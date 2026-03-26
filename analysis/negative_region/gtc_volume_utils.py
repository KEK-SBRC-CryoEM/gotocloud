

import mrcfile
import numpy as np

from miniball import miniball
from scipy.ndimage import affine_transform

## miniball enclosing sphere ##
def enclosing_sphere(volume_segmented):
    """
    Computes the smallest enclosing sphere around the segmented region 
        of a 3D density map, based on a given threshold.

    Parameters:
        volume_segmented (np.ndarray): 3D numpy array representing the density volume after binary segmentation.

    Returns:
        dict: Sphere information (e.g., center and radius) from the miniball algorithm.

    todo: convexhull before miniball may improve speed
    """
    coords = np.column_stack(np.where(volume_segmented==1)).astype(np.float64)
    if coords.size == 0:
        raise ValueError("miniball: no coordinates given. Segmented volume has no density above the input threshold.")
    return miniball(coords)

## mrc file related ##
def load_mrc(filename):
    data = {}
    with mrcfile.open(filename) as mrc:
        data["data"]       = mrc.data
        data["voxel_size"] = mrc.voxel_size.tolist()
    return data

def create_spherical_mask(shape, radius, voxel_size, center=None, filename="mask.mrc"):
    """
    Create a 3D spherical mask with binary values (1 inside sphere, 0 outside).
    
    Parameters:
        shape (tuple): shape of the volume, e.g. (256, 256, 256)
        radius (float): radius of the sphere in voxels
        center (tuple or None): (z, y, x) center of the sphere. If None, uses center of volume
        filename (str): output .mrc file 
    """
    Z, Y, X = np.indices(shape)

    if center is None:
        center = np.array(shape) / 2

    dist = np.sqrt((X - center[2])**2 + (Y - center[1])**2 + (Z - center[0])**2)
    mask = (dist <= radius).astype(np.uint8)

    with mrcfile.new(filename, overwrite=True) as mrc:
        mrc.set_data(mask.astype(np.uint8))
        mrc.voxel_size = voxel_size

## volume manipulation (numpy, scipy) ##
def binary_segmentation(data, threshold=0, is_binary_mask=False):
    """
    Perform binary segmentation on a 3D volume by thresholding.

    Parameters:
        data (np.ndarray): 3D numpy array representing the density map or volume.
        threshold (float): Threshold value for segmentation. Voxels with 
                                     values greater than this threshold are considered foreground. 
        is_binary_mask (bool, optional, default=False): If False, sets voxels outside a centered 
                                            spherical region (corners) to 0. 
                                            If True, interprets the volume as a binary mask and 
                                            applies only simple thresholding (faster).
    Returns:
        np.ndarray: An int8 array (same shape as input) where 1 indicates voxels 
                    above the threshold (segmented region), and 0 otherwise.
    """
    segmented = np.zeros_like(data, dtype=np.int8)
    segmented[data > threshold]  = +1
    segmented[data <= threshold] = 0

    # set 0 to voxels outside sphere bounds
    if not is_binary_mask:
        radius = np.max(data.shape)//2
        z_dim, y_dim, x_dim = data.shape
        center_z, center_y, center_x = z_dim // 2, y_dim // 2, x_dim // 2
    
        z, y, x = np.meshgrid(np.arange(z_dim), np.arange(y_dim), np.arange(x_dim), indexing='ij')
        distances = np.sqrt((x - center_x)**2 + (y - center_y)**2 + (z - center_z)**2)
    
        mask = (distances > radius)
        segmented[mask] = 0
    
    return segmented

def binary_to_grayscale(binary):
    img_gray = binary.astype(np.uint8) * 255
    return img_gray

def get_volume_summed_projection(volume):
    return [volume.sum(axis=i) for i in [0,1,2]]

def get_volume_mean_projection(volume):
    return [volume.mean(axis=i) for i in [0,1,2]]

def get_volume_orthogonal_slices(volume, center=None):
    if center is None:
        cz, cy, cx = volume.shape[0]//2, volume.shape[1]//2, volume.shape[2]//2
    else:
        cz, cy, cx = center
    return [volume[cz, :, :], volume[:, cy, :], volume[:, :, cx]]

def standardize_volume(volume):
    mean = np.mean(volume)
    std = np.std(volume, ddof=0) + 1e-12
    return (volume - mean) / std

def get_spherical_kernel(size):
    z, y, x = np.ogrid[-size//2 : size//2, -size//2 : size//2, -size//2 : size//2]
    return x**2 + y**2 + z**2 <= (size/2)**2

def is_hard_mask(mask):
    return np.all((mask == 0) | (mask == 1))

def covariance_alignment(volume_segmented, volume_original=None):
    # 1. get components by covariance matrix (covariance on the coordinates)
    coords = np.column_stack(np.where(volume_segmented==1)).astype(np.float32)
    
    cov = np.cov(coords, rowvar=False)
    eigvals, eigvecs = np.linalg.eigh(cov)

    # 2. rotate
    center = np.array(volume_segmented.shape) // 2
    R = eigvecs.T
    offset = center - R @ center

    to_rotate = volume_original if volume_original is not None else volume_segmented
    rotated = affine_transform(to_rotate, R,
        offset=offset,
        order=0,
        mode='constant',
        cval=0.0
    )

    return rotated, (eigvals, eigvecs)

## opencv related ##
def normalize_to_uint8(img, max_value):
    return (255*img/max_value).astype(np.uint8)
