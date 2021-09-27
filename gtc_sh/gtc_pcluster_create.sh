#!/bin/sh
#
# Usage:
# $1 : AWS Parallel Cluster Instance ID. e.g. 00
# 
# Example:
# /efs/em/gtc_sh_ver00/gtc_pcluster_create.sh 00
# 
# Debug:
# pcluster ssh kek-moriya-protein210720-00  -i ~/environment/kek-moriya-protein210720.pem
# 
# pcluster dcv connect kek-moriya-protein210720-00  -k ~/environment/kek-moriya-protein210720.pem
# 
# pcluster delete kek-moriya-protein210720-00 

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

echo "GoToCloud: Making sure that pcluster instance ${GTC_INSTANCE_NAME} is not running..."
pcluster status -nw ${GTC_INSTANCE_NAME} &&  {
        echo "GoToCloud: GCT_ERROR! Pcluster instance ${GTC_INSTANCE_NAME} is aleady running!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
}
echo "GoToCloud: OK! Pcluster instance ${GTC_INSTANCE_NAME} is not running yet!"

GTC_CONFIG_INSTANCE=${HOME}/.parallelcluster/config_${GTC_INSATANCE_ID}
echo "GoToCloud [DEBUG]: GTC_CONFIG_INSTANCE=${GTC_CONFIG_INSTANCE}"

if [ ! -e ${GTC_CONFIG_INSTANCE} ]; then
        echo "GoToCloud: GCT_ERROR! Config ${GTC_CONFIG_INSTANCE} is not found..."
        echo "GoToCloud: Please use a correct instance ID instead of ${GTC_INSATANCE_ID}"
        echo "GoToCloud: Exiting(1)..."
        exit 1
fi

GTC_STATUS_CHECK_INTERVAL=60 # in seconds
GTC_TIME_OUT=1800 # in seconds
echo "GoToCloud [DEBUG]: GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"
echo "GoToCloud [DEBUG]: GTC_TIME_OUT=${GTC_TIME_OUT}"

echo "GoToCloud: Creating pcluster instance ${GTC_INSTANCE_NAME}..."
pcluster create ${GTC_INSTANCE_NAME} --config ${GTC_CONFIG_INSTANCE} -nw

t0=`date +%s` # in seconds
while :
do
        # Check if creation of pcluster instace is completed.
        # It is done when pcluster status command outputs "CREATE_COMPLETE".
        GCT_EXIT_STATUS=`pcluster status -nw ${GTC_INSTANCE_NAME}`
        echo "GoToCloud: ${GCT_EXIT_STATUS}"
        if [[ ${GCT_EXIT_STATUS} =~ .*CREATE_COMPLETE.* ]]; then
                echo "GoToCloud: Creation of pcluster instance ${GTC_INSTANCE_NAME} is completed."
                break
        elif [[ ${GCT_EXIT_STATUS} =~ .*ROLLBACK.* ]]; then
                echo "GoToCloud: GCT_ERROR! Creation of pcluster instance ${GTC_INSTANCE_NAME} failed."
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

GTC_CMD="${GTC_SH_DIR}gtc_utility_master_node_startup.sh"
echo "GoToCloud [DEBUG]: GTC_CMD=${GTC_CMD}"

echo "GoToCloud: Executing head-node startup script..."
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} -oStrictHostKeyChecking=no ${GTC_CMD}

echo "GoToCloud: Done"
# echo "GoToCloud [DEBUG]: END OF SCRIPT (gtc_pcluster_create.sh)"
