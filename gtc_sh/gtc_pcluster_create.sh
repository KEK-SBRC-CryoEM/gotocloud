#!/bin/bash
#
# Usage:
#   gtc_pcluster_create.sh  [-i INSTANCE_ID]
#   
# Arguments & Options:
#   -i INSTANCE_ID     : AWS Parallel Cluster Instance ID. e.g. "-i 00". (default NONE)
#   
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_pcluster_create.sh 
#   $ gtc_pcluster_create.sh -i 00
#   
<< DEBUG_COMMANDS
[Instance without ID]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_config_create.sh 
gtc_pcluster_create.sh 
pcluster list
pcluster status kek-moriya-protein210720
pcluster ssh kek-moriya-protein210720 -i ~/environment/kek-moriya-protein210720.pem
=> Do [Check List A]
pcluster dcv connect kek-moriya-protein210720  -k ~/environment/kek-moriya-protein210720.pem
=> Do [Check List B]
pcluster delete kek-moriya-protein210720

[Instance with ID "00"]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_config_create.sh -i 00
gtc_pcluster_create.sh -i 00
pcluster list
pcluster status kek-moriya-protein210720-00
pcluster ssh kek-moriya-protein210720-00 -i ~/environment/kek-moriya-protein210720.pem
=> Do [Check List A]
pcluster dcv connect kek-moriya-protein210720-00 -k ~/environment/kek-moriya-protein210720.pem
=> Do [Check List B]
pcluster delete kek-moriya-protein210720-00

[Instance with ID "01"]
export GTC_SYSTEM_DEBUG_MODE=1
gtc_config_create.sh -i 01
gtc_pcluster_create.sh -i 01
pcluster list
pcluster status kek-moriya-protein210720-01
pcluster ssh kek-moriya-protein210720-01 -i ~/environment/kek-moriya-protein210720.pem
=> Do [Check List A]
pcluster dcv connect kek-moriya-protein210720-01 -k ~/environment/kek-moriya-protein210720.pem
=> Do [Check List B]
pcluster delete kek-moriya-protein210720-01

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

[Check List B]
cd /fsx
relion
chimera
chimerax
=> Disconnect

DEBUG_COMMANDS
#

if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_pcluster_create.sh"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

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
echo "GoToCloud: Creating pcluster instance with following parameters..."
echo "GoToCloud:   AWS Parallel Cluster Instance ID     : ${GTC_INSATANCE_ID}"

GTC_INSATANCE_SUFFIX=""
if [[ "${GTC_INSATANCE_ID}" != "GTC_INVALID" ]]; then
    GTC_INSATANCE_SUFFIX=-${GTC_INSATANCE_ID}
fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_INSATANCE_SUFFIX=${GTC_INSATANCE_SUFFIX}"; fi


# Load gtc_utility_global_varaibles shell functions
source gtc_utility_global_varaibles.sh
# . gtc_utility_global_varaibles.sh

# Obtaine GoToCloud shell script direcctory path
GTC_SH_DIR=$(gtc_utility_get_sh_dir)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_SH_DIR=${GTC_SH_DIR}"; fi

# Get related global variables
GTC_PCLUSTER_NAME=$(gtc_utility_get_pcluster_name)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"; fi

# Set instance name related variables
GTC_INSTANCE_NAME=${GTC_PCLUSTER_NAME}${GTC_INSATANCE_SUFFIX}
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_INSTANCE_NAME=${GTC_INSTANCE_NAME}"; fi

# Get AWS region 
GTC_AWS_REGION=$(gtc_utility_get_aws_region)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_AWS_REGION=${GTC_AWS_REGION}"; fi

# << GTC_DEBUG_COMMENTOUTS
echo "GoToCloud: Making sure that pcluster instance ${GTC_INSTANCE_NAME} is not running..."
# pcluster status -nw ${GTC_INSTANCE_NAME} &&  { 
pcluster describe-cluster --cluster-name ${GTC_INSTANCE_NAME} --region ${GTC_AWS_REGION} > /dev/null &&  { 
        echo "GoToCloud: [GCT_ERROR] Pcluster instance ${GTC_INSTANCE_NAME} is aleady running!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
}


echo "GoToCloud: OK! Pcluster instance ${GTC_INSTANCE_NAME} is not running yet!"

GTC_CONFIG_INSTANCE=${HOME}/.parallelcluster/config${GTC_INSATANCE_SUFFIX}.yaml
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CONFIG_INSTANCE=${GTC_CONFIG_INSTANCE}"; fi
if [ ! -e ${GTC_CONFIG_INSTANCE} ]; then
        echo "GoToCloud: [GCT_ERROR] Config ${GTC_CONFIG_INSTANCE} is not found..."
        echo "GoToCloud: Make sure instance ID is correct and rerun!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
fi

GTC_STATUS_CHECK_INTERVAL=60 # in seconds
GTC_TIME_OUT=3600 # in seconds
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TIME_OUT=${GTC_TIME_OUT}"; fi

echo "GoToCloud: Creating pcluster instance ${GTC_INSTANCE_NAME}..."
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] pcluster create ${GTC_INSTANCE_NAME} --config ${GTC_CONFIG_INSTANCE} -nw"; fi
pcluster create-cluster --cluster-name ${GTC_INSTANCE_NAME} --cluster-configuration ${GTC_CONFIG_INSTANCE}
# pcluster create ${GTC_INSTANCE_NAME} --config ${GTC_CONFIG_INSTANCE} -nw

t0=`date +%s` # in seconds
while :
do
        # Check if creation of pcluster instace is completed.
        # It is done when pcluster status command outputs "CREATE_COMPLETE".
        # GCT_EXIT_STATUS=`pcluster status -nw ${GTC_INSTANCE_NAME}`
        GCT_EXIT_STATUS=`pcluster describe-cluster --cluster-name ${GTC_INSTANCE_NAME} --region ${GTC_AWS_REGION} | jq -r '.clusterStatus'`
        echo "GoToCloud: ${GCT_EXIT_STATUS}"
        if [[ ${GCT_EXIT_STATUS} =~ .*CREATE_COMPLETE.* ]]; then
                echo "GoToCloud: Creation of pcluster instance ${GTC_INSTANCE_NAME} is completed."
                break
        elif [[ ${GCT_EXIT_STATUS} =~ .*CREATE_FAILED.* ]]; then
                echo "GoToCloud: [GCT_ERROR] Creation of pcluster instance ${GTC_INSTANCE_NAME} failed."
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi

        sleep ${GTC_STATUS_CHECK_INTERVAL} 
        t1=`date +%s` # in seconds
        if [ $((t1-t0)) -gt ${GTC_TIME_OUT} ]; then
                echo "GoToCloud: [GCT_ERROR] GTC_TIME_OUT ${GTC_TIME_OUT} seconds"
                echo "GoToCloud: Last output of pcluster status command:"
                echo "GoToCloud: ${GCT_EXIT_STATUS}"
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi
done
# GTC_DEBUG_COMMENTOUTS

# << GTC_DEBUG_COMMENTOUTS
# Set key pair related variables
GTC_KEY_FILE=$(gtc_utility_get_key_file)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_FILE=${GTC_KEY_FILE}"; fi

# Need GoToCloud shell script direcctory path for this script 
# since this command will be executed in master node!
GTC_CMD="${GTC_SH_DIR}/gtc_utility_master_node_startup.sh"
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then
    GTC_CMD="${GTC_SH_DIR}/gtc_utility_master_node_startup.sh -d"
fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CMD=${GTC_CMD}"; fi

echo "GoToCloud: Executing head-node startup script..."
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no \"${GTC_CMD}\""; fi
pcluster ssh --cluster-name ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no "${GTC_CMD}"
# pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no "${GTC_CMD}"
# GTC_DEBUG_COMMENTOUTS

echo "GoToCloud: Done"

if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] "; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_pcluster_create.sh!"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

