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
# Debug script for gtc_setup_cloud9_environment.sh
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS
# [*] IMPORTANT! Do this ONLY-ONCE before starting debugging!
cat ~/.bashrc
cp ~/.bashrc ~/.bashrc_debug_backup
cat ~/.bashrc_debug_backup
### # Do this only if necessary
### cp ~/.bashrc_debug_backup ~/.bashrc

echo $PATH
PATH_DEBUG_BACKUP=$PATH
echo $PATH_DEBUG_BACKUP
### # Do this only if necessary
### PATH=$PATH_DEBUG_BACKUP

# [*] Run debug script
export GTC_SYSTEM_DEBUG_MODE=1
/efs/em/gtc_sh_ver00/gtc_setup_cloud9_environment_debug.sh

# Check activate GoToCloud sytemwise environment variables
source ~/.gtc/global_variables.sh

# Check current values of GoToCloud sytemwise environment variables from global scope
echo "GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"

DEBUG_COMMANDS
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if [ ! -z $GTC_SYSTEM_DEBUG_MODE ]; then 
    echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE IS SET ALREADY!"
    echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
else 
    echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE IS NOT SET YET!"
fi

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Preparation"
echo "GoToCloud: ========================================================================="

GTC_TAIL_N=6

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Store original .bashrc file"
echo "GoToCloud: -------------------------------------------------------------------------"

GTC_BASHRC=${HOME}/.bashrc
echo "GoToCloud: Check contents of ${GTC_BASHRC}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

GTC_BASHRC_DEBUG_ORIGINAL=${HOME}/.bashrc_debug_original
if [ -e ${GTC_BASHRC_DEBUG_ORIGINAL} ]; then
    echo "GoToCloud: [GTC_ERROR] Logically ${GTC_BASHRC_DEBUG_ORIGINAL} should not exists!"
    echo "GoToCloud: Delete ${GTC_BASHRC_DEBUG_ORIGINAL} and re-run this script."
    echo "GoToCloud: Exiting(1)..."
    exit 1
else
    echo "GoToCloud: Making copy of original ${GTC_BASHRC} as ${GTC_BASHRC_DEBUG_ORIGINAL}..."
    cp ${GTC_BASHRC} ${GTC_BASHRC_DEBUG_ORIGINAL}
fi

echo "GoToCloud: Check contents of ${GTC_BASHRC_DEBUG_ORIGINAL}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Store original PATH setting"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: Making a backup of original PATH as PATH_DEBUG_BACKUP..."
PATH_DEBUG_ORIGINAL=${PATH}

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Store original values of GoToCloud enverinment varaibles"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check contents of PATH_DEBUG_ORIGINAL..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: Check original values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: Storing original values of GoToCloud sytemwise environment variables..."
GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_SH_DIR}
GTC_SYSTEM_IAM_USEAR_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_IAM_USEAR_NAME}
GTC_SYSTEM_METHOD_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_METHOD_NAME}
GTC_SYSTEM_PROJECT_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_PROJECT_NAME}
GTC_SYSTEM_PCLUSTER_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_PCLUSTER_NAME}
GTC_SYSTEM_S3_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_S3_NAME}
GTC_SYSTEM_KEY_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_NAME}
GTC_SYSTEM_KEY_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_DIR}
GTC_SYSTEM_KEY_FILE_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_FILE}
GTC_SYSTEM_APPLICATION_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_APPLICATION_DIR}
GTC_SYSTEM_GLOBAL_VARIABLES_FILE_DEBUG_ORIGNAL=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}
GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL=${GTC_SYSTEM_DEBUG_MODE}

echo "GoToCloud: Check stored values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_IAM_USEAR_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_METHOD_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_PROJECT_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_PCLUSTER_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_S3_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_FILE_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_APPLICATION_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE_DEBUG_ORIGNAL=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL=${GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL}"
echo "GoToCloud: "

echo "GoToCloud: Unsetting GoToCloud sytemwise environment variables..."
unset GTC_SYSTEM_SH_DIR
unset GTC_SYSTEM_IAM_USEAR_NAME
unset GTC_SYSTEM_METHOD_NAME
unset GTC_SYSTEM_PROJECT_NAME
unset GTC_SYSTEM_PCLUSTER_NAME
unset GTC_SYSTEM_S3_NAME
unset GTC_SYSTEM_KEY_NAME
unset GTC_SYSTEM_KEY_DIR
unset GTC_SYSTEM_KEY_FILE
unset GTC_SYSTEM_APPLICATION_DIR
unset GTC_SYSTEM_GLOBAL_VARIABLES_FILE
# unset GTC_SYSTEM_DEBUG_MODE  # Exclue this for debugging
echo "GoToCloud: "

echo "GoToCloud: Check usetted values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Run the target script"
echo "GoToCloud: ========================================================================="

# Obtaine GoToCloud shell script directory path from this command line
# Target script file must be in the same directory!
GTC_SH_DIR=`cd $(dirname $0) && pwd`
echo "GoToCloud: GTC_SH_DIR=${GTC_SH_DIR}"
echo "GoToCloud: "

# Call gtc_utility_class_cloud9_tags_get_values
echo "GoToCloud: Running ${GTC_SH_DIR}/gtc_setup_cloud9_environment.sh..."
echo "GoToCloud: "
${GTC_SH_DIR}/gtc_setup_cloud9_environment.sh
echo "GoToCloud: "
echo "GoToCloud: Returned from ${GTC_SH_DIR}/gtc_setup_cloud9_environment.sh"
echo "GoToCloud: "

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Check results"
echo "GoToCloud: ========================================================================="

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check envrinment variable settings and thier activeation by source"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Values of GoToCloud sytemwise environment variables right after running script"
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "
echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

GTC_APPLICATION_DIR=${HOME}/.gtc
echo "GoToCloud: GTC_APPLICATION_DIR=${GTC_APPLICATION_DIR}"
GTC_GLOBAL_VARIABLES_FILE=${GTC_APPLICATION_DIR}/global_variables.sh
echo "GoToCloud: GTC_GLOBAL_VARIABLES_FILE=${GTC_GLOBAL_VARIABLES_FILE}"

echo "GoToCloud: "
echo "GoToCloud: Activating GoToCloud sytemwise environment variables..."
echo "GoToCloud: source ${GTC_GLOBAL_VARIABLES_FILE}"
source ${GTC_GLOBAL_VARIABLES_FILE}

echo "GoToCloud: "
echo "GoToCloud: Values of GoToCloud sytemwise environment variables right after activation"
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check PATH setting"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: which gtc_setup_cloud9_environment.sh"
which gtc_setup_cloud9_environment.sh
echo "GoToCloud: "
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check .bashrc file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_BASHRC}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check gtc global varaible file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_GLOBAL_VARIABLES_FILE}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cat ${GTC_GLOBAL_VARIABLES_FILE}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "
echo "GoToCloud: ls -al ${GTC_GLOBAL_VARIABLES_FILE}"
ls -al ${GTC_GLOBAL_VARIABLES_FILE}

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Restore original settings"
echo "GoToCloud: ========================================================================="

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Restore original values of GoToCloud enverinment varaibles"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check stored original values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_IAM_USEAR_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_METHOD_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_PROJECT_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_PCLUSTER_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_S3_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_NAME_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE_DEBUG_ORIGNAL=${GTC_SYSTEM_KEY_FILE_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_APPLICATION_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE_DEBUG_ORIGNAL=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL=${GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL}"
echo "GoToCloud: "

echo "GoToCloud: Restoring original values of GoToCloud sytemwise environment variables from stored values..."
GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL}
GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME_DEBUG_ORIGNAL}
GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME_DEBUG_ORIGNAL}
GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME_DEBUG_ORIGNAL}
GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME_DEBUG_ORIGNAL}
GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME_DEBUG_ORIGNAL}
GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME_DEBUG_ORIGNAL}
GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR_DEBUG_ORIGNAL}
GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE_DEBUG_ORIGNAL}
GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR_DEBUG_ORIGNAL}
GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE_DEBUG_ORIGNAL}
GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL}

echo "GoToCloud: Check values of GoToCloud sytemwise environment variables after restration..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Restore original PATH setting"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check contents of PATH_DEBUG_ORIGINAL..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: Restore original PATH from PATH_DEBUG_BACKUP..."
PATH=${PATH_DEBUG_ORIGINAL}

echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Restore original .bashrc file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_BASHRC_DEBUG_ORIGINAL}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: Restore contents of original ${GTC_BASHRC} from ${GTC_BASHRC_DEBUG_ORIGINAL}..."
mv ${GTC_BASHRC_DEBUG_ORIGINAL} ${GTC_BASHRC}

echo "GoToCloud: Check contents of ${GTC_BASHRC}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Done"
echo "GoToCloud: ========================================================================="
