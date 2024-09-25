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
# GTC_TAG_KEY_IAMUSER=$(gtc_utility_get_tag_key_iamuser)
# GTC_TAG_KEY_METHOD=$(gtc_utility_get_tag_key_method)
# GTC_TAG_KEY_PROJECT=$(gtc_utility_get_tag_key_project)
# GTC_TAG_KEY_ACCOUNT=$(gtc_utility_get_tag_key_account)
# GTC_IAM_USEAR_NAME=$(gtc_utility_get_iam_user_name)
# GTC_METHOD_NAME=$(gtc_utility_get_method_name)
# GTC_PROJECT_NAME=$(gtc_utility_get_project_name)
# GTC_ACCOUNT_ID=$(gtc_utility_get_account_id)
GTC_S3_NAME=$(gtc_utility_get_s3_name)

# call GTC_S3_TAGSET
gtc_utility_tagset_get_values
GTC_S3_TAGSET=${GTC_S3_TAGSET}
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_IAMUSER=${GTC_TAG_KEY_IAMUSER}"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_METHOD=${GTC_TAG_KEY_METHOD}"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_PROJECT=${GTC_TAG_KEY_PROJECT}"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_ACCOUNT=${GTC_TAG_KEY_ACCOUNT}"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
# if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_ACCOUNT_ID=${GTC_ACCOUNT_ID}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_S3_NAME=${GTC_S3_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_S3_TAGSET=${GTC_S3_TAGSET}"; fi

GTC_S3_WARNING=0
echo "GoToCloud: Making sure that S3 bucket ${GTC_S3_NAME} does not exist yet..."
aws s3 ls s3://${GTC_S3_NAME} && {
    echo "GoToCloud: S3 bucket ${GTC_S3_NAME} exists already in your account"
    #echo "GoToCloud: Done"
    exit 0
}

echo "GoToCloud: OK! S3 bucket ${GTC_S3_NAME} does not exist yet!"

echo "GoToCloud: Creating S3 bucket ${GTC_S3_NAME}..."
aws s3 mb s3://${GTC_S3_NAME} || {
    echo "GoToCloud: [GCT_ERROR] Project name ${GTC_PROJECT_NAME} may be invalid or same bucket name is used already"
    echo "GoToCloud: Exiting(1)..."
    exit 1
}

echo "GoToCloud: Settings tags to S3 bucket ${GTC_S3_NAME}..."
aws s3api put-bucket-tagging --bucket ${GTC_S3_NAME} --tagging "${GTC_S3_TAGSET}"
aws s3api put-public-access-block --bucket ${GTC_S3_NAME}  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "GoToCloud: Created S3 backet ${GTC_S3_NAME}"
#echo "GoToCloud: Done"
