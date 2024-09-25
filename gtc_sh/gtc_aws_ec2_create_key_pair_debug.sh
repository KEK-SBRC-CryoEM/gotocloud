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
# Debug script for gtc_aws_ec2_create_key_pair.sh
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS_GET
export GTC_SYSTEM_DEBUG_MODE=1
gtc_aws_ec2_create_key_pair_debug.sh

DEBUG_COMMANDS_GET
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

# Load gtc_utility_global_varaibles shell functions
source gtc_utility_global_varaibles.sh
# . gtc_utility_global_varaibles.sh
# Get related global variables
GTC_KEY_NAME=$(gtc_utility_get_key_name)
GTC_KEY_FILE=$(gtc_utility_get_key_file)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_NAME=${GTC_KEY_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_FILE=${GTC_KEY_FILE}"; fi
echo "GoToCloud: "

# NOTE (2021/07/27 Toshio Moriya): I could not find any aws command to list all available key-paris

echo "GoToCloud: Checking if key-pair ${GTC_KEY_NAME} exists already"
aws ec2 describe-key-pairs --key-name ${GTC_KEY_NAME} && {
    echo "GoToCloud: [GCT_WARNING] Key-pair ${GTC_KEY_NAME} exists already!"
    echo "GoToCloud: Deleting for debug..."
    aws ec2 delete-key-pair --key-name ${GTC_KEY_NAME}
}
echo "GoToCloud: Key-pair ${GTC_KEY_NAME} does not exist at this point!"
echo "GoToCloud: "

echo "GoToCloud: Checking if key file ${GTC_KEY_FILE} exists already"
if [ -e ${GTC_KEY_FILE} ]; then
    echo "GoToCloud: [GCT_WARNING] Key file ${GTC_KEY_FILE} exists already!"
    echo "GoToCloud: Check file permissions of existing key file ${GTC_KEY_FILE}!"
    ls -l ${GTC_KEY_FILE}
    echo "GoToCloud: Check contents of existing key file ${GTC_KEY_FILE}!"
    echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    cat ${GTC_KEY_FILE}
    echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echo "GoToCloud: Deleting for debug..."
    rm ${GTC_KEY_FILE}
fi

echo "GoToCloud: Key file ${GTC_KEY_FILE} does not exist at this point!"
echo "GoToCloud: "

# The shell script ckecks if the 
echo "GoToCloud: Running gtc_aws_ec2_create_key_pair.sh..."
echo "GoToCloud: "
gtc_aws_ec2_create_key_pair.sh
echo "GoToCloud: "
echo "GoToCloud: Returned from gtc_aws_ec2_create_key_pair.sh."
echo "GoToCloud: "

# NOTE (2021/07/27 Toshio Moriya): I could not find any aws command to list all available key-paris

echo "GoToCloud: Checking if key-pair ${GTC_KEY_NAME} created successfully"
aws ec2 describe-key-pairs --key-name ${GTC_KEY_NAME} || {
    echo "GoToCloud: GTC_UNIT_TEST_FAIL"
    echo "GoToCloud: Failed to create key-pair ${GTC_KEY_NAME}."
    echo "GoToCloud: Do debug again, DUDE!!!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
}

echo "GoToCloud: Checking if key file ${GTC_KEY_FILE} created successfully"
if [ ! -e ${GTC_KEY_FILE} ]; then
    echo "GoToCloud: GTC_UNIT_TEST_FAIL"
    echo "GoToCloud: Failed to create key file ${GTC_KEY_FILE} created."
    echo "GoToCloud: Do debug again, DUDE!!!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

echo "GoToCloud: Check file permissions of created key file ${GTC_KEY_FILE}!"
ls -l ${GTC_KEY_FILE}
echo "GoToCloud: Check contents of created key file ${GTC_KEY_FILE}!"
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cat ${GTC_KEY_FILE}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

echo "GoToCloud: GTC_UNIT_TEST_SUCCESS"
echo "GoToCloud: Key-pair ${GTC_KEY_NAME} and key file ${GTC_KEY_FILE} are successfully created!"
echo "GoToCloud: "

echo "GoToCloud: Checking an exception where key-pair ${GTC_KEY_NAME} exists already..."
echo "GoToCloud: "

# The shell script ckecks if the 
echo "GoToCloud: Running gtc_aws_ec2_create_key_pair.sh..."
echo "GoToCloud: "
gtc_aws_ec2_create_key_pair.sh
GTC_STATUS=$?
echo "GoToCloud: "
echo "GoToCloud: Returned from gtc_aws_ec2_create_key_pair.sh with status ${GTC_STATUS}"
echo "GoToCloud: "

echo "GoToCloud: Checking if the target script $0 handled the exception successfully"
if [[ ${GTC_STATUS} != 0 ]]; then
    echo "GoToCloud: GTC_UNIT_TEST_FAIL"
    echo "GoToCloud: DUDE, do debug again!!!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

if [ ! -e ${GTC_KEY_FILE} ]; then
    echo "GoToCloud: GTC_UNIT_TEST_FAIL"
    echo "GoToCloud: Do debug again, DUDE!!!"
    echo "GoToCloud: Exiting(1)..."
    exit 1
fi

echo "GoToCloud: Check file permissions of created key file ${GTC_KEY_FILE}!"
ls -l ${GTC_KEY_FILE}
echo "GoToCloud: Check contents of created key file ${GTC_KEY_FILE}!"
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cat ${GTC_KEY_FILE}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

echo "GoToCloud: GTC_UNIT_TEST_SUCCESS"
echo "GoToCloud: Key-pair ${GTC_KEY_NAME} and key file ${GTC_KEY_FILE} are still there as it should be!"

echo "GoToCloud: Deleting key-pair ${GTC_KEY_NAME} just created with this debug script..."
aws ec2 delete-key-pair --key-name ${GTC_KEY_NAME}
echo "GoToCloud: Deleting key file ${GTC_KEY_FILE} just created with this debug script..."
rm ${GTC_KEY_FILE}


echo "GoToCloud: Done"
