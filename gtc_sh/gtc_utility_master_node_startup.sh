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
#            Misato Yamamoto (misatoy@post.kek.jp)
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
#   gtc_utility_master_node_startup.sh [-d]
#   
# Arguments & Options:
#   -d                 : Run with GoToCloud debug mode
#   
#   -h                 : Help option displays usage
#   
# Example:
#   $ /efs/em/gtc_sh_ver00/gtc_utility_master_node_startup.sh -d
#   
# Debug Script:
#   gtc_utility_master_node_startup_debug.sh
#  
usage_exit() {
        echo "GoToCloud: Usage $0 [-d]" 1>&2
        echo "GoToCloud: Exiting(1)..."
        exit 1
}

# Check if the number of command line arguments is valid
if [[ $# -gt 1 ]]; then
    echo "GoToCloud: Invalid number of arguments ($#)"
    usage_exit
fi

# Initialize variables with default values
GTC_DEBUG_MODE=0   # 0 (off) by default

# Parse command line arguments
while getopts dh OPT
do
    case "$OPT" in
        d)  echo "GoToCloud: GoToCloud debug mode is specified"
            GTC_DEBUG_MODE=1
            ;;
        h)  usage_exit
            ;;
        \?) echo "GoToCloud: [GTC_ERROR] Invalid option $OPTARG is specified!"
            usage_exit
            ;;
    esac
done

if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_DEBUG_MODE=${GTC_DEBUG_MODE}"; fi

if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_utility_master_node_startup.sh"; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

# GoToCloud shell script direcctory path
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] 0 = $0"; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] dirname $0 = $(dirname $0)"; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] pwd = $(pwd)"; fi
GTC_SH_DIR=`cd $(dirname $(readlink -f ${0})) && pwd`
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SH_DIR=${GTC_SH_DIR}"; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] pwd = $(pwd)"; fi

echo "GoToCloud: Installing basic denpendency for RELION ..."
sudo apt update -y
sudo apt update
#sudo apt install -y cmake git build-essential mpi-default-bin mpi-default-dev libfftw3-dev libtiff-dev
sudo apt install -y cmake git build-essential mpi-default-bin mpi-default-dev libfftw3-dev libtiff-dev libpng-dev ghostscript libxft-dev

echo "GoToCloud: Installing basic denpendency for Schemes in Relion ..."
#sudo apt-get install tk-dev
sudo apt-get --yes install python-tk
sudo apt-get --yes install python3-tk

echo "GoToCloud: Installing basic denpendency for Follow_Relion_gracefully ..."
sudo apt-get --yes --force-yes install python3-venv

echo "GoToCloud: Installing chimerax ..."
sudo apt-get --yes --force-yes install /efs/em/ucsf-chimerax_1.3ubuntu20.04_amd64.deb

echo "GoToCloud: Changing owners of directories and files in fsx (Lustre) ..."
sudo chown -R ubuntu:ubuntu /fsx

# --------------------
# Set GoToCloud application directory path on pcluster head node
GTC_APPLICATION_DIR=${HOME}/.gtc
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_APPLICATION_DIR=${GTC_APPLICATION_DIR}"; fi
if [ -e ${GTC_APPLICATION_DIR} ]; then
    echo "GoToCloud: ${GTC_APPLICATION_DIR} exists already!"
    GTC_APPLICATION_DIR_BACKUP=${GTC_APPLICATION_DIR}_backup_`date "+%Y%m%d_%H%M%S"`
    if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_APPLICATION_DIR_BACKUP=${GTC_APPLICATION_DIR_BACKUP}"; fi
    echo "GoToCloud: Making a backup of previous GoToCloud application ${GTC_APPLICATION_DIR} as ${GTC_APPLICATION_DIR_BACKUP}..."
    mv ${GTC_APPLICATION_DIR} ${GTC_APPLICATION_DIR_BACKUP}
fi
echo "GoToCloud: Creating GoToCloud application directory ${GTC_APPLICATION_DIR}..."
mkdir -p ${GTC_APPLICATION_DIR}

# --------------------
# Set file path of GoToCloud environment settings file for pcluster head node as a systemwise environment constant
GTC_GLOBAL_VARIABLES_FILE=${GTC_APPLICATION_DIR}/global_variables.sh
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_GLOBAL_VARIABLES_FILE=${GTC_GLOBAL_VARIABLES_FILE}"; fi
if [ -e ${GTC_GLOBAL_VARIABLES_FILE} ]; then
    echo "GoToCloud: [GTC_ERROR] Locally ${GTC_GLOBAL_VARIABLES_FILE} should not exist!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

# --------------------
# Store all to GoToCloud environment settings file
echo "GoToCloud: Creating pcluster head node system environment variable settings for GoToCloud global variables as ${GTC_GLOBAL_VARIABLES_FILE}..."
# cat > ${GTC_GLOBAL_VARIABLES_FILE} <<'EOS' suppresses varaible replacements 
# cat > ${GTC_GLOBAL_VARIABLES_FILE} <<EOS allows varaible replacements 
cat > ${GTC_GLOBAL_VARIABLES_FILE} <<'EOS'
#!/bin/sh

# GoToCloud system environment variables
export GTC_SYSTEM_SH_DIR=XXX_GTC_SH_DIR_XXX
export GTC_SYSTEM_DEBUG_MODE=XXX_GTC_DEBUG_MODE_XXX
export RDMAV_FORK_SAFE=1
export FI_EFA_FORK_SAFE=1

# To be causious, put new path at the end
export PATH=$PATH:${GTC_SYSTEM_SH_DIR}
EOS

# Replace variable strings in template to actual values
# XXX_GTC_SH_DIR_XXX -> ${GTC_SH_DIR}
sed -i "s@XXX_GTC_SH_DIR_XXX@${GTC_SH_DIR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
# XXX_GTC_DEBUG_MODE_XXX -> ${GTC_DEBUG_MODE}
sed -i "s@XXX_GTC_DEBUG_MODE_XXX@${GTC_DEBUG_MODE}@g" ${GTC_GLOBAL_VARIABLES_FILE}

# Set file permission 
chmod 775 ${GTC_GLOBAL_VARIABLES_FILE}

# echo "GoToCloud: Activating pcluster head node system environment variable settings for GoToCloud global variables defined in ${GTC_GLOBAL_VARIABLES_FILE}..."
# echo "GoToCloud: Note that this activation is effective only for caller of this script file."
# source ${GTC_GLOBAL_VARIABLES_FILE}
# #. ${GTC_GLOBAL_VARIABLES_FILE}

# --------------------
# Set file path of RELION environment settings file for pcluster head node as a systemwise environment constant
GTC_RELION_SETTINGS_FILE=${GTC_APPLICATION_DIR}/relion_settings.sh
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_RELION_SETTINGS_FILE=${GTC_RELION_SETTINGS_FILE}"; fi
if [ -e ${GTC_RELION_SETTINGS_FILE} ]; then
    echo "GoToCloud: [GTC_ERROR] Locally ${GTC_RELION_SETTINGS_FILE} should not exist!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

# --------------------
# Store all to RELION environment settings file
echo "GoToCloud: Creating pcluster head node system environment variable settings for RELION as ${GTC_RELION_SETTINGS_FILE}..."
# cat > ${GTC_RELION_SETTINGS_FILE} <<'EOS' suppresses varaible replacements 
# cat > ${GTC_RELION_SETTINGS_FILE} <<EOS allows varaible replacements 
cat > ${GTC_RELION_SETTINGS_FILE} <<'EOS'
#!/bin/sh

# load relion 
source /etc/profile.d/modules.sh
module load relion
module load schemes-editing

# GoToCloud system environment variables
export RELION_QSUB_EXTRA_COUNT=2
export RELION_QSUB_EXTRA1="Partition"
export RELION_QSUB_EXTRA1_DEFAULT=g5-vcpu48-gpu4
export RELION_QSUB_EXTRA1_HELP="Partitions: g5-vcpu192-gpu8, g5-vcpu192-gpu8-spot, g5-vcpu48-gpu4, g5-vcpu48-gpu4-spot, g5-vcpu16-gpu1, g5-vcpu16-gpu1-spot, g4dn-vcpu96-gpu8, g4dn-vcpu96-gpu8-spot, g4dn-vcpu48-gpu4, g4dn-vcpu48-gpu4-spot, g4dn-vcpu8-gpu1, g4dn-vcpu8-gpu1-spot, c6i-vcpu128-gpu0, c6i-vcpu128-gpu0-spot, m6i-vcpu128-gpu0, m6i-vcpu128-gpu0-spot, r6i-vcpu128-gpu0, r6i-vcpu128-gpu0-spot, c7i-vcpu192-gpu0, c7i-vcpu192-gpu0-spot, m7i-vcpu192-gpu0, m7i-vcpu192-gpu0-spot, r7i-vcpu192-gpu0, r7i-vcpu192-gpu0-spot"
export RELION_QSUB_EXTRA2="Number of nodes"
export RELION_QSUB_EXTRA2_DEFAULT=1
EOS

# Set file permission 
chmod 775 ${GTC_RELION_SETTINGS_FILE}

# echo "GoToCloud: Activating pcluster head node system environment variable settings for RELION defined in ${GTC_RELION_SETTINGS_FILE}..."
# echo "GoToCloud: Note that this activation is effective only for caller of this script file."
# source ${GTC_RELION_SETTINGS_FILE}
# #. ${GTC_RELION_SETTINGS_FILE}

# --------------------
# Set file path of UCFS Chimera environment settings file for pcluster head node as a systemwise environment constant
GTC_CHIMERA_SETTINGS_FILE=${GTC_APPLICATION_DIR}/chimera_settings.sh
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_CHIMERA_SETTINGS_FILE=${GTC_CHIMERA_SETTINGS_FILE}"; fi
if [ -e ${GTC_CHIMERA_SETTINGS_FILE} ]; then
    echo "GoToCloud: [GTC_ERROR] Locally ${GTC_CHIMERA_SETTINGS_FILE} should not exist!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

# --------------------
# Store all to UCFS Chimera environment settings file
echo "GoToCloud: Creating pcluster head node system environment variable settings for UCFS Chimera settings as ${GTC_CHIMERA_SETTINGS_FILE}..."
# cat > ${GTC_CHIMERA_SETTINGS_FILE} <<'EOS' suppresses varaible replacements 
# cat > ${GTC_CHIMERA_SETTINGS_FILE} <<EOS allows varaible replacements 
cat > ${GTC_CHIMERA_SETTINGS_FILE} <<'EOS'
#!/bin/sh

# load USFS chimera
source /etc/profile.d/modules.sh
module load chimera
EOS

# Set file permission 
chmod 775 ${GTC_CHIMERA_SETTINGS_FILE}

# echo "GoToCloud: Activating pcluster head node system environment variable settings for UCFS Chimera defined in ${GTC_CHIMERA_SETTINGS_FILE}..."
# echo "GoToCloud: Note that this activation is effective only for caller of this script file."
# source ${GTC_CHIMERA_SETTINGS_FILE}
# #. ${GTC_CHIMERA_SETTINGS_FILE}

# --------------------
echo "GoToCloud: Setting up pcluster head node environment variables for GoToCloud system ..."
GTC_BASHRC=${HOME}/.bashrc
if [ -e ${GTC_BASHRC} ]; then
    GTC_BASHRC_BACKUP=${GTC_APPLICATION_DIR}/.bashrc_backup_`date "+%Y%m%d_%H%M%S"`
    echo "GoToCloud: Making a backup of previous ${GTC_BASHRC} as ${GTC_BASHRC_BACKUP}..."
    cp ${GTC_BASHRC} ${GTC_BASHRC_BACKUP}
else
    echo "GoToCloud: [GTC_WARNING] ${GTC_BASHRC} does not exist on this system. Normally, this should not happen!"
fi

echo "GoToCloud: Appending GoToCloud system environment variable settings to ${GTC_BASHRC}..."
# cat > ${GTC_BASHRC} <<'EOS' suppresses varaible replacements 
# cat > ${GTC_BASHRC} <<EOS allows varaible replacements 
cat >> ${GTC_BASHRC} <<EOS

# ------------------
# GoToCloud settings
# ------------------
# GoToCloud system environment variables
source ${GTC_GLOBAL_VARIABLES_FILE}
# GoToCloud RELION settings variables
source ${GTC_RELION_SETTINGS_FILE}
# GoToCloud UCFS Chimera settings variables
source ${GTC_CHIMERA_SETTINGS_FILE}
EOS

echo "GoToCloud: "
echo "GoToCloud: To applying GoToCloud system environment settings, open a new terminal. "
echo "GoToCloud: OR use the following commands in this session:"
echo "GoToCloud: "
echo "GoToCloud:   source ${GTC_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud:   source ${GTC_RELION_SETTINGS_FILE}"
echo "GoToCloud:   source ${GTC_CHIMERA_SETTINGS_FILE}"
echo "GoToCloud: "
echo "GoToCloud: Done"

if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] "; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_utility_master_node_startup.sh!"; fi
if [[ ${GTC_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

