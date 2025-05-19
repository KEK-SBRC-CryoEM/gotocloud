## Overview

This script estimates the **B-factor** from RELION jobs and:

- Saves the estimated value to a `.txt` file
- Generates a corresponding plot in `.pdf` format

It uses the results from **Refine3D** and **PostProcess** jobs.

## Table of Contents
1. [Installation](#installation)
2. [Running from Relion's External Tab](#running-from-relions-external-tab)
3. [Running from the Terminal](#running-from-the-terminal)
4. [About the Script](#about-the-script)

## Installation

Follow these steps to install and set up the script in your working directory:

### 1. Clone the GitHub Repository

First, clone the GitHub repository to your local machine:

```bash
git clone -b add_bfactor_plot https://github.com/KEK-SBRC-CryoEM/gotocloud.git
```

### 2. Add permission to run the script
```bash
 chmod +x gotocloud/rln_external/bfactor_plot/bfactor_plot.py
 ```

## Running from RELION's External Tab

Follow these steps to run the script through the RELION GUI:

### 1. Module Load and Open RELION
Load the `schemes-editing` module then launch the RELION GUI.
```
module load schemes-editing
relion &
```

### 2. Select the "External" Job Type

In the left-hand job list, select **External**.

### 3. Configure script path (Input Tab)

In the Input tab of the External job:
- Set **External executable** to: `full/path/to/gotocloud/rln_external/bfactor_plot/bfactor_plot.py`

### 4. Configure Parameters (Params Tab)

In the Params tab of the External job, add parameters in the following way:

> **Left side** = Parameter **label** (copy exactly)  
> **Right side** = Parameter **value** (you provide)

#### **Required Parameters**
| Label                    | Value                                 |
|:-------------------------|:--------------------------------------|
| `input_refine3d_job`     | Path to the input Refine3D job        |
| `input_postprocess_job`  | Path to the input PostProcess job     |
| `minimum_nr_particles`   | Minimum number of particles           |
| `maximum_nr_particles`   | Maximum number of particles           |

#### **Optional: `mpi_parameters.yaml`**
This is used to provide machine-specific parameters (e.g.: MPI settings). You can leave it **empty** in most cases.

By default, the script will automatically use the same parameter values from the input **Refine3D** or **PostProcess** jobs.

However, if you'd like to **manually define these parameters**, you can:

1. Edit the [`config/mpi_parameters.yaml`](config/mpi_parameters.yaml) file.
2. In the Params tab, set the **path** to this file in the `mpi_parameters` input field:

| Label                    | Value                              |
|:-------------------------|:-----------------------------------|
| `mpi_parameters`         | Path to mpi_parameters.yaml        |


### 5. Run the Script

Click **Run!**

Once finished, the script will save its output:
```
External/<job_name>/BFACTOR_PLOT_estimated.txt
External/<job_name>/BFACTOR_PLOT_rosenthal-henderson-plot.pdf
```

## Running from the Terminal
You can also run the script directly from the terminal using the following command:

```bash
python3 ./bfactor_plot/bfactor_plot.py -o path/to/output -i3d path/to/Refine3D/jobXXX/ -ipp path/to/PostProcess/jobYYY/ --minimum_nr_particles 225 --maximum_nr_particles 7200 -p path_parameter.yaml
```

Where:
- `-o`: Specify the output path. 
   - The script creates the directory if it does not exist. 
   - If the directory already exists, it appends a timestamp at the end of the directory name. 
   - If no output path is provided, it writes the output to `"External/bfactor_<timestamp>"`.
- `-i3d`: Path to the Refine3D job folder.
- `-ipp`: Path to the PostProcess job folder.
- `-minp`: Set the minimum number of particles (default: 5000).
- `-maxp`: Set the maximum number of particles (default: 400000).
- `-p`: (Optional) Provide a path to the parameter YAML file. This can be omitted if you don't need to manually set machine-specific parameters (as explained above). In this case, the script will automatically use values from the input **Refine3D** or **PostProcess** jobs.

> **Note:**  
> The script must be executed **inside** the RELION project directory (where your `Refine3D` and `PostProcess` jobs are).  
> The `.py` script itself can be located anywhere on your system. 

## About the Script

This script is an improved version of the `bfactor_plot.py` from the RELION project ([GitHub Link](https://github.com/3dem/relion/blob/master/scripts/bfactor_plot.py)). The core functionality for computing the **B-factor** has **not** been changed or refactored. The improvements focus mainly on input handling and script compatibility. 

## Breakpoint Analysis
(beta) We included an additional breakpoint analysis to suggest the minimum number of particles to be used in which the B-Factor line

### Changes from the original script:
- Added support for **YAML files** instead of raw `.py` for parameter input (mpi parameters).
- Replaced `sys.argv` with **argparse** for better argument handling.
- Added functionality for setting the **output_node.star** file.
- Improved handling of **matplotlib** and **numpy** imports.
- Replaced **np.int** (deprecated) with **int** for compatibility.
- Fixed the issue with outputting `\u00C5` for **Å** (angstrom symbol).
- Resolved **matplotlib UserWarning** regarding setting tick labels before setting ticks on `ax2` and `ax3`.
- Improved default parameter loading from **Refine3D** and **PostProcess** `job.star` files, when the YAML file is not provided, the mpi parameters are the same as in `job.star`.
- Added breakpoint analysis.


Im a bit stuck on the bfactor analysis, and I may need some time to think about it

The code is working and tries to minimize the fitting error on the right-hand side of the curve.
However, the sample data have two significant digits (inverse resolution squared ranges from ~0.00 to ~0.10).
The MSE on the data versus line fit has error on the 5th decimal place which have no practical impact on the resolution 
Even though we visually see that some datapoints are not perfectly fit on the line as in the figure below

I am going to focus more on CTF while I think about this issue
It seems at this point that the simple solution of filtering the datapoints based on the user input resolution is enough


Your message is clear in intent but can benefit from smoother flow and more precise language. Here's an improved version for clarity and tone:

---


However, when looking at the sample data, I noticed it has only two significant digits (inverse resolution squared ranges from ~0.00 to ~0.10). 

As a result, the mean squared error between the data and the fitted line is on the order of the fifth decimal place, which has no practical impact on the resolution.

Visually, we can still see that a few points do not lie perfectly on the line (as in the figure below) but this difference is negligible in practice.

For now, Im going to shift my focus to the CTF analysis while I continue to think about the bfactor analysis. 
At this point, it seems that the simple solution of filtering the datapoints based on a user defined resolution threshold may work best.

---

Let me know if you'd like to tailor this for an email, paper, or documentation.

