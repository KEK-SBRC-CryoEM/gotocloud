import numpy as np

import os
import logging
import argparse

import utils
import gtc_volume_utils as vutils

from size_estimation import estimate_particle_size

import cv2 as cv

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

logger = logging.getLogger("NEGATIVE DENSITY ANALYSIS")

## negative region related ##
def shell_distance_matrix(volume, center=None):
    """
    Compute the Euclidean distance of each voxel in a 3D volume to a specified center.

    Parameters:
        volume (np.ndarray): 3D numpy array representing the volume.
        center (tuple or list of 3 floats/ints, optional): The (z, y, x) coordinates of the center 
            from which distances are measured. If None, the geometric center of the volume is used.

    Returns:
        np.ndarray: A 3D array of the same shape as `volume`, where each voxel contains its 
                    Euclidean distance to the specified center.
    """
    # coordinate grid
    Z, Y, X = volume.shape
    z, y, x = np.ogrid[0:Z, 0:Y, 0:X]
    
    # if no center provided, use volume center
    if center is None:
        cz, cy, cx = Z // 2, Y // 2, X // 2
    else:
        cz, cy, cx = center

    # distance of each voxel to the center
    r2 = (z - cz)**2 + (y - cy)**2 + (x - cx)**2
    r = np.sqrt(r2)

    return r

def shell_average(volume, distance_matrix, shell_radius, tickness=0.5):
    """
    Compute the mean and standard deviation of voxel intensities within a spherical shell.

    Parameters:
        volume (np.ndarray): 3D numpy array representing the density map or volume.
        distance_matrix (np.ndarray): Precomputed array of same shape as volume, where each voxel 
                                   stores its distance to the center (e.g., from shell_distance_matrix).
        shell_radius (float): Radius of the spherical shell (in voxel units) at which to compute statistics.
                        A shell is defined as the region within ±0.5 voxels of this radius.
        tickness (float, optional, default=0.5): Thickness (in voxels) of the spherical shell around the given radius.

    Returns:
        tuple: (avg, std) of voxel intensities within the specified shell.
    """
    mask = (distance_matrix >= shell_radius - tickness) & (distance_matrix <= shell_radius + tickness)

    avg = volume[mask].mean()
    std = volume[mask].std()

    return avg, std

def batch_shell_average(volume, sphere_positive, min_radius=2, shell_tickness=0.5, distance_to="face"):
    """
    Compute the mean and standard deviation of voxel intensities at increasing radial shells 
    from the center of a given sphere within a 3D volume.

    Parameters:
        volume (np.ndarray): 
            3D numpy array representing the density map or volume.
        sphere_positive (dict):
             Dictionary containing the 'center' (np.array of z, y, x coords) of the region of interest.
        min_radius (int, optional): 
            The minimum radius (in voxels) from which to start computing shell statistics. Default is 2.
        shell_tickness (float, optional, default=0.5):
            Thickness (in voxels) of each radial shell.
        distance_to ({"face", "corner"}, optional, default="face"):
            Defines the maximum radius for shell computation.
            - "face": radius = half the smallest box dimension (inscribed sphere).
            - "corner": radius = distance from center to farthest corner (circumscribed sphere).
    Returns:
        tuple:
            - radii (np.ndarray): Array of shell radii.
            - avgs (np.ndarray): Mean values of voxel intensities per shell.
            - stds (np.ndarray): Standard deviation of voxel intensities per shell.
    """

    # Compute voxel-wise distances to the provided center
    center = sphere_positive["center"].astype(int)
    distance_matrix = shell_distance_matrix(volume, center)

    # Define shell radii from min_radius up to the max distance in the map
    if distance_to=="face": 
        max_radius = np.min(np.array(volume.shape)//2) # distance from center to box face 
    elif distance_to=="corner":
        max_radius = int(np.ceil(distance_matrix.max())) # distance from center to box corner
    else:
        raise ValueError("distance_to must be either 'face' or 'corner'")
    radii = np.arange(min_radius, max_radius)

    # Compute mean and std for each shell
    stats = np.array([
        shell_average(volume, distance_matrix, radius, shell_tickness)
        for radius in radii
    ])
    avgs = stats[:, 0]
    stds = stats[:, 1]

    return radii, avgs, stds

def estimate_negative_shell(pos_radius, lim_radius, pos_center, radii, shell_avg_densities, shell_std_densities, mode="zero_crossing"):
    """
    Estimate the boundary of a potential negative-density shell region in a **standardized** cryo-EM map.

    This function examines the shell-averaged densities beyond the known protein boundary
    and attempts to determine whether an additional negative region exists.
    If such a region is detected, the sphere radius is adjusted to the first zero-crossing
    (transition from negative to non-negative average density). If no zero-crossing is found,
    the radius defaults to the outer limit.

    Parameters:
    pos_radius (float):
        The estimated radius of the protein region (inner boundary).
    lim_radius (float):
        The maximum radius considered for analysis (outer boundary).
    pos_center (array-like of float, shape (3,)):
        The center coordinates of the protein region.
    radii (ndarray of shape (n,)):
        Radii corresponding to the shell averages.
    shell_avg_densities (ndarray of shape (n,)):
        Shell-averaged densities of the map. 
        **Expected to come from a standardized (zero mean, unit variance) map.**
    shell_std_densities (ndarray of shape (n,)):
        Standard deviations of voxel densities within each shell.

    Returns:
    sphere (dict): 
        Dictionary with keys:
        - "center" (ndarray): copy of pos_center
        - "radius" (float): estimated boundary of the negative shell region
          (or `pos_radius` if no negative region detected, or `lim_radius` if no zero-crossing found).

    Notes:
    - Detection is based on a heuristic approach on standardized data:
        * condition_a: std(avg_roi) >= 0.15
        * condition_b: min(avg_roi) <= -0.50
      Both conditions must hold to consider a negative region.
    - A more robust approach worth exploring is collecting voxel features and clustering with k={2,3,4}
    """
    # start analyzing just beyond the protein region until maximum radius
    roi   = (radii>pos_radius) & (radii<=lim_radius)

    # filtered data
    rad_roi = radii[roi]
    avg_roi = shell_avg_densities[roi]
    std_roi = shell_std_densities[roi]

    # default value
    sphere = {"center": pos_center.copy(),
              "radius": pos_radius,
              "exist": False
    }
    
    # conditions
    ## a and b are related; a more robust approach worth exploring is collecting voxel features and clustering with k={2,3,4}
    has_negative = avg_roi.size > 0 and np.std(avg_roi) >= 0.15 and np.min(avg_roi) <= -0.50

    # if negative region exist, then find zero cross, if no zero cross, then default to limit
    if has_negative:
        if mode=="zero_crossing":
            zero_crosses = np.argwhere(avg_roi>=0)
            sphere["radius"] = rad_roi[zero_crosses.item(0)] if zero_crosses.size>0 else lim_radius
            sphere["exist"] = True
        elif mode=="quantile75":
            q3 = np.quantile(avg_roi, 0.75)
            sphere["radius"] = np.min(rad_roi[avg_roi>=q3])
            sphere["exist"]  = True
        else:
            ValueError("mode must be either 'zero_crossing' or 'quantile75'")

    return sphere

## plot related ##
def plot_shell_avg(radii, shell_avg, shell_std, radius_protein=None, radius_limit=None, radii_negative=None, mark_roi=False, title="", output_path=None):
    plt.close('all')
    fig, ax = plt.subplots(figsize=(6, 4))

    radius_last = radius_limit if radius_limit is not None else radii[-1]

    # region of interest
    if radius_protein is not None and mark_roi:
        ax.axvspan(radius_protein, radius_last, alpha=1, color="honeydew", label="Region of Interest")

    # standard deviation cloud
    if shell_std is not None:
        ax.fill_between(radii, shell_avg-shell_std, shell_avg+shell_std, alpha=1, color="lightgray", label="Standard Deviation")

    # main curve
    ax.scatter(radii, shell_avg, color='dimgray', edgecolor='k', s=30, label="Shell Average of Densities")

    # other lines (eg: negative region)
    for i, r in enumerate(radii_negative or []):
        ax.axvline(x=r, color='green', linestyle='--', label = None if i > 0 else f"Possible Negative Radi{'us' if len(radii_negative) == 1 else 'i'}")

    # limit line
    ax.axvline(x=radius_last, color='blue', linestyle='-', label="Limit")

    # protein line
    if radius_protein is not None:
        ax.axvline(x=radius_protein, color='red', linestyle='-', label="Protein Radius")

    # zero line
    ax.axhline(y=0, color='black', linestyle='-', alpha=0.8)

    # titles
    ax.set_title(title)
    ax.set_xlabel("Radii")
    ax.set_ylabel("Shell Averages of Densities")
    ax.legend()
    
    plt.tight_layout()
    if output_path:
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    else:
        plt.show()

def get_visualization_images(volume_segmented, mask, center, align=False, mode="summed"):
    # 0. mode setup
    mode_settings = {
        "summed":     {"method": vutils.get_volume_summed_projection, "max_value": lambda img: np.max(img.shape)},
        # "mean":     {"method": vutils.get_volume_mean_projection, "max_value": lambda img: np.max(img.shape)},
        "orthogonal": {"method": vutils.get_volume_orthogonal_slices, "max_value": lambda img: 1},
    }
    try:
        mode_ = mode_settings[mode]
    except KeyError:
        raise ValueError("mode must be either 'summed' or 'orthogonal'")
    
    # 1. segmentation
    # volume_segmented = vutils.binary_segmentation(volume, threshold, is_binary_mask=fast_mode)

    # 2. alignment (optional)
    if align:
        alignment_data = covariance_alignment(hard_mask=mask, center=center, volume=volume_segmented, center_mode="box")

    # 3. project or take slices
    imgs_projections = mode_["method"](alignment_data["volume"] if align else volume_segmented)

    # 4. grayscale normalization
    imgs_gray        = [vutils.normalize_to_uint8(img, max_value=mode_["max_value"](img)) for img in imgs_projections]

    return imgs_gray

def show_slices(imgs_gray, spheres=None, title="", output_path=None):
    plt.close('all')
    subtitles = ["XY", "XZ", "YZ"]
    indices = [(2,1), (2,0), (1,0)]

    # convert to rgb to enable drawing colored circles
    imgs_rgb = [cv.cvtColor(img, cv.COLOR_GRAY2RGB) for img in imgs_gray]

    # draw circles on each projected image
    for j, sphere in enumerate(spheres or []):
        r = int(np.ceil(sphere["radius"]))
        for i in range(3):
            overlay = imgs_rgb[i].copy()
            ax = int(np.ceil(sphere["center"][indices[i][0]]))
            ay = int(np.ceil(sphere["center"][indices[i][1]]))
            cv.circle(overlay, (ax, ay), r, sphere["plot"]["color"], 2)
            imgs_rgb[i] = cv.addWeighted(overlay, sphere["plot"]["alpha"], imgs_rgb[i], 1-sphere["plot"]["alpha"], 0)

    # plot images
    fig, axs = plt.subplots(1, 3, figsize=(12, 4))
    for i in range(3):
        axs[i].imshow(imgs_rgb[i])
        axs[i].set_title(subtitles[i])

    # colorbar
    sm = plt.cm.ScalarMappable(cmap='gray', norm=plt.Normalize(vmin=0, vmax=255))
    fig.colorbar(sm, ax=axs, orientation='vertical', fraction=0.02, pad=0.04)

    fig.suptitle(title, fontsize=14)
    if output_path:
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    else:
        plt.show()

## analysis and plot pipelines ##
def analysis_pipeline(volume, mask=None, threshold=0, mode="zero_crossing"):
    # maximum sphere for this volume shape
    sphere_limit = {"center": np.array(volume["data"].shape)//2,
                    "radius": volume["data"].shape[0]//2
    }
    logger.info(f"Limiting sphere: \n{utils.handle_output(sphere_limit, show=False)}")
 
    # 1. find the sphere enclosing the volume
    logger.info(f"Estimating volume size using {'MASK' if mask else 'VOLUME'}...")

    sphere_positive = estimate_particle_size(volume     = mask["data"] if mask else volume["data"],
                                             voxel_size = mask["voxel_size"] if mask else volume["voxel_size"],
                                             threshold = 0            if mask else threshold, 
                                             kernel_size=3, kernel_spherical=True)
    logger.info(f"Estimated Positive sphere: \n{utils.handle_output(sphere_positive, show=False)}")

    # 2. find the sphere enclosing the negative density region
    logger.info(f"Estimating size of the negative density region...")
    
    logger.info(f"Standardizing volume...")
    volume_standardized = vutils.standardize_volume(volume["data"])

    logger.info(f"Computing shell statistics...")
    radii, shell_avg_densities, shell_std_densities = batch_shell_average(
        volume_standardized, 
        sphere_positive,
        min_radius=2,
        shell_tickness=0.5,
        distance_to="face"
    )
    logger.info(f"Analyzing...")
    sphere_negative = estimate_negative_shell(pos_radius=sphere_positive["radius"], 
                                              lim_radius=sphere_limit["radius"],
                                              pos_center=sphere_positive["center"],
                                              radii=radii,
                                              shell_avg_densities=shell_avg_densities,
                                              shell_std_densities=shell_std_densities,
                                              mode=mode
    )
    sphere_negative["voxel_size"] = volume["voxel_size"]
    logger.info(f"Estimated Negative sphere: \n{utils.handle_output(sphere_negative, show=False)}")

    result = {#"volume"         : volume["data"],
              #"mask"           : mask["data"]   
              "sphere_positive": sphere_positive,
              "sphere_negative": sphere_negative,
              "sphere_limit"   : sphere_limit,
              "radii"          : radii,
              "shell_avg_densities": shell_avg_densities,
              "shell_std_densities": shell_std_densities,
    }

    return result

def figures_pipeline(volume, mask,
                     radii, shell_avg_densities, shell_std_densities, 
                     sphere_positive, sphere_negative, sphere_limit,
                     output_folder=None):
   
    ### Figure 1: shell average vs radii
    pos_radius = int(np.ceil(sphere_positive["radius"]))
    lim_radius = sphere_limit["radius"]
    plot_shell_avg(
        radii=radii,
        shell_avg=shell_avg_densities,
        shell_std=shell_std_densities,
        radius_protein=pos_radius,
        radius_limit=lim_radius,
        radii_negative=None,
        mark_roi=True,
        title="Density Shell Averages",
        output_path=os.path.join(output_folder, "shell_average.png") if output_folder else None
    )

    ### Figure 2 (zoomed)
    neg_mask   = (radii>pos_radius) & (radii<=lim_radius)
    plot_shell_avg(
        radii=radii[neg_mask],
        shell_avg=shell_avg_densities[neg_mask],
        shell_std=None,
        radius_protein=pos_radius,
        radius_limit=lim_radius,
        radii_negative=[int(np.ceil(sphere_negative["radius"]))],
        mark_roi=True,
        title="Density Shell Averages (zoomed)",
        output_path=os.path.join(output_folder, "shell_average_zoomed.png") if output_folder else None
    )

    ### Figure 3: volume visualization
    #### color settings
    sphere_positive["plot"] = {"color": (255, 0, 0), "alpha": 1}
    sphere_limit["plot"]    = {"color": (0, 0, 255), "alpha": 1}
    sphere_negative["plot"] = {"color": (0, 255, 0), "alpha": 1}

    #### 1a. orthogonal slices
    segmented = vutils.binary_segmentation(volume, threshold=-1e-9, is_binary_mask=False)
    images = get_visualization_images(
                volume_segmented = segmented,
                mask      = mask,
                center    = sphere_negative["center"],
                align     = True,
                mode      = "orthogonal"
    )    
    show_slices(
        imgs_gray=images, 
        spheres=[sphere_negative, sphere_limit, sphere_positive],
        title=f"Volume Visualization (Aligned Orthogonal Slices)",
        output_path=os.path.join(output_folder, "volume_aligned_orthogonal_slices")  if output_folder else None
    )

    #### 1b. summed projection
    images = get_visualization_images( 
                volume_segmented = segmented,
                mask      = mask,
                center    = sphere_negative["center"],
                align     = True,
                mode      = "summed"
    )    
    show_slices(
        imgs_gray=images, 
        spheres=[sphere_negative, sphere_limit, sphere_positive],
        title=f"Volume Visualization (Aligned Summed Projection)",
        output_path=os.path.join(output_folder, "volume_aligned_summed_projections") if output_folder else None
    )
    logger.info(f"Done!\n")

if __name__ == "__main__":
    # python negative_estimation.py -
    parser = argparse.ArgumentParser(
        description=(
            "Estimates the size of the negative density of a .mrc file, "
            "Note: This analysis expects a zero-mean volume *before* CTF correction."
            "Usage: \n"
            "\t python negative_estimation.py -v data_testing/postprocess.mrc -m data_testing/prot_mask_final.mrc \n"
            "\t python negative_estimation.py -v data_testing/postprocess.mrc -m data_testing/prot_mask_final.mrc --s --verbose --output-dir results"
        ),
        formatter_class=argparse.RawTextHelpFormatter)
    
    parser.add_argument("-v", "--volume", type=str, required=True, help="MRC file path (.mrc)")
    parser.add_argument("-m", "--mask", type=str, required=True, help="Mask file (.mrc)")
    parser.add_argument("-t", "--threshold", type=float, default=0, help="Threshold value that best filters out noise (default: 0)")
    parser.add_argument("-s", "--save_files", action="store_true", help="Save files related to the analysis:\n(1) Save enclosing sphere as a map file (.mrc)\n(2) Save plots related to the analysis")
    parser = utils.add_common_cli_arguments(parser) # adds --verbose, --json, --output-dir --debug
    args = parser.parse_args()

    # directory creation
    tdir = "." if args.save_files else None
    basedir = utils.prepare_output_environment(args.output_dir or tdir)
    
    # logging
    utils.configure_logging(verbose=args.verbose, output_directory=basedir, capture_warnings=True)
    if basedir:
        logger.info(f"Output directory set to: {basedir}")

    # preprocessing
    logger.info(f"Loading volume: {args.volume} with threshold {args.threshold}")
    volume = vutils.load_mrc(args.volume)
    logger.info(f"Loading mask: {args.mask}")
    mask   = vutils.load_mrc(args.mask) if args.mask else None

    # computation
    logger.info(f"Running analysis pipeline...")
    result = analysis_pipeline(volume=volume,
                                mask=mask,
                                threshold=args.threshold,
                                mode="zero_crossing"
                                # mode="quantile75"
    )

    if args.save_files:
        logger.info(f"Generating figures...")
        figures_pipeline(volume["data"], mask["data"],
                     **result,
                     output_folder=basedir
        )

    # print and save output
    result_ = {k: result[k] for k in ["sphere_positive", "sphere_negative"] if k in result}
    utils.handle_output(result_, to_json=args.json, output_directory=basedir)
    

