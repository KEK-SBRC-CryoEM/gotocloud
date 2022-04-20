#!/bin/bash
#
# Usage:
#   gtc_pcluster_delete.sh  [-i INSTANCE_ID]
#   
# Arguments & Options:
#   -i INSTANCE_ID     : AWS Parallel Cluster Instance ID. e.g. "-i 00". (default NONE)
#   
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_pcluster_delete.sh 
#   $ gtc_pcluster_delete.sh -i 00
#   
<< DEVELOPER_NOTES
[*] 2010/07/20: Comment from AWS Miyamoto-san
"lfs hsm_archive" command just queues an request of exporting and returns immediately
Therefore, the actuall processing will run on backgroud.
To make sure of the completion of the process, 
it is necessary to check the exporting status using "lfs hsm_action"

DEVELOPER_NOTES
#
<< DEBUG_COMMANDS
[Instance without ID]
export GTC_SYSTEM_DEBUG_MODE=1
pcluster list
pcluster status kek-moriya-protein210720
gtc_pcluster_delete.sh
pcluster status kek-moriya-protein210720
pcluster list

[Instance with ID "00"]
export GTC_SYSTEM_DEBUG_MODE=1
pcluster list
pcluster status kek-moriya-protein210720-00
gtc_pcluster_delete.sh -i 00
pcluster status kek-moriya-protein210720-00
pcluster list

[Instance with ID "01"]
export GTC_SYSTEM_DEBUG_MODE=1
pcluster list
pcluster status kek-moriya-protein210720-01
gtc_pcluster_delete.sh -i 01
pcluster status kek-moriya-protein210720-01
pcluster list

DEBUG_COMMANDS
#
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_pcluster_delete.sh"; fi
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
echo "GoToCloud: Deleting pcluster instance with following parameters..."
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

echo "GoToCloud: Making sure that pcluster instance ${GTC_INSTANCE_NAME} is still running..."
#pcluster status -nw ${GTC_INSTANCE_NAME} ||  {
pcluster describe-cluster --cluster-name ${GTC_INSTANCE_NAME} --region ap-northeast-1 > /dev/null || {
        echo "GoToCloud: [GCT_ERROR] Pcluster instance ${GTC_INSTANCE_NAME} does not exist already!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
}
echo "GoToCloud: OK! pcluster instance ${GTC_INSTANCE_NAME} is still running."

# << GTC_DEBUG_COMMENTOUTS
# Set key pair related variables
GTC_KEY_FILE=$(gtc_utility_get_key_file)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_FILE=${GTC_KEY_FILE}"; fi

GTC_STATUS_CHECK_INTERVAL=10 # in seconds
GTC_TIME_OUT=1800 # in seconds
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TIME_OUT=${GTC_TIME_OUT}"; fi

GTC_CMD_INITIATE="nohup find /fsx -type f -print0 | xargs -0 -n 1 sudo lfs hsm_archive &"
GTC_CMD_STATUS="find /fsx -type f -print0 | xargs -0 -n 1 -P 8 sudo lfs hsm_action | grep 'ARCHIVE' | wc -l"
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CMD_INITIATE=${GTC_CMD_INITIATE}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CMD_STATUS=${GTC_CMD_STATUS}"; fi

echo "GoToCloud: Exporting (archiving) data from Lustre to S3 bucket..."
# Request to export data from Lustre parallel file system (/fsx) to S3 bucket
pcluster ssh --cluster-name ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no "${GTC_CMD_INITIATE}"
# pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no ${GTC_CMD_INITIATE}
# GCT_EXIT_STATUS=`pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no ${GTC_CMD_STATUS}`
# echo "GoToCloud: ${GCT_EXIT_STATUS}"

t0=`date +%s` # in seconds
while :
do
        # Check if exporting (archiving) is completed.
        # It is done when output becomes "0", 
        GCT_EXIT_STATUS=`pcluster ssh --cluster-name ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no "${GTC_CMD_STATUS}"`
        echo "GoToCloud: ${GCT_EXIT_STATUS}"
        if [ ${GCT_EXIT_STATUS} -eq 0 ]; then
                echo "GoToCloud: Exporting (archiving) is completed."
                break
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
GTC_STATUS_CHECK_INTERVAL=60 # in seconds
GTC_TIME_OUT=1800 # in seconds
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TIME_OUT=${GTC_TIME_OUT}"; fi

echo "GoToCloud: Deleting pcluster instance ${GTC_INSTANCE_NAME}..."
pcluster delete-cluster --cluster-name ${GTC_INSTANCE_NAME} --region ap-northeast-1
# pcluster delete --keep-logs ${GTC_INSTANCE_NAME}

t0=`date +%s` # in seconds
while :
do
        # Check if deletion of pcluster instace is completed.
        # It is done when pcluster status command returns error value (Non-zero value) with exit status.
        GCT_EXIT_STATUS=`pcluster describe-cluster --cluster-name ${GTC_INSTANCE_NAME} --region ap-northeast-1 | jq -r '.clusterStatus'`
        # exit_status=$?
        echo "GoToCloud: ${GCT_EXIT_STATUS}"
        if [[ ${GCT_EXIT_STATUS} =~ .*null.* ]]; then
                echo "GoToCloud: Deletion of pcluster instance ${GTC_INSTANCE_NAME} is completed."
                break
        elif [[ ${GCT_EXIT_STATUS} =~ .*DELETE_FAILED.* ]]; then
                echo "GoToCloud: [GCT_ERROR] Deletion of pcluster instance ${GTC_INSTANCE_NAME} failed."
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

echo "GoToCloud: Done"

if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] "; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_pcluster_delete.sh!"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi


