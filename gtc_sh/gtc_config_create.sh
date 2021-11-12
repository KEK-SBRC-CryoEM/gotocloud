#!/bin/bash
#
# Usage:
#   gtc_config_create.sh [-s STRAGE_CAPACITY] [-m MAX_COUNTS] [-i INSTANCE_ID]
#   
# Arguments & Options:
#   -s STRAGE_CAPACITY : FSX (Lustre) strage capacity in MByte. e.g. "-s 1200". (default "2400", meaning 2.4TByte)
#   -m MAX_COUNTS      : Maximum number of EC2 instances you can use at the same time. e.g "-m 2".  (default "10")
#   -i INSTANCE_ID     : AWS Parallel Cluster Instance ID. e.g. "-i 00". (default NONE)
#   
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_config_create.sh 
#   $ gtc_config_create.sh -s 1200 -m 2
#   $ gtc_config_create.sh -i 00
#   $ gtc_config_create.sh -s 1200 -m 2 -i 01 
#   
# Debug Script:
#   gtc_config_create_debug.sh
# 

if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_config_create.sh"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

usage_exit() {
        echo "GoToCloud: Usage $0 [-s STRAGE_CAPACITY] [-m MAX_COUNTS] [-i INSTANCE_ID]" 1>&2
        echo "GoToCloud: Exiting(1)..."
        exit 1
}

# Check if the number of command line arguments is valid
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] @=$@"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] #=$#"; fi
if [[ $# -gt 6 || $# != 1 && $(( $# & 1 )) != 0 ]]; then
    echo "GoToCloud: Invalid number of arguments ($#)"
    usage_exit
fi

# Initialize variables with default values
GTC_INSATANCE_ID="GTC_INVALID"
GTC_FSX_MB_CAPACITY=2400
GTC_COMPUTE_RESOURCE_MAX_COUNT=10

# Parse command line arguments
while getopts i:s:m:h OPT
do
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] OPT=$OPT"; fi
    case "$OPT" in
        s)  GTC_FSX_MB_CAPACITY=$OPTARG
            echo "GoToCloud: FSX (Lustre) strage capacity '${GTC_FSX_MB_CAPACITY}' MByte is specified"
            ;;
        m)  GTC_COMPUTE_RESOURCE_MAX_COUNT=$OPTARG
            echo "GoToCloud: Maximum number of EC2 instances '${GTC_COMPUTE_RESOURCE_MAX_COUNT}' is specified"
            ;;
        i)  GTC_INSATANCE_ID=$OPTARG
            echo "GoToCloud: AWS Parallel Cluster Instance ID '${GTC_INSATANCE_ID}' is specified"
            ;;
        h)  usage_exit
            ;;
        \?) echo "GoToCloud: [GTC_ERROR] Invalid option $OPTARG is specified!"
            usage_exit
            ;;
    esac
done
echo "GoToCloud: Creating config with following parameters..."
echo "GoToCloud:   FSX (Lustre) strage capacity (MByte) : ${GTC_FSX_MB_CAPACITY}"
echo "GoToCloud:   Maximum number of EC2 instances      : ${GTC_COMPUTE_RESOURCE_MAX_COUNT}"
echo "GoToCloud:   AWS Parallel Cluster Instance ID     : ${GTC_INSATANCE_ID}"

GTC_INSATANCE_SUFFIX=""
if [[ "${GTC_INSATANCE_ID}" != "GTC_INVALID" ]]; then
    GTC_INSATANCE_SUFFIX=-${GTC_INSATANCE_ID}
fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_INSATANCE_SUFFIX=${GTC_INSATANCE_SUFFIX}"; fi

# Load gtc_utility_global_varaibles shell functions
source gtc_utility_global_varaibles.sh
# . gtc_utility_global_varaibles.sh
# Get related global variables
GTC_SH_DIR=$(gtc_utility_get_sh_dir)
GTC_IAM_USEAR_NAME=$(gtc_utility_get_iam_user_name)
GTC_METHOD_NAME=$(gtc_utility_get_method_name)
GTC_PROJECT_NAME=$(gtc_utility_get_project_name)
GTC_ACCOUNT_ID=$(gtc_utility_get_account_id)
GTC_S3_NAME=$(gtc_utility_get_s3_name)
GTC_KEY_NAME=$(gtc_utility_get_key_name)
GTC_PCLUSTER_NAME=$(gtc_utility_get_pcluster_name)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_SH_DIR=${GTC_SH_DIR}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_ACCOUNT_ID=${GTC_ACCOUNT_ID}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_S3_NAME=${GTC_S3_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_NAME=${GTC_KEY_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"; fi

# Get VPC and Subnet values
#GTC_VPC=$(aws ec2 describe-vpcs | jq '.Vpcs[]')
GTC_SN=$(aws ec2 describe-subnets | jq '.Subnets[]')
#echo "GoToCloud: [GTC_DEBUG] GTC_VPC=${GTC_VPC}"
#echo "GoToCloud: [GTC_DEBUG] GTC_SN=${GTC_SN}" 
#GTC_VPC_ID=`echo ${GTC_SN} | jq -r 'select(.AvailabilityZoneId == "apne1-az4" and .DefaultForAz == false).VpcId'`
GTC_SUBNET_ID=`echo ${GTC_SN} | jq -r 'select(.AvailabilityZoneId == "apne1-az4" and .DefaultForAz == false).SubnetId'`


# Create config file
GTC_CONFIG_INSTANCE=${HOME}/.parallelcluster/config${GTC_INSATANCE_SUFFIX}.yaml
GTC_CONFIG_INSTANCE1=${HOME}/.parallelcluster/config${GTC_INSATANCE_SUFFIX}
GTC_CONFIG_TEMPLATE=${GTC_SH_DIR}/gtc_config_template.yaml
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CONFIG_INSTANCE=${GTC_CONFIG_INSTANCE}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CONFIG_TEMPLATE=${GTC_CONFIG_TEMPLATE}"; fi

echo "GoToCloud: Creating config from template..."
if [ -e ${GTC_CONFIG_INSTANCE} ]; then
    GTC_CONFIG_BACKUP=${GTC_CONFIG_INSTANCE1}_backup_`date "+%Y%m%d_%H%M%S"`.yaml
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_CONFIG_BACKUP=${GTC_CONFIG_BACKUP}"; fi
    echo "GoToCloud: Making a backup of previous config ${GTC_CONFIG_INSTANCE} as ${GTC_CONFIG_BACKUP}..."
    mv ${GTC_CONFIG_INSTANCE} ${GTC_CONFIG_BACKUP}
fi
cp ${GTC_CONFIG_TEMPLATE} ${GTC_CONFIG_INSTANCE}

# Replace variable strings in template to actual values
# XXX_GTC_KEY_NAME_XXX -> ${GTC_KEY_NAME}
sed -i "s@XXX_GTC_KEY_NAME_XXX@${GTC_KEY_NAME}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_IAM_USER_NAME_XXX -> ${GTC_IAM_USEAR_NAME}
sed -i "s@XXX_GTC_IAM_USER_NAME_XXX@${GTC_IAM_USEAR_NAME}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_METHOD_NAME_XXX -> ${GTC_METHOD_NAME}
sed -i "s@XXX_GTC_METHOD_NAME_XXX@${GTC_METHOD_NAME}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_PROJECT_NAME_XXX -> ${GTC_PROJECT_NAME}
sed -i "s@XXX_GTC_PROJECT_NAME_XXX@${GTC_PROJECT_NAME}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_ACCOUNT_ID_XXX -> ${GTC_ACCOUNT_ID}
sed -i "s@XXX_GTC_ACCOUNT_ID_XXX@${GTC_ACCOUNT_ID}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_S3_NAME_XXX -> ${GTC_S3_NAME}
sed -i "s@XXX_GTC_S3_NAME_XXX@${GTC_S3_NAME}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_FSX_MB_CAPACITY_XXX -> ${GTC_FSX_MB_CAPACITY}
sed -i "s@XXX_GTC_FSX_MB_CAPACITY_XXX@${GTC_FSX_MB_CAPACITY}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_COMPUTE_RESOURCE_MAX_COUNT_XXX -> ${GTC_COMPUTE_RESOURCE_MAX_COUNT}
sed -i "s@XXX_GTC_COMPUTE_RESOURCE_MAX_COUNT_XXX@${GTC_COMPUTE_RESOURCE_MAX_COUNT}@g" ${GTC_CONFIG_INSTANCE}

# XXX_GTC_VPC_ID_XXX -> ${GTC_VPC_ID}
# sed -i "s@XXX_GTC_VPC_ID_XXX@${GTC_VPC_ID}@g" ${GTC_CONFIG_INSTANCE}
# XXX_GTC_SUBNET_ID_XXX -> ${GTC_SUBNET_ID}
sed -i "s@XXX_GTC_SUBNET_ID_XXX@${GTC_SUBNET_ID}@g" ${GTC_CONFIG_INSTANCE}

echo "GoToCloud: Saved config as ${GTC_CONFIG_INSTANCE}"
echo "GoToCloud: Done"

if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] "; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_config_create.sh!"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

