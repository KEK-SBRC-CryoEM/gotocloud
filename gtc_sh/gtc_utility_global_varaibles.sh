#!/bin/bash
#
# ***************************************************************************
#
# Copyright (c) 2021-2024 Structural Biology Research Center, 
#                         Institute of Materials Structure Science, 
#                         High Energy Accelerator Research Organization (KEK)
#
#
# Authors:   Toshio Moriya (toshio.moriya@kek.jp)
#            Misato Yamamoto (misatoy@post.kek.jp)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307  USA
#
# ***************************************************************************
#
# Example:
#   $ source gtc_utility_global_varaibles.sh
#   OR
#   $ . gtc_utility_global_varaibles.sh
#   
#   Then, first call
#   $ gtc_utility_setup_global_variables
#   
#   Then, you can use the following functions from any GoToCloud scripts
#   $ gtc_utility_get_sh_dir
#   $ gtc_utility_get_tag_key_iamuser
#   $ gtc_utility_get_tag_key_method
#   $ gtc_utility_get_tag_key_project
#   $ gtc_utility_get_tag_key_account
#   $ gtc_utility_get_aws_vendor_user
#   $ gtc_utility_get_tag_key_user
#   $ gtc_utility_get_tag_key_service
#   $ gtc_utility_get_tag_key_team
#   $ gtc_utility_get_iam_user_name
#   $ gtc_utility_get_method_name
#   $ gtc_utility_get_project_name
#   $ gtc_utility_get_account_id
#   $ gtc_utility_get_pcluster_name
#   $ gtc_utility_get_s3_name
#   $ gtc_utility_get_key_name
#   $ gtc_utility_get_aws_region
#   $ gtc_utility_get_vpc_id
#   $ gtc_utility_get_vpc_cidr
#   $ gtc_utility_get_accepter_vpc_id
#   $ gtc_utility_get_accepter_vpc_cidr
#   $ gtc_utility_get_efs_filesystem_id
#   $ gtc_utility_get_efs_mount_target_ip
#   $ gtc_utility_get_subnet_name
#   $ gtc_utility_get_subnet_id
#   $ gtc_utility_get_key_dir
#   $ gtc_utility_get_key_file
#   $ gtc_utility_get_application_dir
#   $ gtc_utility_get_virtualenv_name
#   $ gtc_utility_get_global_varaibles_file
#   $ gtc_utility_get_debug_mode
#  
# Debug Script:
#   gtc_utility_global_varaibles_debug_setup.sh 
# 

# Set GTC_IAM_USEAR_NAME GTC_METHOD_NAME GTC_PROJECT_NAME GTC_ACCOUNT_ID GTC_TAG_KEY_*
function gtc_utility_setup_global_variables() {
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_utility_setup_global_variables!"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

    # --------------------
    # Extract GoToCloud shell script direcctory path and set it as a systemwise environment varaible
    # Assumes the directory path of gtc_setup_env_vars_on_cloud9.sh
    GTC_PARENT_COMMAND=$0
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_PARENT_COMMAND=${GTC_PARENT_COMMAND}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] dirname ${GTC_PARENT_COMMAND} = $(dirname ${GTC_PARENT_COMMAND})"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] pwd = $(pwd)"; fi
    GTC_SH_DIR=`cd $(dirname $(readlink -f ${GTC_PARENT_COMMAND})) && pwd`
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SH_DIR=${GTC_SH_DIR}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] pwd = $(pwd)"; fi

    # --------------------
    # Get tags values from this Cloud9 instance and set them as systemwise environment varaibles
    # Load gtc_utility shell functions
    # . ${GTC_SH_DIR}/gtc_utility_account_identity.sh
    # Set GTC_IAM_USEAR_NAME GTC_ACCOUNT_ID
    function gtc_utility_account_identity_get_values() {
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_utility_account_identity_get_values!"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    
        # Get tags values from this Cloud9 instance
        # local GTC_TAGS=$(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) | jq -r '.Reservations[].Instances[].Tags[]')
        local GTC_AWS_INFO=$(aws sts get-caller-identity)
        # echo "GoToCloud: [GTC_DEBUG] GTC_TAGS=${GTC_TAGS}"
    
        # Extract values of keys
        GTC_IAM_USEAR_NAME=`echo ${GTC_AWS_INFO} | jq -r '.Arn' | awk '{sub(".*./", "");print $0;}'`
        GTC_ACCOUNT_ID=`echo ${GTC_AWS_INFO} | jq -r '.Account'`

        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_ACCOUNT_ID=${GTC_ACCOUNT_ID}"; fi
  
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_utility_account_identity_get_values!"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    }

    function gtc_utility_project_name_get_values() {
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_utility_project_name_get_values!"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    
        # Get tags values from this Cloud9 instance
        local GTC_TAGS=$(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) | jq -r '.Reservations[].Instances[].Tags[]')
        GTC_CLOUD9_ENV=`echo ${GTC_TAGS} | jq -r 'select(.Key == "aws:cloud9:environment").Value'`
        GTC_CLOUD9_NAME=`echo ${GTC_TAGS} | jq -r 'select(.Key == "Name").Value' | awk '{sub("-'${GTC_CLOUD9_ENV}'", "");print $0;}' | awk '{sub("aws-cloud9-", "");print $0;}'`

        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_CLOUD9_ENV=${GTC_CLOUD9_ENV}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_CLOUD9_NAME=${GTC_CLOUD9_NAME}"; fi
  
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_utility_project_name_get_values!"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    }

        function gtc_utility_network_info_get_values() {
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_utility_network_info_get_values!"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    
        # Get network info from this Cloud9 instance
        local GTC_CLOUD9_NETWORK_INFO=$(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) | jq -r '.Reservations[].Instances[].NetworkInterfaces[]')
        local GTC_PEERING_INFO=$(aws ec2 describe-vpc-peering-connections --region ${GTC_AWS_REGION} | jq '.VpcPeeringConnections[]')
        GTC_VPC_ID=`echo ${GTC_CLOUD9_NETWORK_INFO} | jq -r '.VpcId'`
        GTC_VPC_CIDR=$(aws ec2 describe-vpcs | jq '.Vpcs[]' | jq -r 'select(.VpcId == "'${GTC_VPC_ID}'").CidrBlock')
        GTC_ACCEPTER_VPC_ID=`echo ${GTC_PEERING_INFO} | jq -r 'select(.RequesterVpcInfo.VpcId == "'${GTC_VPC_ID}'").AccepterVpcInfo.VpcId'`
        GTC_ACCEPTER_VPC_CIDR=`echo ${GTC_PEERING_INFO} | jq -r 'select(.RequesterVpcInfo.VpcId == "'${GTC_VPC_ID}'").AccepterVpcInfo.CidrBlock'`
        GTC_EFS_SETTING=$(echo "$(pwd)/gtc_efs_setting.json")
        GTC_EFS_FILESYSTEM_ID=$(cat ${GTC_EFS_SETTING} | jq '.EfsSettings[]' | jq -r 'select(.VpcId == "'${GTC_ACCEPTER_VPC_ID}'").FileSystemId')
        GTC_EFS_MOUNT_TARGET_IP=$(cat ${GTC_EFS_SETTING} | jq '.EfsSettings[]' | jq -r 'select(.VpcId == "'${GTC_ACCEPTER_VPC_ID}'").IpAddress')
        GTC_SUBNET_ID=`echo ${GTC_CLOUD9_NETWORK_INFO} | jq -r '.SubnetId'`
        GTC_SUBNET_NAME=$(aws ec2 describe-subnets | jq '.Subnets[]' | jq 'select(.SubnetId == "'${GTC_SUBNET_ID}'")' | jq '.Tags[]' | jq -r 'select(.Key == "Name").Value')

        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_VPC_ID=${GTC_VPC_ID}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_VPC_CIDR=${GTC_VPC_CIDR}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_ACCEPTER_VPC_ID=${GTC_ACCEPTER_VPC_ID}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_ACCEPTER_VPC_CIDR=${GTC_ACCEPTER_VPC_CIDR}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_EFS_FILESYSTEM_ID=${GTC_EFS_FILESYSTEM_ID}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_EFS_MOUNT_TARGET_IP=${GTC_EFS_MOUNT_TARGET_IP}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SUBNET_NAME=${GTC_SUBNET_NAME}"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SUBNET_ID=${GTC_SUBNET_ID}"; fi

        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_utility_network_info_get_values!"; fi
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    }

    # Get GoToCloud meta info as global variables within file scope
    # i.e. GTC_IAM_USEAR_NAME GTC_METHOD_NAME GTC_PROJECT_NAME GTC_ACCOUNT_ID GTC_TAG_KEY_*
    GTC_AWS_REGION=$(aws configure get region)
    gtc_utility_account_identity_get_values
    gtc_utility_project_name_get_values
    gtc_utility_network_info_get_values
    if [ ${GTC_PROJECT_NAME_INIT} == "cloud9-name" ]; then
        GTC_PROJECT_NAME=${GTC_CLOUD9_NAME}
    else
        GTC_PROJECT_NAME=${GTC_PROJECT_NAME_INIT}
    fi
    GTC_TAG_KEY_IAMUSER="gtc:iam-user"
    GTC_TAG_KEY_METHOD="gtc:method"
    GTC_TAG_KEY_PROJECT="gtc:project"
    GTC_TAG_KEY_ACCOUNT="gtc:account"
    GTC_METHOD_NAME="cryoem"
    GTC_AWS_VENDOR="1"  # 1:vendor M  0:others
    GTC_TAG_KEY_USER="User"
    GTC_TAG_KEY_SERVICE="Service"
    GTC_TAG_KEY_TEAM="Team"
    GTC_PCLUSTER_NAME=${GTC_IAM_USEAR_NAME}-${GTC_ACCOUNT_ID}-${GTC_PROJECT_NAME}
    GTC_S3_NAME=${GTC_PCLUSTER_NAME}
    GTC_KEY_NAME=${GTC_PCLUSTER_NAME}
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_IAMUSER=${GTC_TAG_KEY_IAMUSER}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_METHOD=${GTC_TAG_KEY_METHOD}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_PROJECT=${GTC_TAG_KEY_PROJECT}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_ACCOUNT=${GTC_TAG_KEY_ACCOUNT}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_AWS_VENDOR=${GTC_AWS_VENDOR}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_USER=${GTC_TAG_KEY_USER}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_SERVICE=${GTC_TAG_KEY_SERVICE}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_TEAM=${GTC_TAG_KEY_TEAM}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_ACCOUNT_ID=${GTC_ACCOUNT_ID}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_S3_NAME=${GTC_S3_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_KEY_NAME=${GTC_KEY_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_AWS_REGION=${GTC_AWS_REGION}"; fi

    # --------------------
    # Set GoToCloud directory path and file path of key file as a systemwise environment constant
    GTC_KEY_DIR=${HOME}/environment
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_KEY_DIR=${GTC_KEY_DIR}"; fi
    GTC_KEY_FILE=${GTC_KEY_DIR}/${GTC_S3_NAME}.pem
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_KEY_FILE=${GTC_KEY_FILE}"; fi

    # --------------------
    # Initialize GoToCloud debug mode for develper and set it as a systemwise environment varaible
    # This hides debug mode from standard users
    GTC_DEBUG_MODE=0
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then
        GTC_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}
    fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_DEBUG_MODE=${GTC_DEBUG_MODE}"; fi
    
    # --------------------
    # Set name of virtual environment for parallelcluster
    GTC_VIRTUALENV_NAME="gtc-parallelcluster" 
    # --------------------
    # Set GoToCloud application directory path on cloud9 and file path of GoToCloud environment settings file for cloud9 as a systemwise environment constant
    GTC_APPLICATION_DIR=${HOME}/.gtc
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_APPLICATION_DIR=${GTC_APPLICATION_DIR}"; fi
    if [ -e ${GTC_APPLICATION_DIR} ]; then
        echo "GoToCloud: ${GTC_APPLICATION_DIR} exists already!"
        GTC_APPLICATION_DIR_BACKUP=${GTC_APPLICATION_DIR}_backup_`date "+%Y%m%d_%H%M%S"`
        if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_APPLICATION_DIR_BACKUP=${GTC_APPLICATION_DIR_BACKUP}"; fi
        echo "GoToCloud: Making a backup of previous GoToCloud application ${GTC_APPLICATION_DIR} as ${GTC_APPLICATION_DIR_BACKUP}..."
        mv ${GTC_APPLICATION_DIR} ${GTC_APPLICATION_DIR_BACKUP}
        
    fi
    echo "GoToCloud: Creating GoToCloud application directory ${GTC_APPLICATION_DIR}..."
    mkdir -p ${GTC_APPLICATION_DIR}
    
    GTC_GLOBAL_VARIABLES_FILE=${GTC_APPLICATION_DIR}/global_variables.sh
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_GLOBAL_VARIABLES_FILE=${GTC_GLOBAL_VARIABLES_FILE}"; fi
    if [ -e ${GTC_GLOBAL_VARIABLES_FILE} ]; then
        # GTC_GLOBAL_VARIABLES_FILE_BACKUP=${GTC_GLOBAL_VARIABLES_FILE}_backup_`date "+%Y%m%d_%H%M%S"`
        # if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_GLOBAL_VARIABLES_FILE_BACKUP=${GTC_GLOBAL_VARIABLES_FILE_BACKUP}"; fi
        # echo "GoToCloud: Making a backup of previous ${GTC_GLOBAL_VARIABLES_FILE} as ${GTC_GLOBAL_VARIABLES_FILE_BACKUP}..."
        # cp ${GTC_GLOBAL_VARIABLES_FILE} ${GTC_GLOBAL_VARIABLES_FILE_BACKUP}
        echo "GoToCloud: [GTC_ERROR] Locally ${GTC_GLOBAL_VARIABLES_FILE} should not exist!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
    fi

    # --------------------
    # Store all to GoToCloud environment settings file
    
    echo "GoToCloud: Creating Cloud9 system environment variable settings for GoToCloud global variables as ${GTC_GLOBAL_VARIABLES_FILE}..."
    # cat > ${GTC_GLOBAL_VARIABLES_FILE} <<'EOS' suppresses varaible replacements 
    # cat > ${GTC_GLOBAL_VARIABLES_FILE} <<EOS allows varaible replacements 
    cat > ${GTC_GLOBAL_VARIABLES_FILE} <<'EOS'
#!/bin/sh

# GoToCloud system environment variables
export GTC_SYSTEM_SH_DIR=XXX_GTC_SH_DIR_XXX
export GTC_SYSTEM_TAG_KEY_IAMUSER=XXX_GTC_TAG_KEY_IAMUSER_XXX
export GTC_SYSTEM_TAG_KEY_METHOD=XXX_GTC_TAG_KEY_METHOD_XXX
export GTC_SYSTEM_TAG_KEY_PROJECT=XXX_GTC_TAG_KEY_PROJECT_XXX
export GTC_SYSTEM_TAG_KEY_ACCOUNT=XXX_GTC_TAG_KEY_ACCOUNT_XXX
export GTC_SYSTEM_AWS_VENDOR=XXX_GTC_AWS_VENDOR_XXX
export GTC_SYSTEM_TAG_KEY_USER=XXX_GTC_TAG_KEY_USER_XXX
export GTC_SYSTEM_TAG_KEY_SERVICE=XXX_GTC_TAG_KEY_SERVICE_XXX
export GTC_SYSTEM_TAG_KEY_TEAM=XXX_GTC_TAG_KEY_TEAM_XXX
export GTC_SYSTEM_IAM_USEAR_NAME=XXX_GTC_IAM_USEAR_NAME_XXX
export GTC_SYSTEM_METHOD_NAME=XXX_GTC_METHOD_NAME_XXX
export GTC_SYSTEM_PROJECT_NAME=XXX_GTC_PROJECT_NAME_XXX
export GTC_SYSTEM_ACCOUNT_ID=XXX_GTC_ACCOUNT_ID_XXX
export GTC_SYSTEM_PCLUSTER_NAME=XXX_GTC_PCLUSTER_NAME_XXX
export GTC_SYSTEM_S3_NAME=XXX_GTC_S3_NAME_XXX
export GTC_SYSTEM_KEY_NAME=XXX_GTC_KEY_NAME_XXX
export GTC_SYSTEM_AWS_REGION=XXX_GTC_AWS_REGION_XXX
export GTC_SYSTEM_VPC_ID=XXX_GTC_VPC_ID_XXX
export GTC_SYSTEM_VPC_CIDR=XXX_GTC_VPC_CIDR_XXX
export GTC_SYSTEM_ACCEPTER_VPC_ID=XXX_GTC_ACCEPTER_VPC_ID_XXX
export GTC_SYSTEM_ACCEPTER_VPC_CIDR=XXX_GTC_ACCEPTER_VPC_CIDR_XXX
export GTC_SYSTEM_EFS_FILESYSTEM_ID=XXX_GTC_EFS_FILESYSTEM_ID_XXX
export GTC_SYSTEM_EFS_MOUNT_TARGET_IP=XXX_GTC_EFS_MOUNT_TARGET_IP_XXX
export GTC_SYSTEM_SUBNET_NAME=XXX_GTC_SUBNET_NAME_XXX
export GTC_SYSTEM_SUBNET_ID=XXX_GTC_SUBNET_ID_XXX
export GTC_SYSTEM_KEY_DIR=XXX_GTC_KEY_DIR_XXX
export GTC_SYSTEM_KEY_FILE=XXX_GTC_KEY_FILE_XXX
export GTC_SYSTEM_APPLICATION_DIR=XXX_GTC_APPLICATION_DIR_XXX
export GTC_SYSTEM_VIRTUALENV_NAME=XXX_GTC_VIRTUALENV_NAME_XXX
export GTC_SYSTEM_GLOBAL_VARIABLES_FILE=XXX_GTC_GLOBAL_VARIABLES_FILE_XXX
export GTC_SYSTEM_DEBUG_MODE=XXX_GTC_DEBUG_MODE_XXX
# To be causious, put new path at the end
export PATH=$PATH:${GTC_SYSTEM_SH_DIR}
EOS

    # Replace variable strings in template to actual values
    # XXX_GTC_SH_DIR_XXX -> ${GTC_SH_DIR}
    sed -i "s@XXX_GTC_SH_DIR_XXX@${GTC_SH_DIR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_TAG_KEY_IAMUSER_XXX -> ${GTC_TAG_KEY_IAMUSER}
    sed -i "s@XXX_GTC_TAG_KEY_IAMUSER_XXX@${GTC_TAG_KEY_IAMUSER}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_TAG_KEY_METHOD_XXX -> ${GTC_TAG_KEY_METHOD}
    sed -i "s@XXX_GTC_TAG_KEY_METHOD_XXX@${GTC_TAG_KEY_METHOD}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_TAG_KEY_PROJECT_XXX -> ${GTC_TAG_KEY_PROJECT}
    sed -i "s@XXX_GTC_TAG_KEY_PROJECT_XXX@${GTC_TAG_KEY_PROJECT}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_TAG_KEY_ACCOUNT_XXX -> ${GTC_TAG_KEY_ACCOUNT}
    sed -i "s@XXX_GTC_TAG_KEY_ACCOUNT_XXX@${GTC_TAG_KEY_ACCOUNT}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_AWS_VENDOR_XXX -> ${GTC_AWS_VENDOR}
    sed -i "s@XXX_GTC_AWS_VENDOR_XXX@${GTC_AWS_VENDOR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_TAG_KEY_USER_XXX -> ${GTC_TAG_KEY_USER}
    sed -i "s@XXX_GTC_TAG_KEY_USER_XXX@${GTC_TAG_KEY_USER}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_TAG_KEY_SERVICE_XXX -> ${GTC_TAG_KEY_SERVICE}
    sed -i "s@XXX_GTC_TAG_KEY_SERVICE_XXX@${GTC_TAG_KEY_SERVICE}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_TAG_KEY_TEAM_XXX -> ${GTC_TAG_KEY_TEAM}
    sed -i "s@XXX_GTC_TAG_KEY_TEAM_XXX@${GTC_TAG_KEY_TEAM}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_IAM_USEAR_NAME_XXX -> ${GTC_IAM_USEAR_NAME}
    sed -i "s@XXX_GTC_IAM_USEAR_NAME_XXX@${GTC_IAM_USEAR_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_METHOD_NAME_XXX -> ${GTC_METHOD_NAME}
    sed -i "s@XXX_GTC_METHOD_NAME_XXX@${GTC_METHOD_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_PROJECT_NAME_XXX -> ${GTC_PROJECT_NAME}
    sed -i "s@XXX_GTC_PROJECT_NAME_XXX@${GTC_PROJECT_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_ACCOUNT_ID_XXX -> ${GTC_ACCOUNT_ID}
    sed -i "s@XXX_GTC_ACCOUNT_ID_XXX@${GTC_ACCOUNT_ID}@g" ${GTC_GLOBAL_VARIABLES_FILE} 
    # XXX_GTC_PCLUSTER_NAME_XXX -> ${GTC_PCLUSTER_NAME}
    sed -i "s@XXX_GTC_PCLUSTER_NAME_XXX@${GTC_PCLUSTER_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_S3_NAME_XXX -> ${GTC_S3_NAME}
    sed -i "s@XXX_GTC_S3_NAME_XXX@${GTC_S3_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_KEY_NAME_XXX -> ${GTC_KEY_NAME}
    sed -i "s@XXX_GTC_KEY_NAME_XXX@${GTC_KEY_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_AWS_REGION_XXX -> ${GTC_AWS_REGION}
    sed -i "s@XXX_GTC_AWS_REGION_XXX@${GTC_AWS_REGION}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_VPC_ID_XXX -> ${GTC_VPC_ID}
    sed -i "s@XXX_GTC_VPC_ID_XXX@${GTC_VPC_ID}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GGTC_VPC_CIDR_XXX -> ${GTC_VPC_CIDR}
    sed -i "s@XXX_GTC_VPC_CIDR_XXX@${GTC_VPC_CIDR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_ACCEPTER_VPC_ID_XXX -> ${GTC_ACCEPTER_VPC_ID}
    sed -i "s@XXX_GTC_ACCEPTER_VPC_ID_XXX@${GTC_ACCEPTER_VPC_ID}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_ACCEPTER_VPC_CIDR_XXX -> ${GGTC_ACCEPTER_VPC_CIDR}
    sed -i "s@XXX_GTC_ACCEPTER_VPC_CIDR_XXX@${GTC_ACCEPTER_VPC_CIDR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_EFS_FILESYSTEM_ID_XXX -> ${GGTC_EFS_FILESYSTEM_ID}
    sed -i "s@XXX_GTC_EFS_FILESYSTEM_ID_XXX@${GTC_EFS_FILESYSTEM_ID}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_EFS_MOUNT_TARGET_IP_XXX -> ${GTC_EFS_MOUNT_TARGET_IP}
    sed -i "s@XXX_GTC_EFS_MOUNT_TARGET_IP_XXX@${GTC_EFS_MOUNT_TARGET_IP}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_SUBNET_NAME_XXX -> ${GTC_SUBNET_NAME}
    sed -i "s@XXX_GTC_SUBNET_NAME_XXX@${GTC_SUBNET_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_SUBNET_ID_XXX -> ${GTC_SUBNET_ID}
    sed -i "s@XXX_GTC_SUBNET_ID_XXX@${GTC_SUBNET_ID}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_KEY_DIR_XXX -> ${GTC_KEY_DIR}
    sed -i "s@XXX_GTC_KEY_DIR_XXX@${GTC_KEY_DIR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_KEY_FILE_XXX -> ${GTC_KEY_FILE}
    sed -i "s@XXX_GTC_KEY_FILE_XXX@${GTC_KEY_FILE}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_APPLICATION_DIR_XXX -> ${GTC_APPLICATION_DIR}
    sed -i "s@XXX_GTC_APPLICATION_DIR_XXX@${GTC_APPLICATION_DIR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_VIRTUALENV_NAME_XXX -> ${GTC_VIRTUALENV_NAME}
    sed -i "s@XXX_GTC_VIRTUALENV_NAME_XXX@${GTC_VIRTUALENV_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_GLOBAL_VARIABLES_FILE_XXX -> ${GTC_GLOBAL_VARIABLES_FILE}
    sed -i "s@XXX_GTC_GLOBAL_VARIABLES_FILE_XXX@${GTC_GLOBAL_VARIABLES_FILE}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_DEBUG_MODE_XXX -> ${GTC_DEBUG_MODE}
    sed -i "s@XXX_GTC_DEBUG_MODE_XXX@${GTC_DEBUG_MODE}@g" ${GTC_GLOBAL_VARIABLES_FILE}

    # Set file permission 
    chmod 775 ${GTC_GLOBAL_VARIABLES_FILE}
    
    echo "GoToCloud: Activating Cloud9 system environment variable settings for GoToCloud global variables defined in ${GTC_GLOBAL_VARIABLES_FILE}..."
    echo "GoToCloud: Note that this activation is effective only for caller of this script file."
    source ${GTC_GLOBAL_VARIABLES_FILE}
    #. ${GTC_GLOBAL_VARIABLES_FILE}
    
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_utility_setup_global_variables!"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
}

# -----------------------
# Get functions
# -----------------------
# These get functions encapsulates the implementation details of 
# where these GTC system values are stored.

function gtc_utility_get_sh_dir() {
    echo ${GTC_SYSTEM_SH_DIR}
}

function gtc_utility_get_tag_key_iamuser() {
    echo ${GTC_SYSTEM_TAG_KEY_IAMUSER}
}

function gtc_utility_get_tag_key_method() {
    echo ${GTC_SYSTEM_TAG_KEY_METHOD}
}

function gtc_utility_get_tag_key_project() {
    echo ${GTC_SYSTEM_TAG_KEY_PROJECT}
}

function gtc_utility_get_tag_key_account() {
    echo ${GTC_SYSTEM_TAG_KEY_ACCOUNT}
}

function gtc_utility_get_aws_vendor() {
    echo ${GTC_SYSTEM_AWS_VENDOR}
}

function gtc_utility_get_tag_key_user() {
    echo ${GTC_SYSTEM_TAG_KEY_USER}
}

function gtc_utility_get_tag_key_service() {
    echo ${GTC_SYSTEM_TAG_KEY_SERVICE}
}

function gtc_utility_get_tag_key_team() {
    echo ${GTC_SYSTEM_TAG_KEY_TEAM}
}

function gtc_utility_get_iam_user_name() {
    echo ${GTC_SYSTEM_IAM_USEAR_NAME}
}

function gtc_utility_get_method_name() {
    echo ${GTC_SYSTEM_METHOD_NAME}
}

function gtc_utility_get_project_name() {
    echo ${GTC_SYSTEM_PROJECT_NAME}
}

function gtc_utility_get_account_id() {
    echo ${GTC_SYSTEM_ACCOUNT_ID}
}

function gtc_utility_get_pcluster_name() {
    echo ${GTC_SYSTEM_PCLUSTER_NAME}
}

function gtc_utility_get_s3_name() {
    echo ${GTC_SYSTEM_S3_NAME}
}

function gtc_utility_get_key_name() {
    echo ${GTC_SYSTEM_KEY_NAME}
}

function gtc_utility_get_aws_region() {
    echo ${GTC_SYSTEM_AWS_REGION}
}

function gtc_utility_get_vpc_id() {
    echo ${GTC_SYSTEM_VPC_ID}
}

function gtc_utility_get_vpc_cidr() {
    echo ${GTC_SYSTEM_VPC_CIDR}
}

function gtc_utility_get_accepter_vpc_id() {
    echo ${GTC_SYSTEM_ACCEPTER_VPC_ID}
}

function gtc_utility_get_accepter_vpc_cidr() {
    echo ${GTC_SYSTEM_ACCEPTER_VPC_CIDR}
}

function gtc_utility_get_efs_filesystem_id() {
    echo ${GTC_SYSTEM_EFS_FILESYSTEM_ID}
}

function gtc_utility_get_efs_mount_target_ip() {
    echo ${GTC_SYSTEM_EFS_MOUNT_TARGET_IP}
}

function gtc_utility_get_subnet_name() {
    echo ${GTC_SYSTEM_SUBNET_NAME}
}

function gtc_utility_get_subnet_id() {
    echo ${GTC_SYSTEM_SUBNET_ID}
}

function gtc_utility_get_key_dir() {
    echo ${GTC_SYSTEM_KEY_DIR}
}

function gtc_utility_get_key_file() {
    echo ${GTC_SYSTEM_KEY_FILE}
}

function gtc_utility_get_application_dir() {
    echo ${GTC_SYSTEM_APPLICATION_DIR}
}

function gtc_utility_get_virtualenv_name() {
    echo ${GTC_SYSTEM_VIRTUALENV_NAME}
}

function gtc_utility_get_global_varaibles_file() {
    echo ${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}
}

function gtc_utility_get_debug_mode() {
    echo ${GTC_SYSTEM_DEBUG_MODE}
}

#create tagset
function gtc_utility_tagset_get_values() {
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_utility_tagset_get_values!"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

    # Get related global variables
    GTC_AWS_VENDOR=$(gtc_utility_get_aws_vendor)
    GTC_TAG_KEY_METHOD=$(gtc_utility_get_tag_key_method)
    GTC_TAG_KEY_PROJECT=$(gtc_utility_get_tag_key_project)
    GTC_TAG_KEY_IAMUSER=$(gtc_utility_get_tag_key_iamuser)
    GTC_TAG_KEY_ACCOUNT=$(gtc_utility_get_tag_key_account)
    GTC_TAG_KEY_SERVICE=$(gtc_utility_get_tag_key_service)
    GTC_TAG_KEY_TEAM=$(gtc_utility_get_tag_key_team)
    GTC_TAG_KEY_USER=$(gtc_utility_get_tag_key_user)
    GTC_IAM_USEAR_NAME=$(gtc_utility_get_iam_user_name)
    GTC_METHOD_NAME=$(gtc_utility_get_method_name)
    GTC_PROJECT_NAME=$(gtc_utility_get_project_name)
    GTC_ACCOUNT_ID=$(gtc_utility_get_account_id)
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_METHOD=${GTC_TAG_KEY_METHOD}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_PROJECT=${GTC_TAG_KEY_PROJECT}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_IAMUSER=${GTC_TAG_KEY_IAMUSER}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_ACCOUNT=${GTC_TAG_KEY_ACCOUNT}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_SERVICE=${GTC_TAG_KEY_SERVICE}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_TEAM=${GTC_TAG_KEY_TEAM}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_USER=${GTC_TAG_KEY_USER}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_ACCOUNT_ID=${GTC_ACCOUNT_ID}"; fi

    if [ ${GTC_AWS_VENDOR} == 1 ]; then
        GTC_S3_TAGSET="TagSet=[{Key='${GTC_TAG_KEY_METHOD}',Value='${GTC_METHOD_NAME}'}, \
        {Key='${GTC_TAG_KEY_PROJECT}',Value='${GTC_PROJECT_NAME}'}, \
        {Key='${GTC_TAG_KEY_IAMUSER}',Value='${GTC_IAM_USEAR_NAME}'}, \
        {Key='${GTC_TAG_KEY_ACCOUNT}',Value='${GTC_ACCOUNT_ID}'}, \
        {Key='${GTC_TAG_KEY_SERVICE}',Value='${GTC_METHOD_NAME}'}, \
        {Key='${GTC_TAG_KEY_TEAM}',Value='${GTC_PROJECT_NAME}'}, \
        {Key='${GTC_TAG_KEY_USER}',Value='${GTC_IAM_USEAR_NAME}'}]"
        GTC_CLOUD9_TAGSET="Key=${GTC_TAG_KEY_METHOD},Value=${GTC_METHOD_NAME} \
        Key=${GTC_TAG_KEY_PROJECT},Value=${GTC_PROJECT_NAME} \
        Key=${GTC_TAG_KEY_IAMUSER},Value=${GTC_IAM_USEAR_NAME} \
        Key=${GTC_TAG_KEY_ACCOUNT},Value=${GTC_ACCOUNT_ID} \
        Key=${GTC_TAG_KEY_SERVICE},Value=${GTC_METHOD_NAME} \
        Key=${GTC_TAG_KEY_TEAM},Value=${GTC_PROJECT_NAME} \
        Key=${GTC_TAG_KEY_USER},Value=${GTC_IAM_USEAR_NAME}"
    else
        GTC_S3_TAGSET="TagSet=[{Key='${GTC_TAG_KEY_METHOD}',Value='${GTC_METHOD_NAME}'}, \
        {Key='${GTC_TAG_KEY_PROJECT}',Value='${GTC_PROJECT_NAME}'}, \
        {Key='${GTC_TAG_KEY_IAMUSER}',Value='${GTC_IAM_USEAR_NAME}'}, \
        {Key='${GTC_TAG_KEY_ACCOUNT}',Value='${GTC_ACCOUNT_ID}'}]"
        GTC_CLOUD9_TAGSET="Key=${GTC_TAG_KEY_METHOD},Value=${GTC_METHOD_NAME} \
        Key=${GTC_TAG_KEY_PROJECT},Value=${GTC_PROJECT_NAME} \
        Key=${GTC_TAG_KEY_IAMUSER},Value=${GTC_IAM_USEAR_NAME} \
        Key=${GTC_TAG_KEY_ACCOUNT},Value=${GTC_ACCOUNT_ID}"
    fi

    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_S3_TAGSET=${GTC_S3_TAGSET}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_CLOUD9_TAGSET=${GTC_CLOUD9_TAGSET}"; fi

    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_utility_tagset_get_values!"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
}