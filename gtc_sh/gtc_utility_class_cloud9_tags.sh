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
#   $ source gtc_utility_class_cloud9_tags.sh
#   OR
#   $ . gtc_utility_class_cloud9_tags.sh
#   
#   Then,
#   $ gtc_class_get_cloud9_tags_values
#  
# Debug Script:
#   gtc_utility_class_cloud9_tags_debug.sh

# Define global variables within file scope (for read ability...)
GTC_IAM_USEAR_NAME=GTC_INVALID
GTC_METHOD_NAME=GTC_INVALID
GTC_PROJECT_NAME=GTC_INVALID

# Set GTC_IAM_USEAR_NAME GTC_METHOD_NAME GTC_PROJECT_NAME
function gtc_utility_class_cloud9_tags_get_values() {
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_utility_class_cloud9_tags_get_values!"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    
    # Get tags values from this Cloud9 instance
    local GTC_TAGS=$(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) | jq -r '.Reservations[].Instances[].Tags[]')
    # echo "GoToCloud: [GTC_DEBUG] GTC_TAGS=${GTC_TAGS}"
    
    # Extract values of keys
    GTC_IAM_USEAR_NAME=`echo ${GTC_TAGS} | jq -r 'select(.Key == "iam-user").Value'`
    GTC_METHOD_NAME=`echo ${GTC_TAGS} | jq -r 'select(.Key == "method").Value'`
    GTC_PROJECT_NAME=`echo ${GTC_TAGS} | jq -r 'select(.Key == "project").Value'`
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
    
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_utility_class_cloud9_tags_get_values!"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
}
