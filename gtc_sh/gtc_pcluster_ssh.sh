#!/bin/bash
#
# Usage:
#   gtc_pcluster_ssh.sh  [-i INSTANCE_ID]
#   
# Arguments & Options:
#   -i INSTANCE_ID     : AWS Parallel Cluster Instance ID. e.g. "-i 00". (default NONE)
#   
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_pcluster_ssh.sh 
#   $ gtc_pcluster_ssh.sh -i 00
#   
<< DEBUG_COMMANDS
[Instance without ID]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_pcluster_ssh.sh
=> Do [Check List A]

[Instance with ID "00"]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_pcluster_ssh.sh -i 00
=> Do [Check List A]

[Instance with ID "01"]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_pcluster_ssh.sh -i 01
=> Do [Check List A]

[Check List A]
cat ~/.bashrc
ls -al ~/.gtc
cat ~/.gtc/global_variables.sh
cat ~/.gtc/relion_settings.sh
cat ~/.gtc/chimera_settings.sh
echo ${GTC_SYSTEM_SH_DIR}
echo ${GTC_SYSTEM_DEBUG_MODE}
echo ${PATH}
which relion
which chimera
which chimerax
exit

DEBUG_COMMANDS
#

# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_pcluster_ssh.sh"; fi
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
echo "GoToCloud: Connecting pcluster instance through SSH with following parameters..."
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

echo "GoToCloud: Connecting to pcluster instance ${GTC_INSTANCE_NAME} through SSH..."
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE}
# pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no

# echo "GoToCloud: Done"

# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] "; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_pcluster_ssh.sh!"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

