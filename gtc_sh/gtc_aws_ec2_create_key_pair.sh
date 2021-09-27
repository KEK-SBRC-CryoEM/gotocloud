#!/bin/bash
#
# Usage:
# $1 : IAM User Name. e.g. kek-gtc00
# $2 : AWS Parallel Cluster ID. Recommended to use date of cryo-EM session or sample name. e.g. protein210719
# 
# Example:
# $ ./gtc_aws_ec2_create_key_pair.sh kek-gtc00 protein210719
# 
# Debug Commands:
# 
# $ ls -lrta ~/.ssh/
# $ ls -l ~/.ssh/kek-gtc00-protein210719.pem
# $ 
# $ ./gtc_aws_ec2_create_key_pair.sh kek-gtc00 protein210719
# $ ls -l ~/.ssh/kek-gtc00-protein210719.pem
# $ 
# $ aws ec2 describe-key-pairs --key-name kek-gtc00-protein210719
# $ 
# $ aws ec2 delete-key-pair --key-name kek-gtc00-protein210719
# $ rm ~/.ssh/kek-gtc00-protein210719.pem
# $ 

GTC_IAM_USER_NAME=$1
GTC_CLUSTER_ID=$2

# echo "GoToCloud(DEBUG): GTC_IAM_USER_NAME=${GTC_IAM_USER_NAME}"
# echo "GoToCloud(DEBUG): GTC_CLUSTER_ID=${GTC_CLUSTER_ID}"

# GTC_KEY_PAIR_DIR="${HOME}/.ssh/"
GTC_KEY_PAIR_DIR="${HOME}/environment/"
mkdir -p ${GTC_KEY_PAIR_DIR}

# GTC_CLUSTER_NAME=`./gtc_utility_generate_pcluster_name.sh ${GTC_IAM_USER_NAME} ${GTC_CLUSTER_ID}`
GTC_CLUSTER_NAME=`/efs/em/gtc_utility_generate_pcluster_name.sh ${GTC_IAM_USER_NAME} ${GTC_CLUSTER_ID}`

echo "GoToCloud: Generating key-pair for ${GTC_CLUSTER_NAME} cluster..."
aws ec2 create-key-pair --key-name ${GTC_CLUSTER_NAME} --region ap-northeast-1 --query 'KeyMaterial' --output text > ${GTC_KEY_PAIR_DIR}${GTC_CLUSTER_NAME}.pem
chmod 600 ${GTC_KEY_PAIR_DIR}${GTC_CLUSTER_NAME}.pem

echo "GoToCloud: Saved key-pair file as ${GTC_KEY_PAIR_DIR}${GTC_CLUSTER_NAME}.pem"
echo "GoToCloud: Done"
