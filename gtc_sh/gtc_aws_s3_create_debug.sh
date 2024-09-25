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
# Debug script for gtc_aws_s3_create.sh
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS_GET
export GTC_SYSTEM_DEBUG_MODE=1
gtc_aws_s3_create_debug.sh

DEBUG_COMMANDS_GET
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

# Load gtc_utility_global_varaibles shell functions
source gtc_utility_global_varaibles.sh
# Get related global variables
GTC_S3_NAME=$(gtc_utility_get_s3_name)
echo "GoToCloud: GTC_S3_NAME=${GTC_S3_NAME}"
echo "GoToCloud: "

# List all available S3 buckets
echo "GoToCloud: aws s3 ls"
aws s3 ls
echo "GoToCloud: "

echo "GoToCloud: Checking if S3 bucket ${GTC_S3_NAME} exists already"
if [[ $(aws s3 ls | grep ${GTC_S3_NAME} | wc -l) > 0 ]]; then
    echo "GoToCloud: S3 bucket ${GTC_S3_NAME} exists already!"
    
    echo "GoToCloud: aws s3 ls s3://${GTC_S3_NAME}"
    aws s3 ls s3://${GTC_S3_NAME}
    echo "GoToCloud: "
    
    echo "GoToCloud: aws s3api get-bucket-tagging --bucket ${GTC_S3_NAME}"
    aws s3api get-bucket-tagging --bucket ${GTC_S3_NAME}
    echo "GoToCloud: "
    
    echo "GoToCloud: Deleting for debug..."
    aws s3 rb s3://${GTC_S3_NAME}
fi
echo "GoToCloud: S3 bucket ${GTC_S3_NAME} does not exist at this point!"
echo "GoToCloud: "

# The shell script ckecks if the 
echo "GoToCloud: Running gtc_aws_s3_create.sh..."
echo "GoToCloud: "
gtc_aws_s3_create.sh
echo "GoToCloud: "
echo "GoToCloud: Returned from gtc_aws_s3_create.sh."
echo "GoToCloud: "

# List all available S3 buckets
echo "GoToCloud: aws s3 ls"
aws s3 ls
echo "GoToCloud: "

echo "GoToCloud: Checking if S3 bucket ${GTC_S3_NAME} created successfully"
if [[ $(aws s3 ls | grep ${GTC_S3_NAME} | wc -l) == 0 ]]; then
    echo "GoToCloud: GTC_UNIT_TEST_FAIL"
    echo "GoToCloud: Failed to create S3 bucket ${GTC_S3_NAME}."
    echo "GoToCloud: Do debug again, DUDE!!!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

echo "GoToCloud: GTC_UNIT_TEST_SUCCESS"
echo "GoToCloud: S3 bucket ${GTC_S3_NAME} is successfully created!"
echo "GoToCloud: "

echo "GoToCloud: aws s3 ls s3://${GTC_S3_NAME}"
aws s3 ls s3://${GTC_S3_NAME}
echo "GoToCloud: "

echo "GoToCloud: aws s3api get-bucket-tagging --bucket ${GTC_S3_NAME}"
aws s3api get-bucket-tagging --bucket ${GTC_S3_NAME}
echo "GoToCloud: "

echo "GoToCloud: Checking an exception where S3 bucket ${GTC_S3_NAME} exists already..."

# The shell script ckecks if the 
echo "GoToCloud: Running gtc_aws_s3_create.sh..."
echo "GoToCloud: "
gtc_aws_s3_create.sh
GTC_STATUS=$?
echo "GoToCloud: "
echo "GoToCloud: Returned from gtc_aws_s3_create.sh with status ${GTC_STATUS}"
echo "GoToCloud: "

aws s3 ls | grep ${GTC_S3_NAME}

echo "GoToCloud: Checking if the target script $0 handled the exception successfully"
if [[ $(aws s3 ls | grep ${GTC_S3_NAME} | wc -l) == 0 || ${GTC_STATUS} != 0 ]]; then
    echo "GoToCloud: GTC_UNIT_TEST_FAIL"
    echo "GoToCloud: DUDE, do debug again!!!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

echo "GoToCloud: GTC_UNIT_TEST_SUCCESS"
echo "GoToCloud: S3 bucket ${GTC_S3_NAME} is still there as it should be!"

echo "GoToCloud: Deleting S3 bucket ${GTC_S3_NAME} just created with this debug script..."
aws s3 rb s3://${GTC_S3_NAME}

echo "GoToCloud: Done"
