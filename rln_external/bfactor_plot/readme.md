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

### 2. Copy the Script to Your RELION Project

Next, copy the **bfactor_plot** directory into your RELION project directory:

```bash
cp -r gotocloud/rln_external/bfactor_plot ./path/to/relion/project/
```

Replace `./path/to/relion/project` with the actual path to your RELION project directory.

### 3. Add permission to run the script
```bash
 chmod +x bfactor_plot/bfactor_plot.py
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

### 3. Load the Initial Settings File

- On the top toolbar, go to **Load** → **Load job.star**
- Choose the file: [`bfactor_plot/config/job.star`](config/job.star)

This file loads default settings required to run the script.

### 4. Set Parameters in the External Job

In the **Params** section of the External job, the user must provide the following:

#### **Required Parameters**
- `input_refine3d_job`: Path to the input Refine3D job
- `input_postprocess_job`: Path to the input PostProcess job
- `minimum_nr_particles`: Minimum number of particles
- `maximum_nr_particles`: Maximum number of particles

#### **Optional: `mpi_parameters.yaml`**
This is used to provide machine-specific parameters (e.g.: MPI settings). You can leave it **empty** in most cases.

By default, the script will automatically use the same parameter values from the input **Refine3D** or **PostProcess** jobs.

However, if you'd like to **manually define these parameters**, you can:

1. Edit the [`bfactor_plot/config/mpi_parameters.yaml`](config/mpi_parameters.yaml) file.
2. In the "Params" tab, set the **path** to this file in the `mpi_parameters` input field:
   - Param label: `mpi_parameters`  
   - Param input: `<path/to/config/mpi_parameters.yaml>`


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
- `-p`: (Optional) Provide a path to the parameter YAML file. This can be omitted if you don't need to manually set machine-specific parameters (as explained above).

**Note:** The `-p` flag (for the parameter file) can be omitted if you don't need to specify custom settings. The script will automatically use values from the input **Refine3D** or **PostProcess** jobs.

## About the Script

This script is an improved version of the `bfactor_plot.py` from the RELION project ([GitHub Link](https://github.com/3dem/relion/blob/master/scripts/bfactor_plot.py)). The core functionality for computing the **B-factor** has **not** been changed or refactored. The improvements focus mainly on input handling and script compatibility.

### Changes from the original script:
- Added support for **YAML files** instead of raw `.py` for parameter input (mpi parameters).

- Replaced `sys.argv` with **argparse** for better argument handling.
- Added functionality for setting the **output_node.star** file.
- Improved handling of **matplotlib** and **numpy** imports.
- Replaced **np.int** (deprecated) with **int** for compatibility.
- Fixed the issue with outputting `\u00C5` for **Å** (angstrom symbol).
- Resolved **matplotlib UserWarning** regarding setting tick labels before setting ticks on `ax2` and `ax3`.
- Improved default parameter loading from **Refine3D** and **PostProcess** `job.star` files, when the YAML file is not provided, the mpi parameters are the same as in `job.star`.

