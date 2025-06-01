# Authors: (2025.05) Jair Pereira and Toshio Moriya
# This script uses the output from the b-factor plot to
#    compute the minimum number of particles to divide the stack

from bfactor_plot_v3 import line_fit, plot_bfactor, gtf_get_timestamp, compute_bfactor

import os
import time
import yaml
import logging
import argparse
from pathlib import Path

import numpy as np
import pandas as pd

import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, FixedFormatter

mpl.use('pdf')

### BREAKPOINT ###
def calc_mse(xs, ys):
    mse = 0
    sigma2 = 0
    if len(xs)>1:
        slope, intercept = line_fit(xs, ys)
        y_pred = [x * slope + intercept for x in xs]
        mse = np.square(np.subtract(ys, y_pred)).mean()
        sigma2 = np.std(np.subtract(ys, y_pred), ddof=2)**2
    
    return mse, sigma2

def plot_breakpoint(x, y, poi, plot_all=False, savepath=None):
    fig, ax1 = plt.subplots(figsize=(8, 5))
    
    # error line
    line1 = ax1.plot(x, y, label='MSE', color='blue', marker="o")
    
    ax1.set_xlabel("Number of removed datapoints")
    ax1.set_ylabel("Metrics")
    ax1.set_xticks(x)

    for i, (name, ((curve, idx), _, mark)) in enumerate(poi.items()):
        ax1.plot(x[idx], y[idx], marker=mark, color='red', 
             markersize=12+i*1.5, markerfacecolor='none', label=name)

        if plot_all:
            start = len(x) - len(curve)
            ax1.plot(x[start:], curve, label=name, color='green', marker=mark)
    
    ax1.legend()
    fig.tight_layout()

    
    if savepath:
        fig.savefig(savepath, dpi=300)
    return

def find_inflection(x, y):
    dy  = np.gradient(y, x)
    d2y = np.gradient(dy, x)
    
    idx = np.argmax(np.abs(d2y)) + 1

    return  d2y, np.min([len(x)-1, idx])

def find_max_change(x):
    x2 = np.abs(np.diff(x))
    idx = np.argmax(x2) + 1
    return x2, np.min([len(x)-1, idx])
    
def find_max_relative_change(x): # forward change
    x2 = np.diff(x) / (x[:-1]+np.finfo(float).eps) # prevent div by 0
    idx = np.argmax(-x2) + 1 

    return x2, np.min([len(x)-1, idx])


def write_text(xs, ys, mse, breakpoints, filepath=None):
    output_info =  ["\n"]
    output_info += ["Breakpoint Analysis"]
    output_info += ["Min ln(#particles)\t Resolution\t MSE\t #data_points\t Method"]
    output_info += [f"{xs[0]:.3e}\t {ys[0]:.3e}\t {mse[0]:.3e}\t {len(xs)}\t None"]
    output_info += [f"{xs[idx]:.3e}\t {ys[idx]:.3e}\t {mse[idx]:.3e}\t {len(xs[idx:])}\t {name}" for name, ((curve, idx), _,_) in breakpoints.items()]
    output_info += ["\n"]
    
    if filepath:
        with open(filepath, mode='a') as file:
            file.write("\n".join(output_info))

    return output_info

def write_csv(bfactor_data, mse, breakpoints, filepath=None):
    # shortcuts
    x = np.array(bfactor_data["nr_particles"])
    y = np.array(bfactor_data["log_n_particles"])
    z = np.array(bfactor_data["resolutions"])
    w = np.array(bfactor_data["inv_resolution_squared"])

    # dataframe rows
    rows = [[x[0], y[0], z[0], w[0], mse[0], len(x), "None"]]
    rows += [[x[idx], y[idx], z[idx], w[idx], mse[idx], len(x[idx:]), name] for name, ((curve, idx), _, _) in breakpoints.items()]

    # make dataframe
    columns = ["MIN Number of particles", "MIN ln(#particles)", "Resolution", "Res Inv Squared", "MSE", "#data_points", "Method"]
    df = pd.DataFrame(rows, columns=columns)

    if filepath:
        df.to_csv(filepath, index=False)

    return df

def breakpoint_analysis(bfactor_data, method="Inflection on data", output_path=None):
    '''
    This analysis has the assumption that we can break the data into two segments 
        in a way that the remaining datapoints at the rightside have a better linear fit
        than the original complete data

        This analysis does:
        1. Compute the MSE of the remaining rightside line after removing N points from the left side
        2. Decide the breakpoint by using one of these methods:
            2.1. Inflection: compute the second derivative of the MSE and find the highest peak/valley 
            2.2. Max Change on the MSE curve
            2.3. Max Relative Change on the MSE curve
            2.4. Max Relative Change on gradient(MSE) curve
        3. Output this information on text files and plots.
        
    '''
    # prepare output file list
    savepath_list = None
    if output_path:
        savepath_list = {
            "breakpoint_info":           os.path.join(output_path, "breakpoint.csv"),
            "breakpoint_plot":           os.path.join(output_path, "breakpoint_plot.pdf"),
            "breakpoint_rh_none":        os.path.join(output_path, "breakpoint_rh_none.pdf"),
            "breakpoint_rh_inflection1":  os.path.join(output_path, "breakpoint_rh_inflection1.pdf"),
            "breakpoint_rh_inflection2":  os.path.join(output_path, "breakpoint_rh_inflection2.pdf"),
            "breakpoint_rh_maxerror":  os.path.join(output_path, "breakpoint_rh_maxerror.pdf"),
            "breakpoint_rh_relerror":  os.path.join(output_path, "breakpoint_rh_relerror.pdf"),
            "breakpoint_rh_relgrad":  os.path.join(output_path, "breakpoint_rh_relgrad.pdf"),
        }

    # shortcuts
    xs = np.array(bfactor_data["log_n_particles"])
    ys = np.array(bfactor_data["inv_resolution_squared"])
    data_size = len(xs)
    min_datapoints = 3

    # mse of the right side line fit
    mse, sigma  = zip(*[calc_mse(xs=xs[i:], ys=ys[i:]) for i in range(data_size-min_datapoints)])

    # find breakpoint using different methods
    breakpoints = {"Inflection on data":    (find_inflection(range(len(xs)), xs),       "breakpoint_rh_inflection1", "o"),
                   "Inflection on sigma2":  (find_inflection(range(len(sigma)), sigma), "breakpoint_rh_inflection2", "s"),

                   "Max Error Change":      (find_max_change(mse),                      "breakpoint_rh_maxerror", "^"),

                   "Max Relative Error Change":     (find_max_relative_change(mse),                               "breakpoint_rh_relerror", "X"),
                   "Max Relative Gradient Change":  (find_max_relative_change(np.gradient(mse, range(len(mse)))), "breakpoint_rh_relgrad", "*"),

    }
    # breakpoint plot
    plot_breakpoint(x=range(data_size-min_datapoints), 
                    y=mse,
                    poi=breakpoints,
                    plot_all=False,
                    savepath=savepath_list["breakpoint_plot"] if savepath_list else None)

    # new b-factor plots
    plot_bfactor(xs      = bfactor_data["log_n_particles"],
             ys          = bfactor_data["inv_resolution_squared"],
             b_factor    = bfactor_data["b_factor"],
             fitted_line = bfactor_data["fitted_line"],
             savepath    = savepath_list["breakpoint_rh_none"] if savepath_list else None,
             set_yrange = True)

    for name, ((curve, idx), fname, _) in breakpoints.items():
        new_data = compute_bfactor(all_nr_particles = bfactor_data["all_nr_particles"],
                                   nr_particles     = bfactor_data["nr_particles"][idx:],
                                   resolutions      = bfactor_data["resolutions"][idx:],
                                   prediction_range = bfactor_data["prediction_range"])
    
        plot_bfactor(xs          = new_data["log_n_particles"],
                     ys          = new_data["inv_resolution_squared"],
                     b_factor    = new_data["b_factor"],
                     fitted_line = new_data["fitted_line"],
                     savepath    = savepath_list[fname] if savepath_list else None,
                     set_yrange=True)

    # print and save output
    # txt_bp = write_csv(xs, ys, mse, breakpoints, filepath=savepath_list["breakpoint_info"])  
    df_bp = write_csv(bfactor_data, mse, breakpoints, filepath=savepath_list["breakpoint_info"])

    method = method if method in df_bp["Method"] else "Inflection on data"
    return df_bp.loc[df_bp["Method"] == method, "MIN Number of particles"].values[0] 

def load_bfactor_data(path_yaml, path_csv):
    bfactor_data = {}
    
    # load yaml
    with open(path_yaml, 'r') as file:
        dyaml = yaml.safe_load(file)
  
    # load df
    df = pd.read_csv(path_csv)

    # combine data
    dyaml.update({k:list(df[k]) for k in df.columns})

    return dyaml

def get_input_files(input_dir, files_of_interest):
    # for each file of interest, get first available path or None
    file_map = {p: next(Path(input_dir).glob(p), None) for p in files_of_interest}

    # check if any file is missing
    missing_files = [p for p, fp in file_map.items() if fp is None]
    if missing_files:
        print(f"BFACTOR BREAKPOINT | ERROR: The following files were not found in the input directory '{input_dir}': ")
        for fp in missing_files:
            print(f"BFACTOR BREAKPOINT | ERROR: - {fp}")

        raise FileNotFoundError(f"Missing files for: {', '.join(missing_files)}")
    
    return file_map

def run_breakpoint_analysis(input_directory, verbose=False):
    logging.basicConfig(level=logging.INFO if verbose else logging.WARNING, 
                        format="BFACTOR BREAKPOINT | %(levelname)s: %(message)s"
    )

    logging.info("--------------------------------------------------------------------------------------------------------")
    logging.info("Running BFACTOR Breakpoint analysis.")

    # check if the input files exist (raise exception if any file is not found)
    logging.info(f"Reading data from: {input_directory}")
    input_files = get_input_files(input_dir         = input_directory, 
                                  files_of_interest = ["*bfactor_data.yaml", "*particles_resolution.csv"])

    # make output directory
    output_path = os.path.join(input_directory, "breakpoint_analysis", gtf_get_timestamp(True))
    Path(output_path).mkdir(parents=True, exist_ok=True)
    logging.info(f"Making output directory: {output_path}")

    logging.info("Please wait...")

    # load data
    bfactor_data = load_bfactor_data(path_yaml = input_files["*bfactor_data.yaml"],
                                    path_csv  = input_files["*particles_resolution.csv"]
    )

    # data processing 
    result = breakpoint_analysis(bfactor_data, method="Inflection on data", output_path=output_path)
    logging.info(f"Recommended minimum number of particles: {result}")
    
    logging.info("Done!")

    logging.info("--------------------------------------------------------------------------------------------------------")

    return result


if __name__ == "__main__":
    # argument parser
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_directory", type=str, required=True, help="Path to the directory created by the bfactor_plot.py")
    parser.add_argument("-v", "--verbose", action='store_true', help='Enable verbose output')
    args, unknown = parser.parse_known_args()

    result = run_breakpoint_analysis(input_directory=args.input_directory, verbose=args.verbose)
    print(result)
