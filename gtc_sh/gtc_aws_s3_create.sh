#!/bin/bash
#
# Usage:
#  gtc_aws_s3_create.sh
#   
# Arguments & Options:
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_aws_s3_create.sh
#   
# Debug Script:
#   gtc_aws_s3_create_debug.sh
# 

usage_exit() {
        echo "GoToCloud: Usage $0" 1>&2
        echo "GoToCloud: Exiting(1)..."
        exit 1
}

# Check if the number of command line arguments is valid
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] @=$@"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] #=$#"; fi
if [[ $# -gt 1 ]]; then
    echo "GoToCloud: Invalid number of arguments ($#)"
    usage_exit
fi

# Parse command line arguments
while getopts h OPT
do
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] OPT=$OPT"; fi
    case "$OPT" in
        h)  usage_exit
            ;;
        \?) echo "GoToCloud: [GTC_ERROR] Invalid option $OPTARG is specified!"
            usage_exit
            ;;
    esac
done


# Load gtc_utility_global_varaibles shell functions
source gtc_utility_global_varaibles.sh 
# . gtc_utility_global_varaibles.sh
# Get related global variables
GTC_IAM_USEAR_NAME=$(gtc_utility_get_iam_user_name)
GTC_METHOD_NAME=$(gtc_utility_get_method_name)
GTC_PROJECT_NAME=$(gtc_utility_get_project_name)
GTC_S3_NAME=$(gtc_utility_get_s3_name)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_S3_NAME=${GTC_S3_NAME}"; fi

echo "GoToCloud: Creating S3 bucket ${GTC_S3_NAME}..."
aws s3 mb s3://${GTC_S3_NAME} || {
    echo "GoToCloud: [GCT_WARNING] S3 bucket ${GTC_S3_NAME} exists already!"
    echo "GoToCloud: Exiting(0)..."
    exit 0
}

echo "GoToCloud: Settings tags to S3 bucket ${GTC_S3_NAME}..."
aws s3api put-bucket-tagging --bucket ${GTC_S3_NAME} --tagging "TagSet=[{Key='iam-user',Value='${GTC_IAM_USEAR_NAME}'},{Key='method',Value='${GTC_METHOD_NAME}'},{Key='project',Value='${GTC_PROJECT_NAME}'}]"
aws s3api put-public-access-block --bucket ${GTC_S3_NAME}  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "GoToCloud: Created S3 backet ${GTC_S3_NAME}"
echo "GoToCloud: Done"
