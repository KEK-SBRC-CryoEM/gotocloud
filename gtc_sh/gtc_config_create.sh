#!/bin/sh
#
# Usage:
# $1 : AWS Parallel Cluster Instance ID. e.g. 00
# $2 : FSX (Lustre) strage capacity in MByte. e.g. 2400 (meaning 2.4TByte)
# $3 : Maximum number of EC2 instances you can use at the same time. e.g. 10
# 
# Example
# $ /efs/em/gtc_sh_ver00/gtc_config_create.sh 00 2400 10
# $ ls -l ~/.parallelcluster/
# $ cat ~/.parallelcluster/config_00
# $ rm config_00*
# $ 
# $ ls -l ~/environment/kek-moriya-protein210720.pem
# $ cat ~/environment/kek-moriya-protein210720.pem
# $ 
# $ aws ec2 describe-key-pairs --key-name kek-moriya-protein210720
# $ 

GTC_INSATANCE_ID=$1
GTC_FSX_MB_CAPACITY=$2
GTC_COMPUTE_RESOURCE_MAX_COUNT=$3
echo "GoToCloud [DEBUG]: GTC_INSATANCE_ID=${GTC_INSATANCE_ID}"
echo "GoToCloud [DEBUG]: GTC_FSX_MB_CAPACITY=${GTC_FSX_MB_CAPACITY}"
echo "GoToCloud [DEBUG]: GTC_COMPUTE_RESOURCE_MAX_COUNT=${GTC_COMPUTE_RESOURCE_MAX_COUNT}"

GTC_SH_DIR="/efs/em/gtc_sh_ver00/"
echo "GoToCloud [DEBUG]: GTC_SH_DIR=${GTC_SH_DIR}"

GTC_IAM_USEAR_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_iam-user_val.sh`
GTC_METHOD_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_method_val.sh`
GTC_PROJECT_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_project_val.sh`
GTC_PCLUSTER_NAME=`${GTC_SH_DIR}gtc_utility_generate_pcluster_name.sh`
GTC_KEY_NAME=${GTC_PCLUSTER_NAME}
GTC_S3_NAME=${GTC_PCLUSTER_NAME}
echo "GoToCloud [DEBUG]: GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"
echo "GoToCloud [DEBUG]: GTC_METHOD_NAME=${GTC_METHOD_NAME}"
echo "GoToCloud [DEBUG]: GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"
echo "GoToCloud [DEBUG]: GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"
echo "GoToCloud [DEBUG]: GTC_KEY_NAME=${GTC_KEY_NAME}"
echo "GoToCloud [DEBUG]: GTC_S3_NAME=${GTC_S3_NAME}"

GTC_CONFIG=${HOME}/.parallelcluster/config
GTC_CONFIG_INSTANCE=${HOME}/.parallelcluster/config_${GTC_INSATANCE_ID}
GTC_CONFIG_TEMPLATE=${GTC_SH_DIR}gtc_config_template.txt
echo "GoToCloud [DEBUG]: GTC_CONFIG_INSTANCE=${GTC_CONFIG_INSTANCE}"
echo "GoToCloud [DEBUG]: GTC_CONFIG_TEMPLATE=${GTC_CONFIG_TEMPLATE}"

echo "GoToCloud: Creating config from template..."
if [ -e ${GTC_CONFIG_INSTANCE} ]; then
    GTC_CONFIG_BACKUP=${GTC_CONFIG_INSTANCE}_`date "+%Y%m%d_%H%M%S"`
    echo "GoToCloud [DEBUG]: GTC_CONFIG_BACKUP=${GTC_CONFIG_BACKUP}"
    echo "GoToCloud: Making a backup of previous config ${GTC_CONFIG_INSTANCE} as ${GTC_CONFIG_BACKUP}..."
    mv ${GTC_CONFIG_INSTANCE} ${GTC_CONFIG_BACKUP}
fi
cp ${GTC_CONFIG_TEMPLATE} ${GTC_CONFIG_INSTANCE}

# Replace variable strings in template to actual values
# XXX_GTC_KEY_NAME_XXX -> ${GTC_KEY_NAME}
sed -i "s/XXX_GTC_KEY_NAME_XXX/${GTC_KEY_NAME}/g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_IAM_USER_NAME_XXX -> ${GTC_IAM_USEAR_NAME}
sed -i "s/XXX_GTC_IAM_USER_NAME_XXX/${GTC_IAM_USEAR_NAME}/g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_METHOD_NAME_XXX -> ${GTC_METHOD_NAME}
sed -i "s/XXX_GTC_METHOD_NAME_XXX/${GTC_METHOD_NAME}/g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_PROJECT_NAME_XXX -> ${GTC_PROJECT_NAME}
sed -i "s/XXX_GTC_PROJECT_NAME_XXX/${GTC_PROJECT_NAME}/g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_S3_NAME_XXX -> ${GTC_S3_NAME}
sed -i "s/XXX_GTC_S3_NAME_XXX/${GTC_S3_NAME}/g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_FSX_MB_CAPACITY_XXX -> ${GTC_FSX_MB_CAPACITY}
sed -i "s/XXX_GTC_FSX_MB_CAPACITY_XXX/${GTC_FSX_MB_CAPACITY}/g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_COMPUTE_RESOURCE_MAX_COUNT_XXX -> ${GTC_COMPUTE_RESOURCE_MAX_COUNT}
sed -i "s/XXX_GTC_COMPUTE_RESOURCE_MAX_COUNT_XXX/${GTC_COMPUTE_RESOURCE_MAX_COUNT}/g" ${GTC_CONFIG_INSTANCE}

echo "GoToCloud: Creating config from template..."
if [ -e ${GTC_CONFIG} ]; then
    GTC_CONFIG_PREVIOUS=${GTC_CONFIG}_previous
    echo "GoToCloud [DEBUG]: GTC_CONFIG_PREVIOUS=${GTC_CONFIG_PREVIOUS}"
    echo "GoToCloud: Making a backup of previous config ${GTC_CONFIG} as ${GTC_CONFIG_PREVIOUS}..."
    mv ${GTC_CONFIG} ${GTC_CONFIG_PREVIOUS}
fi
cp ${GTC_CONFIG_INSTANCE} ${GTC_CONFIG}

echo "GoToCloud: Saved config as ${GTC_CONFIG_INSTANCE}"
echo "GoToCloud: Done"
