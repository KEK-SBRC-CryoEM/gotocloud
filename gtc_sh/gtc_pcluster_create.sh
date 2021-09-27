#!/bin/sh
#
# Usage:
# $1 : IAM User Name. e.g. kek-gtc00
# $2 : AWS Parallel Cluster ID. Recommended to use date of cryo-EM session or sample name. e.g. protein210719
# $3 : AWS Parallel Cluster Instance ID. e.g. 01
# $4 : FSX (Lustre) strage capacity in MByte. e.g. 1200 or 2400 (meaning 1.2TByte or 2.4TByte)
# 
# Example:
# ./gtc_pcluster_create.sh kek-gtc00 protein210719 01 1200
# 

GTC_IAM_USER_NAME=$1
GTC_CLUSTER_ID=$2
GTC_INSATANCE_ID=$3
GTC_FSX_MB_CAPACITY=$4

echo "GoToCloud: GTC_IAM_USER_NAME=${GTC_IAM_USER_NAME}"
echo "GoToCloud: GTC_CLUSTER_ID=${GTC_CLUSTER_ID}"
echo "GoToCloud: GTC_INSATANCE_ID=${GTC_INSATANCE_ID}"
echo "GoToCloud: GTC_FSX_MB_CAPACITY=${GTC_FSX_MB_CAPACITY}"

GTC_CLUSTER_NAME=`/efs/em/gtc_utility_generate_pcluster_name.sh ${GTC_IAM_USER_NAME} ${GTC_CLUSTER_ID}`
GTC_KEY_PAIR_DIR="${HOME}/environment/"
GTC_KEY_FILE_PATH="${GTC_KEY_PAIR_DIR}${GTC_CLUSTER_NAME}.pem"
GTC_INSTANCE_NAME="${GTC_CLUSTER_NAME}-${GTC_INSATANCE_ID}"

echo "GoToCloud: GTC_CLUSTER_NAME=${GTC_CLUSTER_NAME}"
echo "GoToCloud: GTC_KEY_PAIR_DIR=${GTC_KEY_PAIR_DIR}"
echo "GoToCloud: GTC_KEY_FILE_PATH=${GTC_KEY_FILE_PATH}"
echo "GoToCloud: GTC_INSTANCE_NAME=${GTC_INSTANCE_NAME}"

GTC_CONFIG_TEMPORARY="${HOME}/.parallelcluster/config_temporary"
GTC_CMD="/efs/em/gtc_utility_master_node_startup.sh"
GTC_STATUS_CHECK_INTERVAL=60 # in seconds
GTC_TIME_OUT=1800 # in seconds

echo "GoToCloud: GTC_CONFIG_TEMPORARY=${GTC_CONFIG_TEMPORARY}"
echo "GoToCloud: GTC_CMD=${GTC_CMD}"
echo "GoToCloud: GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"
echo "GoToCloud: GTC_TIME_OUT=${GTC_TIME_OUT}"

echo "GoToCloud: Checking if ${GTC_INSTANCE_NAME} cluster instance is running..."
pcluster status -nw ${GTC_INSTANCE_NAME} &&  {
        echo "GoToCloud: ${GTC_INSTANCE_NAME} cluster instance aleady exists."
        echo "GoToCloud: Please delete the cluster first."
        exit 1
}
echo "GoToCloud: ${GTC_INSTANCE_NAME} cluster instance is not running yet."

echo "GoToCloud: Editing temporary config...."
# Set XXX_GTC_FSX_MB_CAPACITY_XXX -> ${GTC_FSX_MB_CAPACITY}
sed -i "s/XXX_GTC_FSX_MB_CAPACITY_XXX/${GTC_FSX_MB_CAPACITY}/g" ${GTC_CONFIG_TEMPORARY}

echo "GoToCloud: Creating ${GTC_INSTANCE_NAME} cluster instance..."
pcluster create -nw ${GTC_INSTANCE_NAME}

t0=`date +%s` # in seconds
while :
do
        stat=`pcluster status -nw ${GTC_INSTANCE_NAME}`
        echo "GoToCloud: ${stat}"
        if [[ ${stat} =~ .*CREATE_COMPLETE.* ]]; then
                echo "GoToCloud: Creation of ${GTC_INSTANCE_NAME} cluster instance is completed."
                break
        elif [[ ${stat} =~ .*ROLLBACK.* ]]; then
                echo "GoToCloud: Creation of ${GTC_INSTANCE_NAME} cluster instance is failed."
                exit 1
        fi

        sleep ${GTC_STATUS_CHECK_INTERVAL} 
        t1=`date +%s` # in seconds
        if [ $((t1-t0)) -gt ${GTC_TIME_OUT} ]; then
                echo "GoToCloud: GTC_TIME_OUT"
                echo "GoToCloud: Last output of pcluster status command:"
                echo "GoToCloud: ${stat}"
                exit 1
        fi
done

echo "GoToCloud: Executing start-up script..."
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} -oStrictHostKeyChecking=no ${GTC_CMD}
echo "GoToCloud: Done"
