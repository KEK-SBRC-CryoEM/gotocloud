#!/bin/sh
#
# Usage:
# $1 : IAM User Name. e.g. kek-moriya
# $2 : AWS Parallel Cluster ID. Recommended to use date of cryo-EM session or sample name. e.g. protein01
# 
# Example 1
# ./gtc_utility_generate_pcluster_name.sh kek-moriya protein01
# 
# Example 2
# GTC_CLUSTER_NAME=`./gtc_utility_generate_pcluster_name.sh kek-moriya protein01`
# echo ${GTC_CLUSTER_NAME}

GTC_IAM_USER_NAME=$1
GTC_CLUSTER_ID=$2

# echo "GoToCloud(DEBUG): GTC_IAM_USER_NAME=${GTC_IAM_USER_NAME}"
# echo "GoToCloud(DEBUG): GTC_CLUSTER_ID=${GTC_CLUSTER_ID}"

# return generated cluster name
echo ${GTC_IAM_USER_NAME}-${GTC_CLUSTER_ID}
