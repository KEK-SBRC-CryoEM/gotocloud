

import os
from pathlib import Path
import logging
import argparse

import numpy as np
from scipy import ndimage

import utils
import gtc_volume_utils as vutils
from negative_estimation import show_slices

logger = logging.getLogger("VOLUME ALIGNMENT")

def generate_figures(segmented, initial_sphere, aligned_sphere, output_path):
    # define sphere coloring
    initial_sphere["plot"] = {"color": (255, 0, 0), "alpha": 1}
    aligned_sphere["plot"] = {"color": (0, 255, 0), "alpha": 1}

    #
    slices     = vutils.get_volume_orthogonal_slices(segmented)
    imgs_gray  = [vutils.normalize_to_uint8(img, max_value=1) for img in slices]
    show_slices(imgs_gray, spheres=[initial_sphere, aligned_sphere], 
                title="Aligned and Centered Volume (Orthogonal Slices)", 
                output_path=output_path)

def do_alignment(volume, mask, threshold):
    # 1. segmentation if mask is not provided
    segmented = mask
    if mask is None:
        segmented = vutils.binary_segmentation(volume, threshold, is_binary_mask=False)

    # 2. center of the volume
    initial_enclosing_sphere = vutils.enclosing_sphere(segmented)

    # 3. pca alignment
    alignment_data = vutils.covariance_alignment(hard_mask=segmented, 
                                                 center=initial_enclosing_sphere["center"], 
                                                 volume=volume,
                                                 center_mode="box")

    alignment_data["initial_enclosing_sphere"] = initial_enclosing_sphere
    alignment_data["aligned_enclosing_sphere"] = vutils.enclosing_sphere(alignment_data["mask"])

    return alignment_data

if __name__ == "__main__":
    # python volume_alignment.py -v volume.mrc -m mask.mrc -s
    # python volume_alignment.py -v volume.mrc -t 0.01 -s
    parser = argparse.ArgumentParser(
        description=(
            "Aligns a 3D volume/mask to the orthogonal axes. "
            "Calculates the rotation "
            "using Principal Component Analysis (PCA) to orient the longest "
            "view of the structure along a primary axis and center it within "
            "the coordinate box. User provides the volume to be aligned "
            "and threshold for binary segmentation OR a binary mask."
            
            "Usage: \n"
            "\t python volume_alignment.py -v volume.mrc -m mask.mrc -s\n"
            "\t python volume_alignment.py -v volume.mrc -t 0.01 -s"
        ),
        formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument("-v", "--volume",    type=str, required=True, help="Path to the volume file (.mrc)")
    parser.add_argument("-m", "--mask",      type=str,                help="Path to the mask file (.mrc)")
    parser.add_argument("-t", "--threshold", type=float, default=0,   help="Threshold for binary segmentation.")
    parser.add_argument("-s", "--save",      action="store_true",     help="Save orthogonal slices of the aligned volume.")
    parser = utils.add_common_cli_arguments(parser) # adds --verbose, --json, --output-dir --debug
    args = parser.parse_args()

    # directory creation
    basedir = utils.prepare_output_environment(args.output_dir)

    # logging
    utils.configure_logging(verbose=args.verbose, output_directory=basedir, capture_warnings=True)

    if basedir:
        logger.info(f"Output directory set to: {basedir}")

    # computation
    logger.info(f"Loading volume: {args.volume}")
    volume_mrc = vutils.load_mrc(args.volume)
    volume     = volume_mrc["data"]
    voxel_size = volume_mrc["voxel_size"]
    
    logger.info(f"+ Input threshold: {args.threshold if not args.mask else None}")
    
    logger.info(f"Loading mask: {args.mask}")
    mask   = vutils.load_mrc(args.mask)["data"] if args.mask else None
    logger.info(f"+ Binary Mask? {vutils.is_hard_mask(mask)}")

    logger.info(f"Running alignment...")
    alignment_data = do_alignment(volume, mask, args.threshold)
    alignment_data["box_size"] = alignment_data["volume"].shape[0]

    # saving aligned volume
    avolume_path = os.path.join(basedir or ".", f"aligned_{Path(args.volume).name}")
    amask_path = os.path.join(basedir or ".", f"aligned_{Path(args.mask).name}") if args.mask else None

    vutils.save_mrc(volume=alignment_data["volume"],
                    voxel_size=voxel_size,
                    filename=avolume_path)
    if amask_path:
        vutils.save_mrc(volume=alignment_data["mask"],
                voxel_size=voxel_size,
                filename=amask_path)

    # figures
    logger.info(f"Save figures? {args.save}")
    if args.save:
        outp = os.path.join(basedir or ".", "orthogonal_view.png")
        logger.info(f"+ Saving to {outp}")
        generate_figures(segmented      = alignment_data["mask"],
                         initial_sphere = alignment_data["initial_enclosing_sphere"], 
                         aligned_sphere = alignment_data["aligned_enclosing_sphere"], 
                         output_path    = outp)

    

    # print and save output
    ## replacing volume and mask data by its path
    alignment_data["volume"] = avolume_path
    alignment_data["mask"]   = amask_path
    
    utils.handle_output(alignment_data, to_json=args.json, output_directory=basedir)
