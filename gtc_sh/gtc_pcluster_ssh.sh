#!/bin/sh
#
# Usage:
# $1 : AWS Parallel Cluster Instance ID. e.g. 00
# 
# Example:
# /efs/em/gtc_sh_ver00/gtc_pcluster_ssh.sh 00
# 

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

echo "GoToCloud: Connecting to pcluster instance ${GTC_INSTANCE_NAME} through SSH..."
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH}
# pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE_PATH} -oStrictHostKeyChecking=no
# echo "GoToCloud: Done"
