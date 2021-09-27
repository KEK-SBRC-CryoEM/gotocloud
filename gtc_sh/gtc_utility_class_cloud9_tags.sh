#!/bin/bash
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
