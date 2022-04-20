#!/bin/bash
#
# Usage:
#   gtc_aws_s3_key_pair_delete.sh
#   
# Arguments & Options:
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_aws_s3_key_pair_delete.sh
# 
# Debug Script:
#   
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
GTC_KEY_NAME=$(gtc_utility_get_key_name)
GTC_KEY_DIR=$(gtc_utility_get_key_dir)
GTC_KEY_FILE=$(gtc_utility_get_key_file)
GTC_S3_NAME=$(gtc_utility_get_s3_name)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_NAME=${GTC_KEY_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_DIR=${GTC_KEY_DIR}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_FILE=${GTC_KEY_FILE}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_FILE=${GTC_S3_NAME}"; fi

#if [ ! -e ${GTC_KEY_DIR} ]; then
#    echo "GoToCloud: [GCT_WARNING] Key directory ${GTC_KEY_DIR} does not exists. Normally, this should not happen!"
#    echo "GoToCloud: However, this does not cause any fatal problem and so continue by making key directory ${GTC_KEY_DIR}"
#    mkdir -p ${GTC_KEY_DIR}
#fi

echo "GoToCloud: Making sure that Key-pair '${GTC_KEY_NAME}' exist ..."
aws ec2 describe-key-pairs --key-name ${GTC_KEY_NAME} && {
    if [ -e ${GTC_KEY_FILE} ]; then
        echo "GoToCloud: Key-pair '${GTC_KEY_NAME}' and" 
        echo "GoToCloud: Key file '${GTC_KEY_FILE}' exist in your environment."
        echo "GoToCloud: Deleting Key-pair '${GTC_KEY_NAME}' and"
        echo "GoToCloud: key file '${GTC_KEY_FILE}' ..."
        aws ec2 delete-key-pair --key-name ${GTC_KEY_NAME}
        rm ${GTC_KEY_FILE}
        echo "GoToCloud: Deleted Key-pair '${GTC_KEY_NAME}' and"
        echo "GoToCloud: Key file '${GTC_KEY_FILE}'."
    else
        echo "GoToCloud: [GCT_WARNING] Only Key-pair '${GTC_KEY_NAME}' exists,"
        echo "GoToCloud: but key file '${GTC_KEY_FILE}' doesn't exist. Normally, this should not happen!"
        echo "GoToCloud: However, this does not cause any fatal problem and so only Key-pair '${GTC_KEY_NAME}' is deleted."
        echo "GoToCloud: Deleting Key-pair '${GTC_KEY_NAME}'."
        aws ec2 delete-key-pair --key-name ${GTC_KEY_NAME}
        echo "GoToCloud: Deleted Key-pair '${GTC_KEY_NAME}'."
    fi
} || {
    if [ -e ${GTC_KEY_FILE} ]; then
        echo "GoToCloud: [GCT_WARNING] Key file '${GTC_KEY_FILE}' exists in your environment,"
        echo "GoToCloud: but Key-pair '${GTC_KEY_NAME}' doesn't exist. Normally, this should not happen!" 
        echo "GoToCloud: However, this does not cause any fatal problem and so only Key file '${GTC_KEY_FILE}' is deleted."
        echo "GoToCloud: Deleting Key file '${GTC_KEY_FILE}' ..."
        rm ${GTC_KEY_FILE}
        echo "GoToCloud: Deleted Key file '${GTC_KEY_FILE}'."
    else
        echo "GoToCloud: [GCT_WARNING] Both Key-pair '${GTC_KEY_NAME}' and"
        echo "GoToCloud: Key file '${GTC_KEY_FILE}' don't exist."
    fi
}

echo "GoToCloud:"
echo "GoToCloud: Making sure that S3 bucket '${GTC_S3_NAME}' exists ..."
aws s3 ls s3://${GTC_S3_NAME} && {
    echo "GoToCloud: S3 bucket '${GTC_S3_NAME}' exists in your account."
    echo "GoToCloud: Deleting S3 bucket '${GTC_S3_NAME}'..."
    aws s3 rb s3://${GTC_S3_NAME} --force > /dev/null &
    pid=$!  #Process ID
    #echo "pid=${pid}"
    GTC_STATUS_CHECK_INTERVAL=30 # in seconds
    GTC_TIME_OUT=3600 # in seconds
    t0=`date +%s` # in seconds
    while :
    do
        #sleep ${GTC_STATUS_CHECK_INTERVAL}
        # Check if process is completed.
        echo "GoToCloud: DELETE_IN_PROGRESS"
        ps ${pid} > /dev/null || {
            break
        }
        sleep ${GTC_STATUS_CHECK_INTERVAL} 
        t1=`date +%s` # in seconds
        if [ $((t1-t0)) -gt ${GTC_TIME_OUT} ]; then
                echo "GoToCloud: [GCT_ERROR] GTC_TIME_OUT ${GTC_TIME_OUT} seconds"
                echo "GoToCloud: Exiting(1)..."
                exit 1
        fi
    done
    echo "GoToCloud: Deleted S3 backet '${GTC_S3_NAME}'."
} || {
    echo "GoToCloud: S3 backet '${GTC_S3_NAME}' doesn't exist in your account."
}

echo "GoToCloud:"
echo "GoToCloud: Done"