#!/bin/sh
#
# Usage:
# $1 : IAM User Name. e.g. kek-gtc00
# $2 : AWS Parallel Cluster ID. Recommended to use date of cryo-EM session or sample name. e.g. protein210719
# $3 : AWS Parallel Cluster Instance ID. e.g. 01
# 
# Example:
# ./gtc_pcluster_ssh.sh kek-gtc00 protein210719 01
# 

GTC_IAM_USER_NAME=$1
GTC_CLUSTER_ID=$2
GTC_INSATANCE_ID=$3

echo "GoToCloud: GTC_IAM_USER_NAME=${GTC_IAM_USER_NAME}"
echo "GoToCloud: GTC_CLUSTER_ID=${GTC_CLUSTER_ID}"
echo "GoToCloud: GTC_INSATANCE_ID=${GTC_INSATANCE_ID}"

GTC_CLUSTER_NAME=`/efs/em/gtc_utility_generate_pcluster_name.sh ${GTC_IAM_USER_NAME} ${GTC_CLUSTER_ID}`
GTC_KEY_PAIR_DIR="${HOME}/environment/"
GTC_KEY_FILE_PATH="${GTC_KEY_PAIR_DIR}${GTC_CLUSTER_NAME}.pem"
GTC_INSTANCE_NAME="${GTC_CLUSTER_NAME}-${GTC_INSATANCE_ID}"

echo "GoToCloud: GTC_CLUSTER_NAME=${GTC_CLUSTER_NAME}"
echo "GoToCloud: GTC_KEY_PAIR_DIR=${GTC_KEY_PAIR_DIR}"
echo "GoToCloud: GTC_KEY_FILE_PATH=${GTC_KEY_FILE_PATH}"
echo "GoToCloud: GTC_INSTANCE_NAME=${GTC_INSTANCE_NAME}"

echo "GoToCloud: Connecting to ${GTC_INSTANCE_NAME} cluster instance through SSH..."
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH}
# pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} -oStrictHostKeyChecking=no
# echo "GoToCloud: Done"
