#!/bin/bash
#
# ***************************************************************************
#
# Copyright (c) 2021-2024 Structural Biology Research Center, 
#                         Institute of Materials Structure Science, 
#                         High Energy Accelerator Research Organization (KEK)
#
#
# Authors:   Toshio Moriya (toshio.moriya@kek.jp)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307  USA
#
# ***************************************************************************
#
# Usage:
#   gtf_relion4_run_cryolo_system.sh --in_mics RELION_MIC_STAR_FILE_RPATH  -o RELION_JOB_DIR_RPATH [-cryolo_repo CRYOLO_REPO_DIR_FPATH] [--threshold CRYOLO_CONFIDENCE_THRESHOLD] [--device GPU_DEVICE] [--denoise] [--j THREADS]
#   
# Arguments & Options:
# -i, --input, --in_mics    : RELION requirement! Input micrographs star file Path (relative)
# -o, --output,             : RELION requirement! Output job directory path (relative)
# -r, --cryolo_repo         : crYOLO script directory path (full).
# -t, --threshold           : Particle selection threshold.
# -g, --device              : GPU devide. To use multiple device, use camma like relion (e.g. 0,1,2,3)
# -n, --denoise,            : Use JANNI denoising instead of low-pass filtering (default False)
# -j, --j, --threads        : Number of threads (Input from RELION. Not used here).

#   
# Example:
#   $ gtf_relion4_run_cryolo_system.sh --in_mics CtfFind/job123/micrographs_ctf.star --o External/job143/ --cryolo_repo /gpfs/data/EM/software/crYOLO --threshold 0.3 --device 0 -denoise
#   
# Debug Script:
#   [NONE]
# 
# Developer Notes:
#   2021/01/07 Currently supports only the defult crYOLO module
# 
# Create: 2021/10/31 Toshio Moriya (KEK, SBRC)
# Modified: 2022/01/07 Toshio Moriya (KEK, SBRC)
#   - Renamed from gtf_relion4_run_cryolo_kek.sh to gtf_relion4_run_cryolo_system.sh
#     to support system enviroment also 
#   - Added option to choose low-pass filter or JANNI denoise versions
#   - Repository Path
#     PF-GPFS       : /gpfs/data/EM/software/crYOLO
#     AWS-GoToCloud : /efs/em/crYOLO -> Currently /efs/em/crYOLO (2022/01/07)
# 

<< DEBUG_NOTES
DEBUG_NOTES
# 

GTF_DEBUG_MODE=0

usage_exit() {
        echo "GoToFly(JK): Usage $0 -in_mics RELION_MIC_STAR_FILE_RPATH  -o RELION_JOB_DIR_RPATH [-cryolo_repo CRYOLO_REPO_DIR_FPATH] [--threshold CRYOLO_CONFIDENCE_THRESHOLD] [--device GPU_DEVICE] [--denoise] [--j THREADS]" 1>&2
        echo "GoToFly(JK): Exiting(1)..."
        exit 1
}

if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] --------------------------------------------------"; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] Hello gtf_relion4_run_cryolo_system.sh"; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] --------------------------------------------------"; fi

if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] Command line arguments = $@"; fi

# Get crYOLO repository full path from command line
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTF_DEBUG] 0 = $0"; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTF_DEBUG] dirname $0 = $(dirname $0)"; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTF_DEBUG] pwd = $(pwd)"; fi
GTF_CRYOLO_REPO_DIR_FPATH=`cd $(dirname ${0}) && pwd`
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTF_DEBUG] GTF_CRYOLO_REPO_DIR_FPATH=${GTF_CRYOLO_REPO_DIR_FPATH}"; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTF_DEBUG] pwd = $(pwd)"; fi

echo "GoToFly(JK): "
echo "GoToFly(JK): Changing module setting defined by system enviroment to run crYOLO..."
echo "GoToFly(JK): "

# module list does not use standard output but error output!
GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
echo "GoToFly(JK): ${GTF_MODULE_LIST}"
echo "GoToFly(JK): "
echo "GoToFly(JK): >>> Unloading unnecessary modules..."
GTF_TOPAZ_MODULE="topaz"
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] GTF_TOPAZ_MODULE=${GTF_TOPAZ_MODULE}"; fi
GTF_WAS_TOPAZ_MODULE_LOADED=0
if [[ ${GTF_MODULE_LIST} =~ .*${GTF_TOPAZ_MODULE}.* ]]; then
	echo "GoToFly(JK):     ${GTF_TOPAZ_MODULE} module has been loaded!"
	echo "GoToFly(JK):     Unloading ${GTF_TOPAZ_MODULE} module..."
	GTF_WAS_TOPAZ_MODULE_LOADED=1
	module unload ${GTF_TOPAZ_MODULE}; wait
	# GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
	# echo "GoToFly(JK): ${GTF_MODULE_LIST}"
else
	echo "GoToFly(JK):     ${GTF_TOPAZ_MODULE} module has not been loaded!"
	GTF_WAS_TOPAZ_MODULE_LOADED=0
fi

echo "GoToFly(JK): "
echo "GoToFly(JK): >>> Loading necessary modules..."
GTF_CRYOLO_MODULE="crYOLO"
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] GTF_CRYOLO_MODULE=${GTF_CRYOLO_MODULE}"; fi
GTF_WAS_CRYOLO_MODULE_LOADED=0
if [[ ${GTF_MODULE_LIST} =~ .*${GTF_CRYOLO_MODULE}.* ]]; then
		echo "GoToFly(JK):     ${GTF_CRYOLO_MODULE} module has been loaded!"
	GTF_WAS_CRYOLO_MODULE_LOADED=1
else
	echo "GoToFly(JK):     ${GTF_CRYOLO_MODULE} module has not been loaded!"
	echo "GoToFly(JK):     Loading ${GTF_CRYOLO_MODULE} module..."
	GTF_WAS_CRYOLO_MODULE_LOADED=0
	module load ${GTF_CRYOLO_MODULE}; wait
	# GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
	# echo "GoToFly(JK): ${GTF_MODULE_LIST}"
fi

echo "GoToFly(JK): "
GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
echo "GoToFly(JK): ${GTF_MODULE_LIST}"

echo "GoToFly(JK): "
echo "GoToFly(JK): Runing crYOLO (gtf_relion4_run_cryolo.py)...."

### GCT_CMD_CRYOLO="/gpfs/data/EM/software/crYOLO/gtf_relion4_run_cryolo.py $@"
GCT_CMD_CRYOLO="${GTF_CRYOLO_REPO_DIR_FPATH}/gtf_relion4_run_cryolo.py $@"

if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] GCT_CMD_CRYOLO=python ${GCT_CMD_CRYOLO}"; fi
python ${GCT_CMD_CRYOLO} $@
wait

echo "GoToFly(JK): "
echo "GoToFly(JK): Restoring module setting defined by system enviroment..."

# GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
# echo "GoToFly(JK): ${GTF_MODULE_LIST}"

echo "GoToFly(JK): "
echo "GoToFly(JK): >>> Unloading back necessary modules..."
if [[ ${GTF_WAS_CRYOLO_MODULE_LOADED} == 0 ]]; then 
	echo "GoToFly(JK):     Unloading back ${GTF_CRYOLO_MODULE} module..."
	module unload ${GTF_CRYOLO_MODULE}
	# GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
	# echo "GoToFly(JK): ${GTF_MODULE_LIST}"
fi

echo "GoToFly(JK): "
echo "GoToFly(JK): >>> Loading back unnecessary modules..."
if [[ ${GTF_WAS_TOPAZ_MODULE_LOADED} != 0 ]]; then 
	echo "GoToFly(JK):     Loading back ${GTF_TOPAZ_MODULE} module..."
	module load ${GTF_TOPAZ_MODULE}
	# GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
	# echo "GoToFly(JK): ${GTF_MODULE_LIST}"
fi

echo "GoToFly(JK): "
GTF_MODULE_LIST=`module list 2>&1 >/dev/null`; wait
echo "GoToFly(JK): ${GTF_MODULE_LIST}"

echo "GoToFly(JK): "
echo "GoToFly(JK): Done"

if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] "; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] --------------------------------------------------"; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] Good-bye gtf_relion4_run_cryolo_system.sh!"; fi
if [[ ${GTF_DEBUG_MODE} != 0 ]]; then echo "GoToFly(JK): [GTF_DEBUG] --------------------------------------------------"; fi
