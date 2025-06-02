# Overview

This folder includes two scripts for analyzing B-factor behavior from RELION jobs:

- **[`bfactor_plot.py`](./bfactor_plot.py)** (main script): estimates the B-factor from `Refine3D` and `PostProcess` jobs
- **[`bfactor_breakpoint.py`](./bfactor_breakpoint.py)** (optional): analyzes resolution vs. particle count to detect breakpoints

Most users will only need `bfactor_plot.py`. Use `breakpoint_analysis.py` when you need to **split the particle stack** as  this script helps identify the **minimum number of particles per subset** based on resolution behavior.

# Table of Contents
1. [Installation](#1-installation)
2. [B-factor plot](#2-b-factor-plot)  
   2.1. [Running from Relion's External Tab](#21-running-from-relions-external-tab)  
   2.2. [Running from the Terminal](#22-running-from-the-terminal)  
   2.3. [About the Script](#23-about-the-script)  
3. [Breakpoint analysis](#3-breakpoint-analysis)  
4. [Requirements](#4-requirements)

# 1. Installation

Follow these steps to install and set up the script in your working directory:

## 1.1. Clone the GitHub Repository

First, clone the GitHub repository to your local machine:

```bash
git clone -b add_bfactor_plot https://github.com/KEK-SBRC-CryoEM/gotocloud.git
```

## 1.2. Add permission to run the script
```bash
 chmod +x gotocloud/rln_external/bfactor_analysis/bfactor_plot.py
 chmod +x gotocloud/rln_external/bfactor_analysis/bfactor_breakpoint.py
 ```

# 2. B-factor plot

This script estimates the **B-factor** from RELION jobs and:

- Saves the estimated value to a `.txt` file
- Generates a corresponding plot in `.pdf` format

It uses the results from **Refine3D** and **PostProcess** jobs.

## 2.1 Running from RELION's External Tab

Follow these steps to run the script through the RELION GUI:

### 2.1.1. Module Load and Open RELION
Load the `schemes-editing` module then launch the RELION GUI.
```
module load schemes-editing
relion &
```

For use outside KEK, check [Requirements](#4-requirements).

### 2.1.2. Select the "External" Job Type

In the left-hand job list, select **External**.

### 2.1.3. Configure script path (Input Tab)

In the Input tab of the External job:
- Set **External executable** to: `full/path/to/gotocloud/rln_external/bfactor_analysis/bfactor_plot.py`

### 2.1.4. Configure Parameters (Params Tab)

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


### 2.1.5. Run the Script

Click **Run!**

Once finished, the script will save its main output:
```
External/<job_name>/BFACTOR_PLOT_estimated.txt
External/<job_name>/BFACTOR_PLOT_rosenthal-henderson-plot.pdf
```

Additionally, these other two files will be saved in case the user wants to proceed with the breakpoint analysis:
```
External/<job_name>/BFACTOR_PLOT_bfactor_data.yaml
External/<job_name>/BFACTOR_PLOT_particles_resolution.csv
```

## 2.2. Running from the Terminal
You can also run the script directly from the terminal using the following command:

```bash
python3 path/to/bfactor_plot.py -o path/to/output -i3d path/to/Refine3D/jobXXX/ -ipp path/to/PostProcess/jobYYY/ --minimum_nr_particles 225 --maximum_nr_particles 7200 -p path_parameter.yaml
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

## 2.3. About this Script

This script is an improved version of the `bfactor_plot.py` from the RELION project ([GitHub Link](https://github.com/3dem/relion/blob/master/scripts/bfactor_plot.py)). The core functionality for computing the **B-factor** has **not** been changed, but has been slightly refactored. The improvements focus mainly on input handling and script compatibility. 

### Changes from the original script:
- Added support for **YAML files** instead of raw `.py` for parameter input (mpi parameters).
- Replaced `sys.argv` with **argparse** for better argument handling.
- Added functionality for setting the **output_node.star** file.
- Improved handling of **matplotlib** and **numpy** imports.
- Replaced **np.int** (deprecated) with **int** for compatibility.
- Fixed the issue with outputting `\u00C5` for **Å** (angstrom symbol).
- Resolved **matplotlib UserWarning** regarding setting tick labels before setting ticks on `ax2` and `ax3`.
- Improved default parameter loading from **Refine3D** and **PostProcess** `job.star` files, when the YAML file is not provided, the mpi parameters are the same as in `job.star`.

# 3. Breakpoint Analysis
(beta) We included an additional breakpoint analysis. This script analyzes the **Rosenthal–Henderson plot** curve to suggest how many low-particle data points to remove. The goal is to find a **breakpoint** where the B-factor fit becomes more linear and reliable. This minimum number of particles can then be used to divide the particle stack.

### 3.1 Running
To run this script, you must first run [`bfactor_plot.py`](./bfactor_plot.py), which generates the required input files.

Then:

```bash
python3 path/to/bfactor_breakpoint.py -i path/to/data/directory/ -v
```
- `-o`: (input directory): The path to the directory containing the output files from `bfactor_plot.py`. Do not pass individual file paths or rename the .csv and .yaml files as this script expects the default filenames.
- `-v`: (verbose): Enables verbose output. If omitted, the script will display only warnings and errors.

**Note:**  This script requires **at least 3 data points** from the B-factor Rosenthal plot to run.
However, for meaningful analysis, please provide around 10 or more data points.

This script will return the suggested minimum number of particles.

### 3.2 Output Files
This script creates a folder named `breakpoint_analysis/<timestamp>` and saves all analysis plots and summary files in that directory.

- **`breakpoint_plot.pdf`**  
  Shows the MSE curve as a function of the number of data points removed.  
  Markers indicate suggested breakpoints from different analysis methods.

- **`breakpoint_rh_remove_<N>.pdf`**  
  Visualizes the B-factor plot after removing `N` data points from the beginning (i.e., low particle counts).

- **`breakpoint.csv`**  
  Summarizes the suggested minimum number of particles according to each method.

### 3.3 Breakpoint Detection Methods

All methods try to detect the leftmost (low-particle count) data points that deviate from the linear trend expected in a Rosenthal–Henderson plot. These are generally **greedy heuristics**, designed to split the curve into two regions: a less reliable region and a more linear region.

- **Inflection on data**  you added a i.e., also give me a ie for
  Finds the peak in the second derivative of `log(#particles)` (i.e., the point where the data starts bending more sharply.)

- **Inflection on $\sigma^2$**  
  Finds the peak in the second derivative of the **unbiased variance estimate** ($\sigma^2$). 

- **Max Error Change**  
  Finds the maximum increase in MSE (mean squared error) on the curve.

- **Max Relative Error Change**  
  Finds for the maximum relative increase in MSE between consecutive steps.

- **Max Relative Gradient Change**  
  Finds the maximum relative change in the **gradient** of the MSE curve.

> **Default method:** The script uses **"Inflection on data"** to suggest the default minimum number of particles. For the other methods, you can check **`breakpoint.csv`**. 

In an automated pipeline, one can run:

```PYTHON
run_breakpoint_analysis(input_directory=..., method="Inflection on data")
```
Where method can be "Inflection on data", "Inflection on sigma2", "Max Relative Error Change", "Max Relative Gradient Change".

# 4. Requirements

- Python 3.8 or higher
- numpy
- pandas
- matplotlib
- pyyaml

---


 





