#!/bin/sh
#
# Usage:
# $1 : AWS ParallelCluster Instance ID. e.g. 00
# 
# Example:
# /efs/em/gtc_sh_ver00/gtc_pcluster_delete.sh 00
# 
# Note 2010/07/20: Comment from AWS Miyamoto-san
# "lfs hsm_archive" command just queues an request of exporting and returns immediately
# Therefore, the actuall processing will run on backgroud.
# To make sure of the completion of the process, 
# it is necessary to check the exporting status using "lfs hsm_action"

GTC_INSATANCE_ID=$1
echo "GoToCloud [DEBUG]: GTC_INSATANCE_ID=${GTC_INSATANCE_ID}"

GTC_SH_DIR="/efs/em/gtc_sh_ver00/"
echo "GoToCloud [DEBUG]: GTC_SH_DIR=${GTC_SH_DIR}"

GTC_PCLUSTER_NAME=`${GTC_SH_DIR}gtc_utility_generate_pcluster_name.sh`
GTC_KEY_PAIR_DIR=${HOME}/environment/
GTC_KEY_FILE_PATH=${GTC_KEY_PAIR_DIR}${GTC_PCLUSTER_NAME}.pem
GTC_INSTANCE_NAME=${GTC_PCLUSTER_NAME}-${GTC_INSATANCE_ID}
echo "GoToCloud [DEBUG]: GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"
echo "GoToCloud [DEBUG]: GTC_KEY_PAIR_DIR=${GTC_KEY_PAIR_DIR}"
echo "GoToCloud [DEBUG]: GTC_KEY_FILE_PATH=${GTC_KEY_FILE_PATH}"
echo "GoToCloud [DEBUG]: GTC_INSTANCE_NAME=${GTC_INSTANCE_NAME}"

echo "GoToCloud: Making sure that pcluster instance ${GTC_INSTANCE_NAME} is still running..."
pcluster status -nw ${GTC_INSTANCE_NAME} ||  {
        echo "GoToCloud: GCT_ERROR! Pcluster instance ${GTC_INSTANCE_NAME} does not exist already!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
}
echo "GoToCloud: OK! pcluster instance ${GTC_INSTANCE_NAME} is still running."

GTC_STATUS_CHECK_INTERVAL=10 # in seconds
GTC_TIME_OUT=1800 # in seconds
echo "GoToCloud [DEBUG]: GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"
echo "GoToCloud [DEBUG]: GTC_TIME_OUT=${GTC_TIME_OUT}"

GTC_CMD_INITIATE="nohup find /fsx -type f -print0 | xargs -0 -n 1 sudo lfs hsm_archive &"
GTC_CMD_STATUS="find /fsx -type f -print0 | xargs -0 -n 1 -P 8 sudo lfs hsm_action | grep 'ARCHIVE' | wc -l"
echo "GoToCloud [DEBUG]: GTC_CMD_STATUS=${GTC_CMD_STATUS}"
echo "GoToCloud [DEBUG]: GTC_CMD_INITIATE=${GTC_CMD_INITIATE}"

echo "GoToCloud: Exporting (archiving) data from Lustre to S3 bucket..."
# Request to export data from Lustre parallel file system (/fsx) to S3 bucket
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} -oStrictHostKeyChecking=no ${GTC_CMD_INITIATE}
# GCT_EXIT_STATUS=`pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} -oStrictHostKeyChecking=no ${GTC_CMD_STATUS}`
# echo "GoToCloud: ${GCT_EXIT_STATUS}"

t0=`date +%s` # in seconds
while :
do
        # Check if exporting (archiving) is completed.
        # It is done when output becomes "0", 
        GCT_EXIT_STATUS=`pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} -oStrictHostKeyChecking=no ${GTC_CMD_STATUS}`
        echo "GoToCloud: ${GCT_EXIT_STATUS}"
        if [[ ${GCT_EXIT_STATUS} == 0 ]]; then
                echo "GoToCloud: Exporting (archiving) is completed."
                break
        fi
        
        sleep ${GTC_STATUS_CHECK_INTERVAL} 
        t1=`date +%s` # in seconds
        if [ $((t1-t0)) -gt ${GTC_TIME_OUT} ]; then
                echo "GoToCloud: GCT_ERROR! GTC_TIME_OUT ${GTC_TIME_OUT} seconds"
                echo "GoToCloud: Last output of pcluster status command:"
                echo "GoToCloud: ${GCT_EXIT_STATUS}"
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi
done

GTC_STATUS_CHECK_INTERVAL=60 # in seconds
GTC_TIME_OUT=1800 # in seconds
echo "GoToCloud [DEBUG]: GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"
echo "GoToCloud [DEBUG]: GTC_TIME_OUT=${GTC_TIME_OUT}"

echo "GoToCloud: Deleting pcluster instance ${GTC_INSTANCE_NAME}..."
pcluster delete ${GTC_INSTANCE_NAME}

t0=`date +%s` # in seconds
while :
do
        # Check if deletion of pcluster instace is completed.
        # It is done when pcluster status command returns error value (Non-zero value) with exit status.
        GCT_EXIT_STATUS=`pcluster status -nw ${GTC_INSTANCE_NAME}`
        exit_status=$?
        echo "GoToCloud: ${GCT_EXIT_STATUS}"
        if [[ $exit_status ]]; then
                echo "GoToCloud: Deletion of pcluster instance ${GTC_INSTANCE_NAME} is completed."
                break
        elif [[ ${GCT_EXIT_STATUS} =~ .*DELETE_FAILED.* ]]; then
                echo "GoToCloud: GCT_ERROR! Deletion of pcluster instance ${GTC_INSTANCE_NAME} failed."
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi

        sleep ${GTC_STATUS_CHECK_INTERVAL} 
        t1=`date +%s` # in seconds
        if [ $((t1-t0)) -gt ${GTC_TIME_OUT} ]; then
                echo "GoToCloud: GCT_ERROR! GTC_TIME_OUT ${GTC_TIME_OUT} seconds"
                echo "GoToCloud: Last output of pcluster status command:"
                echo "GoToCloud: ${GCT_EXIT_STATUS}"
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi
done

echo "GoToCloud: Done"
# echo "GoToCloud [DEBUG]: END OF SCRIPT (debug_gtc_pcluster_delete.sh)"


