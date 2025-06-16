# Authors: (2025.04) Jair Pereira and Toshio Moriya
# This script plots the CTF Limit for a list of parameter:
#    boxsizes, defocus, and pixel sizes

import os
import copy
import yaml
import time
import argparse
import numpy as np
from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, FixedFormatter
from matplotlib.patches import Circle

matplotlib.use('Agg') # prevents opening the gui

import logging
logger = logging.getLogger(__name__)

from ctf import ctf_limit, relativistic_electron_wavelength, phaseshift_ctf, phaseshift_ctf2d

### utils ###
def create_numbered_folder(base_path="."):
    '''
    created a numbered folder '000' at base_path
    if base_path/'000' already exists, increments one and try again
    '''
    n = 0
    while True:
        folder_name = f"{n:03d}"
        full_path = os.path.join(base_path, folder_name)
        if not os.path.exists(full_path):
            os.makedirs(full_path)
            return full_path
        n += 1

def gtf_get_timestamp(file_format=False):
	"""
	Utility function to get a properly formatted timestamp. 

	Args:
		file_format (bool): If true, timestamp will not include ':' characters
			for a more OS-friendly string that can be used in less risky file 
			names [default: False ]
	"""
	if file_format:
		return time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime())
	else:
		return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

def load_yaml(filepath):
    """
    Receives a string filepath for a .yaml file and loads it as a dictionary
    """
    if filepath is not None and filepath.strip()!="":
        parameters = yaml.safe_load(filepath)
        with open(filepath, 'r') as yaml_file:
            yaml_dict = yaml.safe_load(yaml_file)
        return yaml_dict
    return None

def process_params(dparams):
    params = copy.deepcopy(dparams)
    params["boxsizes_all"] = np.array(params["boxsizes"])
    params["boxsizes"]     = np.array(params["boxsizes"])
    
    # handling user input
    if params["box_lower_bound"]==-1:
        params["box_lower_bound"] = params["boxsizes"].min()
        
    if params["box_upper_bound"]==-1:
        params["box_upper_bound"] = params["boxsizes"].max()

    if params["compute_all_boxsizes"]: # use all values between min and max
        params["boxsizes"] = range(params["box_lower_bound"], params["box_upper_bound"], 1)
    else: # filter boxsize list based on the given bounds
        mask = (params["boxsizes"] >= params["box_lower_bound"]) & (params["boxsizes"] <= params["box_upper_bound"])
        params["boxsizes"] = params["boxsizes"][mask]

    return params

### ctflimit ###
def compute_ctf_limits_for_boxsizes(boxsize_list, pixel_size, voltage, defocus, cs, limit_resolution=15):
    '''
    calls ctf_limit for a list of boxsizes

    returns an np.array where 
        [:,0] -> fourier pixel
        [:,1] -> limiting resolution;
        [:,2] -> boxsize
    '''

    # Compute CTF Limit for all boxsizes
    ctf_values = np.array([(*ctf_limit(boxsize          = v,
                                       defocus          = defocus,
                                       cs               = cs,
                                       voltage          = voltage,
                                       pixel_size       = pixel_size,
                                       limit_resolution = limit_resolution), v) for v in boxsize_list])


    ctf_values[:,1] = 1/ctf_values[:,1]

    return ctf_values

def compute_ctf_limits_for_parameter_list(pixel_list, defocus_list, boxsize_list, voltage, cs, limit_resolution=15):
    '''
    calls compute_ctf_limits_for_boxsizes for a list of pixel_sizes and list of defocus

	Returns:
		dict: A nested dictionary structured as:
			data[pixel_size][defocus] = ctflimit_data
	'''
    data = {}
    for pix in pixel_list:
        data[pix] = {}
        data[pix]["nyquist_limit"] = 2*pix
        for defocus in defocus_list:
            data[pix][defocus] = compute_ctf_limits_for_boxsizes(boxsize_list     = boxsize_list,
                                                                 defocus          = defocus,
                                                                 cs               = cs,
                                                                 voltage          = voltage,
                                                                 pixel_size       = pix,
                                                                 limit_resolution = limit_resolution)
    return data

def compute_best_boxsize(boxsize_list, pixel_size, voltage, defocus, cs, limit_resolution=15):
    # evaluate all boxsizes
    data =  compute_ctf_limits_for_boxsizes(boxsize_list, pixel_size, voltage, defocus, cs, limit_resolution)

    # get best resolution
    best_solution = data[np.argmin(data[:,1])]

    # return resolution, boxsize
    return best_solution[1], best_solution[2]

### ctf plot ###
def plot_ctf_1d(spatial_frequencies, phaseshift_ctf, title="", filename=None):
    x = spatial_frequencies
    y = phaseshift_ctf

    fig, ax1 = plt.subplots()
    ax1.plot(x, y, label="CTF")
    ax1.set_xlabel("Spatial frequency [1/Å]")
    ax1.set_ylabel("CTF")
    ax1.set_title(f"CTF - {title}")
    ax1.grid(False)

    ax2 = ax1.twiny()
    ax2.xaxis.set_ticks_position("bottom")
    ax2.xaxis.set_label_position("bottom")
    ax2.set_xlim(ax1.get_xlim())
    ax2.spines["bottom"].set_position(("axes", -0.25))
    freq_ticks = ax1.get_xticks()
    resolution_ticks = [f"{1/x:.2f}" if x != 0 else "" for x in freq_ticks]
    ax2.xaxis.set_major_locator(FixedLocator(freq_ticks))
    ax2.xaxis.set_major_formatter(FixedFormatter(resolution_ticks))
    ax2.set_xlabel("Resolution [Å]")

    plt.tight_layout()
    # plt.legend()
    if filename:
        fig.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close(fig)

def plot_ctf_2d(phaseshift_ctf2d, nyquist, boxsize, filename=None):
    extent = [-nyquist, nyquist, -nyquist, nyquist]

    fig, ax = plt.subplots()
    img = ax.imshow(phaseshift_ctf2d, cmap='gray', origin='lower', extent=extent)
    ax.set_xlabel("Spatial frequency [1/Å]")
    ax.set_ylabel("Spatial frequency [1/Å]")
    ax.set_title(f"Thon Rings for boxsize = {256}")
    cbar = fig.colorbar(img, ax=ax, label="CTF amplitude")


    circle = Circle((0, 0), nyquist, color='red', alpha=1.0, fill=False, linestyle='--', lw=2)
    ax.add_patch(circle)

    plt.tight_layout()

    if filename:
        fig.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close(fig)

### plots ###
def make_figs_by_pixelsize(data, pixelsize_list, defocus_list, limit_resolution, output_path):
    """
    Generates one figure from plot_resolution_boxsize_curves_by_defocus
        for several values of pixel size

    todo:
        get pixel and defocus using data.keys() but need to exclude nyquist_limit and check if needs sorting
    """
    for pix in pixelsize_list:
        fig = plot_resolution_boxsize_curves_by_defocus(data[pix], pix, defocus_list, limit_resolution)
        fig.savefig(os.path.join(output_path, f"ctflimit_pixel{pix:.2f}.pdf"), dpi=300, bbox_inches='tight')
        plt.close(fig)
        
def plot_resolution_boxsize_curves_by_defocus(data, pixel_size, defocus_list, limit_resolution):
    """
    Generates a figure where
        x-axis: boxsizes
        y-axis: resolution
        curves: defocus settings
    """
    fig, ax = plt.subplots(figsize=(12, 8))

    for defocus in defocus_list:
        data_x = data[defocus][:, 2]  # box size
        data_y = data[defocus][:, 1]  # resolution

        x_min =  data[defocus][:, 2].min()
        x_max =  data[defocus][:, 2].max()
        
        ax.plot(
            data_x,
            data_y,
            marker='o',
            linestyle='-',
            label=f"{defocus}"
        )

    # nyquist
    nyquist_limit = data["nyquist_limit"]
    ax.plot(
        [x_min, x_max],
        [nyquist_limit, nyquist_limit],
        linestyle='-',
        color='black',
        linewidth=3,
        label=f"Nyquist: {nyquist_limit}[Å]"
    )

    ax.set_title(f"CTF Limit: Maximum Resolution for a Given Box Size Across Multiple Defocus Values for pixel size={pixel_size} [Å]")
    ax.set_xlabel("Box size")
    ax.set_ylabel("Resolution [Å]")
    ax.set_xlim(0, x_max + 10)
    ax.set_ylim(0, 40)
    # ax.set_ylim(0, limit_resolution)
    # ax.set_yticks(np.arange(0, limit_resolution + 1.5, 1.5))

    # place legend inside
    ax.legend(
        title="Defocus [µm]",
        loc='upper right',
        bbox_to_anchor=(0.98, 0.98),
        frameon=True,
        edgecolor='black'
    )
    # hide top and right spines, show left and bottom
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    return fig        

def table_optimal_boxsize(data, boxsize_list, boxsize_lower_bound, pixelsize_list, defocus_list, tol=0):
    '''
    returns a np.array where each row is
        row: ["Pixel Size [Å]", "Defocus [µm]", "CTF Limit []", "Minimum Boxsize", ctflimit==nyquist?]
    '''
    table_dict = {}
    mask = (boxsize_list >= boxsize_lower_bound)
    for pix in pixelsize_list:
        table_dict[pix] = []
        for defocus in defocus_list:
            min_idx   = data[pix][defocus][:,1][mask].argmin()
            ctf_limit = data[pix][defocus][:,1][mask][min_idx]
            box_min   = data[pix][defocus][:,2][mask][min_idx]

            mark = "*" if abs(ctf_limit - data[pix]["nyquist_limit"]) > tol else "" # if ctflimit == nyquist within a tol
            table_dict[pix] += [[float(pix), float(defocus), ctf_limit, int(box_min), mark]]
        table_dict[pix] = np.array(table_dict[pix], dtype="object")
    return table_dict

def save_table(table_data, output_path):
    header = ["Pixel Size [Å]", "Defocus [µm]", "CTF Limit [Å]", "Minimum Boxsize"]
    
    # from dictionary to single np.array
    data = np.array([row for k, v in table_data.items() for row in v], dtype="object")
    
    # adjusting the decimal points
    data[:,0] = np.array([f"{x:.3f}" for x in data[:,0]]) # pixel size
    data[:,2] = np.array([f"{x:.2f}{m}" for x,m in zip(data[:,2], data[:,4])]) # ctf limit
    data[:,3] = np.array([f"{int(x)}" for x in data[:,3]]) # min boxsize
    data = np.delete(data, 4, axis=1) # delete the marking column

    # make Figure
    fig, ax = plt.subplots(figsize=(6, len(data) * 0.5 + 1))
    ax.axis('tight')
    ax.axis('off')
    
    table = ax.table(cellText=data, colLabels=header, loc='center')
    
    # bold header
    for col in range(len(header)):
        cell = table[(0, col)]
        cell.set_text_props(weight='bold')
        cell.set_facecolor('#CCCCCC')  # Light gray header

    # footer
    table.scale(1, 1.1)  # make room vertically
    fig.text(0.5, 0.02, "*: Worse than Nyquist", ha='center', va='center', fontsize=10, style='italic')

    plt.savefig(os.path.join(output_path, "min_boxsizes.pdf"), bbox_inches='tight', dpi=300)

def plot_boxsize_vs_defocus_by_pixelsize(data, pixelsize_list, output_path):
    fig, ax = plt.subplots(figsize=(12, 8))
    yticks = set()
    xticks = set()
    
    for pix in pixelsize_list:
        data_x  = data[pix][:,1] # defocus
        data_y  = data[pix][:,3] # min boxsize
        
        yticks = yticks.union(set(data_y))
        xticks = xticks.union(set(data_x))
        
        ax.plot(
            data_x,
            data_y,
            marker='o',
            linestyle='-',
            label=f"{pix:.3f}"
        )
    
    ax.set_title(f"Minimum Boxsize vs. Defocus")
    ax.set_xlabel("Defocus values [µm]")
    ax.set_ylabel("Minimum Boxsize for the best resolution")
    
    ax.set_xticks(list(xticks))
    ax.set_yticks(list(yticks))
    
    ax.legend(
        title="Pixel Size [Å]",
        # loc='upper right',
        # bbox_to_anchor=(0.98, 0.98),
        frameon=True,
        edgecolor='black'
    )
    
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
            
    fig.savefig(os.path.join(output_path, f"defocus_vs_boxsize.pdf"), dpi=300, bbox_inches='tight')
    plt.close(fig)

### analyses pipelines ###
def run_boxsize_plot(path_params):
    logger.info(f"Running Complete Boxsize analysis")

    # 1. Load user data and prepares directory structure
    config = load_yaml(path_params)
    config = process_params(config)
    logger.info(f"Loading parameters from {path_params}")

    # config["output_folder"] = create_numbered_folder(config["output_folder"])
    config["output_folder"] = os.path.join(config["output_folder"], gtf_get_timestamp(True))
    Path(config["output_folder"]).mkdir(parents=True, exist_ok=True)
    # subfolder = os.path.join(config["output_folder"], "ctf")
    # Path(subfolder).mkdir(parents=True, exist_ok=True)
    logger.info(f"Setting output folder to: {config['output_folder']}")

    # 2. Compute the ctf limit for several pixel sizes, defocus values, and boxsizes
    logger.info("Computing CTF data... (may take a while)")
    ctf_data = compute_ctf_limits_for_parameter_list(
        pixel_list       = config["pixel_size"],
        defocus_list     = config["defocus"],
        boxsize_list     = config["boxsizes_all"],
        voltage          = config["voltage"],
        cs               = config["cs"],
        limit_resolution = config["limiting_resolution"],
    )

    # 3. Save the minimum boxsize to a pdf and plot
    logger.info("Processing data and generating output files...")
    table_data = table_optimal_boxsize(
                    data                = ctf_data,
                    boxsize_list        = config["boxsizes_all"],
                    boxsize_lower_bound = config["boxsizes"][0],
                    pixelsize_list      = config["pixel_size"],
                    defocus_list        = config["defocus"],
                    tol                 = config["nyquist_tol"]
    )

    save_table(table_data, output_path=config['output_folder'])

    plot_boxsize_vs_defocus_by_pixelsize(
        data           = table_data,
        pixelsize_list = config["pixel_size"],
        output_path    = config['output_folder']
    ) # here we feed the filtered data and in the plot below and unfiltered

    # 4. Plot and save
    make_figs_by_pixelsize(
        data = ctf_data,
        pixelsize_list = config["pixel_size"],
        defocus_list   = config["defocus"],
        output_path    = config["output_folder"],
        limit_resolution = config["limiting_resolution"]
    )

    # 5. Plot CTF versus boxsizes (too many figures)
    # run_ctf_vs_boxsize(
    #     voltage        = config["voltage"],
    #     cs             = config["cs"],
    #     pixelsize_list = config["pixel_size"],
    #     defocus_list   = config["defocus"],
    #     boxsize_list   = config["boxsizes"],
    #     output_folder  = subfolder
    # )
    
    logger.info("Done!")

def run_boxsize_optimal(pixel_size, voltage, defocus, cs, limit_resolution=15):
    logger.info("Running Optimal Boxsize analysis")

    # from: https://blake.bcm.edu/emanwiki/EMAN2/BoxSize
    # for our application, we consider the minimum boxsizes >450
    boxsize_list = [#24, 32, 36, 40, 44, 48, 52, 56, 60, 64,
                    #72, 84, 96, 100, 104, 112, 120, 128, 132, 140,
                    #168, 180, 192, 196, 208, 216, 220, 224, 240, 256,
                    #260, 288, 300, 320, 352, 360, 384, 416, 440, 448,
                    480, 512, 540, 560, 576, 588, 600, 630, 640, 648,
                    672, 686, 700, 720, 750, 756, 768, 784, 800, 810,
                    840, 864, 882, 896, 900, 960, 972, 980, 1000, 1008, 
                    1024, 
    ] # for custom boxsizes, please use plot mode

    res_f, res_b = compute_best_boxsize(boxsize_list, pixel_size, voltage, defocus, cs, limit_resolution=15)

    logger.info(f"Best boxsize {res_b} for resolution {res_f} [Å]")

    return res_f, res_b

def run_ctf_vs_boxsize(voltage, cs, pixelsize_list, defocus_list, boxsize_list, output_folder):
    lambda_ = relativistic_electron_wavelength(voltage_kV=voltage)
    c = cs*1e7 # mm to Å
    
    for pixel_size in pixelsize_list:
        nyquist = 1/(2*pixel_size)
        for defocus in defocus_list:
            z = defocus*-1e4 # positive for underfocus in Å (from µm)
            for boxsize in boxsize_list:
                # CTF
                freq, ctf1d = phaseshift_ctf(
                    lambda_    = lambda_,
                    pixel_size = pixel_size,
                    defocus    = z,
                    cs         = c,
                    boxsize    = boxsize
                )

                plot_ctf_1d(freq, ctf1d, 
                    title=f"pixelsize={pixel_size} defocus={defocus} boxsize={boxsize}",
                    filename=os.path.join(output_folder, f"CTF_pixelsize{pixel_size}_defocus{defocus}_boxsize{boxsize}.png")
                )

                # Thon Rings
                f, c = phaseshift_ctf2d(
                    lambda_    = lambda_,
                    pixel_size = pixel_size,
                    defocus    = z,
                    cs         = c,
                    boxsize    = boxsize
                )
                plot_ctf_2d(c, nyquist, boxsize, filename=os.path.join(output_folder, f"CTF2D_pixelsize{pixel_size}_defocus{defocus}_boxsize{boxsize}.png"))

if __name__ == "__main__":
    # boxsize_analysis.py -q opt -p 1.2 -v 300 -d -0.8 -c 2.7 
    # boxsize_analysis.py -q opt -p 1.2 -v 300 -d -0.8 -c 2.7 -save
    # boxsize_analysis.py -q plot -p config/boxsize.yaml 

    ### Argument Parser and Script Mode Selection ###
    parser = argparse.ArgumentParser(
        description=(
            "CTF Analysis to aid choosing the right boxsize\n\n"
            "Choose one of the modes:\n"
            "  - plot: Analyze multiple microscope setups using a parameter file.\n"
            "  - opt : Compute the optimal box size for a specific setup using direct inputs.\n\n"
            "Use one of the modes below followed by -h to see mode-specific options.\n"
            "Example:\n"
            "  python boxsize_analysis.py -q plot -p params.yaml\n"
            "  python boxsize_analysis.py -q opt -p 1.2 -v 300 -d -0.8 -c 2.7"
            "Ommit -q for verbose ouput."
        ),
        formatter_class=argparse.RawTextHelpFormatter  # preserves line breaks
    )
    parser.add_argument("-q", "--quiet", action='store_true', help="Disable verbose output")
    subparsers = parser.add_subparsers(dest="mode", required=True, help="Choose between modes 'plot' or 'opt'")

    ### Parameters for Plot Mode ###
    plot_parser = subparsers.add_parser("plot", help="Run analysis over multiple parameter sets")
    plot_parser.add_argument("-p", "--param_file", type=str, required=True, help="Path to parameter file")

    ### Parameters for Optimal Mode ###
    opt_parser = subparsers.add_parser("opt", help="Run single calculation with custom parameters")
    opt_parser.add_argument("-p", "--pixel_size", type=float, required=True, help="Pixel size in [Å].")
    opt_parser.add_argument("-v", "--voltage",    type=float, required=True, help="Microscope accelerating voltage in [kV].")
    opt_parser.add_argument("-d", "--defocus",    type=float, required=True, help="Defocus value in micrometers [µm].")
    opt_parser.add_argument("-c", "--cs",         type=float, required=True, help="Spherical aberration constant (Cs) in millimeters [mm].")
    opt_parser.add_argument("-limres", "--limit_resolution",  default=15, type=float, help="(Optional) Estimate CTF only up to this limiting resolution")
    opt_parser.add_argument("-save", "--save_plots", action='store_true', help="Saves the CTF plots for 1D and 2D.")
  
    args = parser.parse_args()

    ### Logging ###
    logging.basicConfig(level=logging.WARNING if args.quiet else logging.INFO, 
                        format=f"CTF {args.mode.upper()} | %(levelname)s: %(message)s"
    ) # modify logging setting only if run from main 

    ### Mode Execution ###
    if args.mode=="plot":
        run_boxsize_plot(path_params=args.param_file)
    elif args.mode=="opt":
        result = run_boxsize_optimal(pixel_size       = args.pixel_size,
                                     voltage          = args.voltage,
                                     defocus          = args.defocus,
                                     cs               = args.cs,
                                     limit_resolution = args.limit_resolution)
        print(result)
        if args.save_plots:
            output_path = os.path.join("boxsize_analysis", gtf_get_timestamp(True))
            # output_path = "./boxsize_analysis"
            Path(output_path).mkdir(parents=True, exist_ok=True)
            run_ctf_vs_boxsize(
                voltage        = args.voltage,
                cs             = args.cs,
                pixelsize_list = [args.pixel_size],
                defocus_list   = [args.defocus],
                boxsize_list   = [int(result[1])],
                output_folder  = output_path
            )
    else:
        logger.warning(f"Unknown mode {args.mode}! Exiting...")

