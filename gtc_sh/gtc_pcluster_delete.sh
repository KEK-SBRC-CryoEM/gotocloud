#!/bin/sh
#
# Usage:
# $1 : IAM User Name. e.g. kek-gtc00
# $2 : AWS Parallel Cluster ID. Recommended to use date of cryo-EM session or sample name. e.g. protein210719
# $3 : AWS Parallel Cluster Instance ID. e.g. 01
# 
# Example
# ./gtc_pcluster_delete.sh dev-moriya01 ~/environment/key-pcluster-dev-moriya01.pem

GTC_IAM_USER_NAME=$1
GTC_CLUSTER_ID=$2
GTC_INSATANCE_ID=$3

echo "GoToCloud: GTC_IAM_USER_NAME=${GTC_IAM_USER_NAME}"
echo "GoToCloud: GTC_CLUSTER_ID=${GTC_CLUSTER_ID}"
echo "GoToCloud: GTC_INSATANCE_ID=${GTC_INSATANCE_ID}"

GTC_CLUSTER_NAME=`/efs/em/gtc_utility_generate_pcluster_name.sh ${GTC_IAM_USER_NAME} ${GTC_CLUSTER_ID}`
GTC_INSTANCE_NAME="${GTC_CLUSTER_NAME}-${GTC_INSATANCE_ID}"

echo "GoToCloud: GTC_CLUSTER_NAME=${GTC_CLUSTER_NAME}"
echo "GoToCloud: GTC_INSTANCE_NAME=${GTC_INSTANCE_NAME}"

# GTC_CMD="/efs/em/gtc_export_fsx.sh"
GTC_STATUS_CHECK_INTERVAL=60 # in seconds
GTC_TIME_OUT=1800 # in seconds

# echo "GoToCloud: GTC_CMD=${GTC_CMD}"
echo "GoToCloud: GTC_STATUS_CHECK_INTERVAL=${GTC_STATUS_CHECK_INTERVAL}"
echo "GoToCloud: GTC_TIME_OUT=${GTC_TIME_OUT}"

pcluster status -nw ${GTC_INSTANCE_NAME} ||  {
        echo "GoToCloud: The cluster ${GTC_INSTANCE_NAME} does not exist."
        exit 1
}

# echo "GoToCloud: Exporting files in the Lustre file system to S3 ..."
# pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} ${GTC_CMD}
# echo "GoToCloud: Exporting files is completed."

echo "GoToCloud: Deleting ${GTC_INSTANCE_NAME} cluster instance..."
pcluster delete ${GTC_INSTANCE_NAME}

t0=`date +%s` # in seconds
while :
do
        stat=`pcluster status -nw ${GTC_INSTANCE_NAME}`
        exit_status=$?
        echo "GoToCloud: ${stat}"
        if [[ $exit_status ]]; then
                echo "GoToCloud: Deletion of ${GTC_INSTANCE_NAME} cluster instance is completed."
                break
        elif [[ ${stat} =~ .*DELETE_FAILED.* ]]; then
                echo "GoToCloud: Deletion of ${GTC_INSTANCE_NAME} cluster instance is failed."
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

