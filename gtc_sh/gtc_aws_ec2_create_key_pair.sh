#!/bin/bash
#
# Usage:
#   gtc_aws_ec2_create_key_pair.sh
#   
# Arguments & Options:
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_aws_ec2_create_key_pair.sh
# 
# Debug Script:
#   gtc_aws_ec2_create_key_pair_debug.sh
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
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_NAME=${GTC_KEY_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_DIR=${GTC_KEY_DIR}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_KEY_FILE=${GTC_KEY_FILE}"; fi

if [ ! -e ${GTC_KEY_DIR} ]; then
    echo "GoToCloud: [GCT_WARNING] Key directory ${GTC_KEY_DIR} does not exists. Normally, this should not happen!"
    echo "GoToCloud: However, this does not cause any fatal problem and so continue by making key directory ${GTC_KEY_DIR}"
    mkdir -p ${GTC_KEY_DIR}
fi

echo "GoToCloud: Making sure that Key-pair ${GTC_KEY_NAME} does not exist yet..."
aws ec2 describe-key-pairs --key-name ${GTC_KEY_NAME} && {
    if [ -e ${GTC_KEY_FILE} ]; then
        echo "GoToCloud: Key file ${GTC_KEY_FILE} exists already in your environment!"
        #echo "GoToCloud: Done"
        exit 0
    else
        echo "GoToCloud: [GCT_WARNING] Key-pair ${GTC_KEY_NAME} exists already! Failed to create key file."
        echo "GoToCloud: Exiting(1)..."
        exit 1
    fi
} || {
    if [ -e ${GTC_KEY_FILE} ]; then
        echo "GoToCloud: Key file ${GTC_KEY_FILE} exists already in your environment, but Key-pair ${GTC_KEY_NAME} dosen't exist. Failed to create key-pair." 
        exit 1
    fi
}

echo "GoToCloud: OK! Key-pair ${GTC_KEY_NAME} does not exist yet!"

echo "GoToCloud: Generating Key-pair ${GTC_KEY_NAME}..."
aws ec2 create-key-pair --key-name ${GTC_KEY_NAME} --region ap-northeast-1 --query 'KeyMaterial' --output text > ${GTC_KEY_FILE} || {
    echo "GoToCloud: [GCT_WARNING] Key-pair ${GTC_KEY_NAME} exists already! Failed to create key file."
    echo "GoToCloud: Exiting(1)..."
    exit 1
}
chmod 600 ${GTC_KEY_FILE}

echo "GoToCloud: Saved Key file as ${GTC_KEY_FILE}"
#echo "GoToCloud: Done"
