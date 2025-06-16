# Overview

This folder includes scripts for theoretical contrast transfer function (CTF) analysis:

- **[`ctf.py`](./ctf.py)**: contains core CTF functions, including calculation of the CTF aliasing limit and the 1D/2D phase shift CTF.

- **[`boxsize_analysis.py`](./boxsize_analysis.py)**: Provides two analysis modes:  
  a. **opt**: Calculates the optimal box size for a given set of microscope parameters.  
  b. **plot**: Generates plots to visualize the optimal boxsize across a range of parameter values.


# Table of Contents
1. [Installation](#1-installation)
2. [CTF](#2-ctf)  
3. [Boxsize Analysis](#2-boxsize-analysis)  

# 1. Installation

Follow these steps to install and set up the script in your working directory:

## 1.1. Clone the GitHub Repository

First, clone the GitHub repository to your local machine:

```bash
git clone -b add_ctf_analysis https://github.com/KEK-SBRC-CryoEM/gotocloud.git
```

## 1.2. Add permission to run the script
```bash
 chmod +x gotocloud/analysis/ctf_analysis/ctf.py
 chmod +x gotocloud/analysis/ctf_analysis/boxsize_analysis.py
 ```

### 1.3. Module Environment

These scripts depend on the following Python packages: `yaml`, `numpy`, and `matplotlib`.

For internal users, these dependencies are included in the `schemes-editing` module. To load the environment, run:

```
module load schemes-editing
```

### 1.4. Change working directory
```bash
 cd gotocloud/analysis/ctf_analysis
 ```

# 2. CTF

This script provides functions to:

- Compute the **CTF aliasing limit** (i.e., where aliasing occurs in Fourier space).
- Calculate the **CTF period** (local spacing between zero crossings).
- Generate **1D and 2D phase shift CTF** curves.

When executed as a script (`python ctf.py`), it estimates the spatial frequency (resolution) at which aliasing occurs in the CTF, based on electron microscope parameters.

## Usage

```bash
python ctf.py -b 480 -p 1.2 -v 300 -d 1.5 -c 2.7 -q
```

## Required Arguments

- `-b`, `--boxsize`           : Box size in pixels.
- `-p`, `--pixel_size`        : Pixel size in Ångström.
- `-v`, `--voltage`           : Accelerating voltage in kilovolts (kV).
- `-d`, `--defocus`           : Defocus value in micrometers (µm).
- `-c`, `--cs`                : Spherical aberration constant (Cs) in millimeters (mm).

## Optional Arguments

- `--limit_resolution`, `-limres` : Estimate CTF only up to this resolution (default: 15 Å).
- `--quiet`, `-q`                  : Suppress verbose output.

## Output
A tuple:
- `fourier_pixel_index` (int): Index in Fourier space where aliasing occurs.
- `spatial_frequency` (float): Spatial frequency at the aliasing point in Å⁻¹.

## Phase Shift CTF Equation

The phase shift CTF is computed using the following equation:

$PhCTF(f) = sin(\frac{2\pi}{\lambda}[\frac{-C_s \lambda ^4 f^4}{4} + \frac{\Delta F \lambda ^2 f^2}{2}])$

Where:

- `PhCTF(f)` is the phase shift CTF at spatial frequency `f` [Å⁻¹]
- `λ` is the relativistic electron wavelength [Å]
- `Cs` is the spherical aberration constant [Å]
- `ΔF` is the defocus value [Å]

This formula is obtained from:
- [1] van Heel, M. (2009). Principles of phase contrast (electron) microscopy. Imperial College London, Department of Biological Sciences.
- [2] Glaeser, R. M., Nogales, E., & Chiu, W. (2021). Single-particle Cryo-EM of biological macromolecules. IOP publishing.

# 3. Boxsize Analysis
This script helps in choosing the optimal boxsize for the particle picking by analyzing the theoretical CTF based on microscope parameters. This script has two options detailed below.

### 3.1 OPT Mode
This mode computes the optimal boxsize for a single microscope setup.

#### Usage
```bash
python boxsize_analysis.py -q opt -p 1.2 -v 300 -d -0.8 -c 2.7
```

This mode outputs a tuple:

- The **first value** is the theoretical resolution limit [Å] at which aliasing begins.
- The **second value** is the **minimum box size** (in pixels) required to reach that resolution without aliasing.

#### Required Parameters:
- `-p`, `--pixel_size`: Pixel size of the microscope detector, in Ångstroms [Å].
- `-v`, `--voltage`: Accelerating voltage of the microscope, in kilovolts [kV].
- `-d`, `--defocus`: Defocus value, specified in micrometers [µm].
- `-c`, `--cs`: Spherical aberration constant (Cs), in millimeters [mm].

#### Optional Parameters:
- `-limres`, `--limit_resolution`  
  Limits the CTF estimation up to this resolution value (default: 15 Å).
- `-save`, `--save_plots`  
  If set, the script saves the generated 1D and 2D CTF (Thon Rings) plots as image files and save them in `./boxsize_opt/<timestamp>`.

### 3.2 PLOT Mode
This mode analyzes multiple microscope setups using a parameter file (`.yaml`). Useful for batch analysis across many parameter combinations and studying material.

#### Usage
```bash
python boxsize_analysis.py -q plot -p config/boxsize.yaml 
```

- `-p`, `--param_file`: Path to the YAML parameter file.  
  A sample file is provided at: [`config/boxsize.yaml`](config/boxsize.yaml)

The YAML file accepts the same parameters as in the **OPT** mode.  
However, for **`pixel_size`** and **`defocus`**, you can also provide **lists of values** to evaluate multiple settings in one run.

Advanced users may include additional configuration options. Please refer to the sample file for details.

#### Output Files

This mode produces the following plots and save them in `./boxsize_plot/<timestamp>`:

- **`ctflimit_pixel{value}.pdf`**:  
  A plot of **resolution vs. optimal box size** for various defocus settings.  
  These plots illustrate how resolution improves (approaches the Nyquist limit) as boxsize increases.  
  One plot is generated **per pixel size setting**.

- **`defocus_vs_boxsize.pdf`**:  
  Shows the **optimal box size vs. defocus** for different pixel sizes.  
  Each curve represents a specific pixel size, showing how the required boxsize changes as the focus values changes.


### Optional Flags
Both modes support the following optional flag:
- **`--quiet`, `-q`**:  
  Suppresses verbose output for cleaner logs and minimal console messages.
