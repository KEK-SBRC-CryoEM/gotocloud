# DeepMASC Installation and Test Guide

This guide explains how to install **DeepMASC** on a remote server and perform a test run on your RELION dataset.

> **Note:** After installation and a testrun, it is strongly recommended to consult the documentation in the [official repository](https://github.com/AntiMatter568/DeepMASC) before running on your full dataset.

> **Important:** Read all commands before executing, as they may need path and parameter adjustments.

---

## Preparation

We assume you already have:

* Unix system modules
* RELION
* Chimera
* Conda installed

[//]: <> (> Click here if you don't have them installed.)

We will use:

* Installation path: `/home/apps/`
* DeepMASC data path: `/home/data/deepmasc/`

Create the data folder:

```bash
mkdir -p /home/data/deepmasc/
```

---

## Download Repository

Repository URL: [https://github.com/AntiMatter568/DeepMASC/](https://github.com/AntiMatter568/DeepMASC/)

```bash
cd /home/apps/
git clone https://github.com/AntiMatter568/DeepMASC/
```

---

## Conda Environment
Conda should already be installed:

```bash
cd /home/apps/DeepMASC
conda env create -f environment.yml
```

Make a note of the environment path for the next step:

```bash
conda info --envs
```

You should see output similar to:

```
DeepMASC        /home/user/anaconda3/envs/DeepMASC
```

## System Module

Create a modulefile for DeepMASC:

```bash
mkdir -p /home/apps/modulefiles/deepmasc
cd /home/apps/modulefiles/deepmasc

cat > 1.0
```

Paste the following content, do not forget to modify the line `set CONDA_ENV ` based on the path from the last step.

```bash
#%Module1.0 
## Minimal DeepMASC modulefile

module-whatis "DeepMASC - Deep Learning for cryo-EM map selection and contouring"

# Absolute path to your DeepMASC installation folder (root of repo)
set DEEPMASC_ROOT /home/apps/DeepMASC
# Absolute path to the conda environment used by DeepMASC
set CONDA_ENV /home/user/anaconda3/envs/DeepMASC
# -------------------

# Provide help
proc ModulesHelp { } {
    puts stderr "\tDeepMASC - Deep Learning for Map Selection and Contouring"
    puts stderr "\n\tStandalone Commands:"
    puts stderr "\t  deepmasc                    - Main AutoSelect3D tool"
    puts stderr "\t  deepmasc-contour            - AutoContour mask generation tool"
    puts stderr "\n\tRELION Integration Commands:"
    puts stderr "\t  deepmasc-relion-select      - AutoSelect3D for RELION GUI"
    puts stderr "\t  deepmasc-relion-contour     - AutoContour for RELION GUI"
    puts stderr "\t  deepmasc-relion-eval-mask   - Eval Refinement Mask for RELION GUI"
    puts stderr "\n\tProject directory: $DEEPMASC_ROOT"
}

# Add wrapper scripts to PATH
prepend-path PATH $DEEPMASC_ROOT/module/bin

# Environment variables DeepMASC expects
setenv DEEPMASC_ROOT $DEEPMASC_ROOT
setenv DEEPMASC_CONDA_ENV $CONDA_ENV
setenv DEEPMASC_PYTHON $CONDA_ENV/bin/python
setenv PYTHONNOUSERSITE 1

# Messages on load/unload
if { [module-info mode load] } {
    puts stderr "DeepMASC loaded"
    puts stderr "Standalone: deepmasc, deepmasc-contour"
    puts stderr "RELION: deepmasc-relion-select, deepmasc-relion-contour, deepmasc-relion-eval-mask"
    puts stderr "Using conda environment: $CONDA_ENV"
}
if { [module-info mode remove] } {
    puts stderr "DeepMASC unloaded"
}
```

Save and exit.

---

## Example Run

> **Important:** On HPC, do not run intensive command line tasks on the login node. Use an interactive GPU session:

```bash
srun -p gpu --gres=gpu:1 --pty bash
```

---

### Select Class 3D

#### Command Line

```bash
module load deepmasc
nohup deepmasc -f <RELION project path>/Class3D/jobXXX/run_itNNN_class*.mrc -g 0 -o /home/data/deepmasc/testrun_select3d > /home/data/deepmasc/testrun_select3d.log 2>&1 &
```

#### RELION External

Load modules:

```bash
module load deepmasc
module load relion
```

* **MAIN TAB**
  * External Executable: `deepmasc-relion-select`
  * Input particles: `Class3D/jobNNN/run_itMMM_data.star`
* **PARAMETERS TAB**
  * gpus: 0
  * batch: 4
* **RUNNING TAB**
  * Thread: 1
  * Sub: your RELION GPU submission script

Full parameter list:
[AutoSelect3D README](https://github.com/AntiMatter568/DeepMASC/blob/main/README_AutoSelect3D.md)

---

### AutoContour using GMM

#### Command Line

```bash
module load deepmasc
nohup deepmasc-contour -i <RELION project path>/PostProcess/jobXXX/postprocess.mrc -o /home/data/deepmasc/testrun_autocontour_gmm -g 0 -p > /home/data/deepmasc/testrun_autocontour_gmm.log 2>&1 &
```

#### RELION External

* Load modules:

```bash
module load deepmasc
module load relion
```

* **MAIN TAB**
  * External Executable: `deepmasc-relion-contour`
  * Input 3D reference: `PostProcess/jobNNN/postprocess.mrc`
* **PARAMETERS TAB**
  * plot_all: True
* **RUNNING TAB**
  * Thread: 1
  * Sub: your RELION GPU submission script

Full parameter list:
[AutoContour README](https://github.com/AntiMatter568/DeepMASC/blob/main/README_AutoContour.md)

---

### AutoContour using cryoRead

#### Command Line

```bash
module load deepmasc
nohup deepmasc-contour -i <RELION project path>/PostProcess/jobNNN/postprocess.mrc -o /home/data/deepmasc/testrun_autocontour_cryoread -g 0 -p -r -b 4 > /home/data/deepmasc/testrun_autocontour_cryoread.log 2>&1 &
```

#### RELION External

* Load modules:

```bash
module load deepmasc
module load relion
```

* **MAIN TAB**
  * External Executable: `deepmasc-relion-contour`
  * Input 3D reference: `PostProcess/jobNNN/postprocess.mrc`
* **PARAMETERS TAB**
  * gpus: 0,1
  * plot_all: True
  * refinement_mask: True
  * batch_size: 8
* **RUNNING TAB**
  * Thread: 1
  * Sub: your RELION GPU submission script

Full parameter list:
[AutoContour README](https://github.com/AntiMatter568/DeepMASC/blob/main/README_AutoContour.md)

---

## Useful Commands

Check your Slurm jobs:

```bash
squeue -u $USER
```

Check job details:

```bash
scontrol show job <job_id>
```

Cancel a job:

```bash
scancel <job_id>
```
