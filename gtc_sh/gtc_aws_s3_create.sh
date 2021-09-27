#!/bin/bash
#
# Example:
# $ /efs/em/gtc_sh_ver00/gtc_aws_s3_create.sh
# 
# Debug Commands:
# 
# $ aws s3 ls
# $ 
# $ /efs/em/gtc_sh_ver00/gtc_aws_s3_create.sh
# $ 
# ### $ aws s3api list-buckets
# $ aws s3api get-bucket-tagging --bucket kek-moriya-protein210720
# $ aws s3 ls
# $ aws s3 ls s3://kek-moriya-protein210720
# $ 
# $ aws s3 rb s3://kek-moriya-protein210720


GTC_SH_DIR="/efs/em/gtc_sh_ver00/"

echo "GoToCloud [DEBUG]: GTC_SH_DIR=${GTC_SH_DIR}"

GTC_IAM_USEAR_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_iam-user_val.sh`
GTC_METHOD_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_method_val.sh`
GTC_PROJECT_NAME=`${GTC_SH_DIR}gtc_utility_get_tags_project_val.sh`
GTC_PCLUSTER_NAME=`${GTC_SH_DIR}gtc_utility_generate_pcluster_name.sh`

echo "GoToCloud [DEBUG]: GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"
echo "GoToCloud [DEBUG]: GTC_METHOD_NAME=${GTC_METHOD_NAME}"
echo "GoToCloud [DEBUG]: GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"
echo "GoToCloud [DEBUG]: GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"

echo "GoToCloud: Creating S3 bucket ${GTC_PCLUSTER_NAME}..."
aws s3 mb s3://${GTC_PCLUSTER_NAME} || {
        echo "GoToCloud: GCT_ERROR! S3 bucket ${GTC_PCLUSTER_NAME} exists already!"
        echo "GoToCloud: Exiting..."
        exit 1
}

echo "GoToCloud: Settings tags to S3 bucket ${GTC_PCLUSTER_NAME}..."
aws s3api put-bucket-tagging --bucket ${GTC_PCLUSTER_NAME} --tagging "TagSet=[{Key='iam-user',Value='${GTC_IAM_USEAR_NAME}'},{Key='method',Value='${GTC_METHOD_NAME}'},{Key='project',Value='${GTC_PROJECT_NAME}'}]"
aws s3api put-public-access-block --bucket ${GTC_PCLUSTER_NAME}  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "GoToCloud: Created S3 backet ${GTC_PCLUSTER_NAME}"
echo "GoToCloud: Done"
