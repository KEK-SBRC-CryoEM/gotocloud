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
#   gtc_pcluster_dcv_connect.sh  [-i INSTANCE_ID]
#   
# Arguments & Options:
#   -i INSTANCE_ID     : AWS Parallel Cluster Instance ID. e.g. "-i 00". (default NONE)
#   
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_pcluster_dcv_connect.sh
#   $ gtc_pcluster_dcv_connect.sh -i 00
#   
<< DEBUG_COMMANDS
[Instance without ID]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_pcluster_dcv_connect.sh
=> Connect on web browser
=> Do [Check List B]
=> Disconnect on web browser

[Instance with ID "00"]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_pcluster_dcv_connect.sh -i 00
=> Connect on web browser
=> Do [Check List B]
=> Disconnect on web browser

[Instance with ID "01"]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_pcluster_dcv_connect.sh -i 01
=> Connect on web browser
=> Do [Check List B]
=> Disconnect on web browser

[Check List B]
cd /fsx
relion
chimera
chimerax
=> Disconnect

DEBUG_COMMANDS
#

# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_pcluster_dcv_connect.sh"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

usage_exit() {
        echo "GoToCloud: Usage $0 [-i INSTANCE_ID]" 1>&2
        echo "GoToCloud: Exiting(1)..."
        exit 1
}

# Check if the number of command line arguments is valid
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] @=$@"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] #=$#"; fi
if [[ $# -gt 2 ]]; then
    echo "GoToCloud: Invalid number of arguments ($#)"
    usage_exit
fi

# Initialize variables with default values
GTC_INSATANCE_ID="GTC_INVALID"

# Parse command line arguments
while getopts i:h OPT
do
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] OPT=$OPT"; fi
    case "$OPT" in
        i)  GTC_INSATANCE_ID=$OPTARG
            echo "GoToCloud: AWS Parallel Cluster Instance ID '${GTC_INSATANCE_ID}' is specified"
            ;;
        h)  usage_exit
            ;;
        \?) echo "GoToCloud: [GTC_ERROR] Invalid option $OPTARG is specified!"
            usage_exit
            ;;
    esac
done
echo "GoToCloud: Connecting pcluster instance through NiceDCV with following parameters..."
echo "GoToCloud:   AWS Parallel Cluster Instance ID     : ${GTC_INSATANCE_ID}"

GTC_INSATANCE_SUFFIX=""
if [[ "${GTC_INSATANCE_ID}" != "GTC_INVALID" ]]; then
    GTC_INSATANCE_SUFFIX=-${GTC_INSATANCE_ID}
fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_INSATANCE_SUFFIX=${GTC_INSATANCE_SUFFIX}"; fi

# Load gtc_utility_global_varaibles shell functions
source gtc_utility_global_varaibles.sh
# . gtc_utility_global_varaibles.sh
# Get related global variables
GTC_PCLUSTER_NAME=$(gtc_utility_get_pcluster_name)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"; fi

# Set instance name related variables
GTC_INSTANCE_NAME=${GTC_PCLUSTER_NAME}${GTC_INSATANCE_SUFFIX}
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_INSTANCE_NAME=${GTC_INSTANCE_NAME}"; fi

# Set key pair related variables
GTC_KEY_FILE=$(gtc_utility_get_key_file)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_FILE=${GTC_KEY_FILE}"; fi

echo "GoToCloud: Connecting to pcluster instance ${GTC_INSTANCE_NAME} through NiceDCV..."
pcluster dcv-connect --cluster-name ${GTC_INSTANCE_NAME} --key-path ${GTC_KEY_FILE}
#pcluster dcv connect ${GTC_INSTANCE_NAME} -k ${GTC_KEY_FILE}

# echo "GoToCloud: Done"

# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] "; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_pcluster_dcv_connect.sh!"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

