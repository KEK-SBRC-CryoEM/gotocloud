#!/bin/sh
# 
# Usage
# /efs/em/gtc_sh_ver00/gtc_utility_generate_pcluster_name.sh

GTC_SH_DIR="/efs/em/gtc_sh_ver00/"
GTC_IAM_USEAR_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_iam-user_val.sh`
GTC_PROJECT_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_project_val.sh`
# echo "GoToCloud [DEBUG]: GTC_SH_DIR=${GTC_SH_DIR}"
# echo "GoToCloud [DEBUG]: GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"
# echo "GoToCloud [DEBUG]: GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"

# return generated cluster name
echo ${GTC_IAM_USEAR_NAME}-${GTC_PROJECT_NAME}
