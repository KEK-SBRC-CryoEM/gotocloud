#!/bin/bash
#
# Usage:
#   gtc_setup_cloud9_environment.sh
#   
# Arguments & Options:
#   -p                 : Project name (default "`date`session")
#   -h                 : Help option displays usage
#   
# Examples:
#   $ /efs/em/gtc_sh_ver00/gtc_setup_cloud9_environment.sh
# 
# Debug Script:
#   gtc_setup_cloud9_environment_debug.sh
# 
# Developer Notes:
#   [2021/0725 Toshio Moriya]
#   Considered following specification but rejected.
#   Usage:
#     gtc_setup_env_vars_on_cloud9.sh  -s GTC_SH_DIR  -d GTC_DEBUG_MODE
#   
#   Arguments & Options:
#     -s GTC_SH_DIR      : GoToCloud shell script direcctory path. e.g. "/efs/em/gtc_sh_ver00/". (default "/efs/em/gtc_sh")
#     -d GTC_DEBUG_MODE  : GoToCloud debug mode. 0 (off) or 1 (on)  (default 0 (off))
#     
#     -h                 : Help option displays usage

if [ ! -z $GTC_SYSTEM_DEBUG_MODE ]; then 
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SYSTEM_DEBUG_MODE is set to ${GTC_SYSTEM_DEBUG_MODE} already!"; fi
else 
    # GTC_SYSTEM_DEBUG_MODE is not set yet!
    export GTC_SYSTEM_DEBUG_MODE=0
fi

if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Hello gtc_setup_cloud9_environment.sh"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi

usage_exit() {
        echo "GoToCloud: Usage $0" 1>&2
        echo "GoToCloud: Exiting(1)..."
        exit 1
}

# Check if the number of command line arguments is valid
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] @=$@"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] #=$#"; fi
if [[ $# -gt 2 ]]; then
    echo "GoToCloud: Invalid number of arguments ($#)"
    usage_exit
fi

# Initialize variables with default values
GTC_PROJECT_NAME=`date "+%Y%m%d"`"session"
# Parse command line arguments
while getopts p:h OPT
do
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] OPT=$OPT"; fi
    case "$OPT" in
        p)  GTC_PROJECT_NAME=$OPTARG
            echo "GoToCloud: project name '${GTC_PROJECT_NAME}' is specified"
            ;;
        h)  usage_exit
            ;;
        \?) echo "GoToCloud: [GTC_ERROR] Invalid option $OPTARG is specified!"
            usage_exit
            ;;
    esac
done

# GoToCloud shell script direcctory path
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] 0 = $0"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] dirname $0 = $(dirname $0)"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] pwd = $(pwd)"; fi
GTC_SH_DIR=`cd $(dirname ${0}) && pwd`
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SH_DIR=${GTC_SH_DIR}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] pwd = $(pwd)"; fi

# Setup Cloud9 environment for GoToCloud (mainly systemwise environment global variables)
echo "GoToCloud: Calling gtc_utility_setup_global_variables..."
# First import gtc_utility_global_varaibles shell utility functions
source ${GTC_SH_DIR}/gtc_utility_global_varaibles.sh
# . ${GTC_SH_DIR}/gtc_utility_global_varaibles.sh
# Then call gtc_utility_setup_global_variables function
gtc_utility_setup_global_variables

if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then 
# 
    echo "GoToCloud: [GTC_DEBUG] "
    echo "GoToCloud: [GTC_DEBUG] At this point, get functions in gtc_utility_global_varaibles.sh should be usable within file scope of this script file"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_sh_dir = $(gtc_utility_get_sh_dir)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_tag_key_iamuser = $(gtc_utility_get_tag_key_iamuser)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_tag_key_method = $(gtc_utility_get_tag_key_method)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_tag_key_project = $(gtc_utility_get_tag_key_project)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_tag_key_account = $(gtc_utility_get_tag_key_account)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_iam_user_name = $(gtc_utility_get_iam_user_name)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_method_name = $(gtc_utility_get_method_name)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_project_name = $(gtc_utility_get_project_name)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_account_id = $(gtc_utility_get_account_id)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_pcluster_name = $(gtc_utility_get_pcluster_name)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_s3_name = $(gtc_utility_get_s3_name)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_key_name = $(gtc_utility_get_key_name)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_key_dir = $(gtc_utility_get_key_dir)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_key_file = $(gtc_utility_get_key_file)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_application_dir = $(gtc_utility_get_application_dir)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_global_varaibles_file = $(gtc_utility_get_global_varaibles_file)"
    echo "GoToCloud: [GTC_DEBUG] gtc_utility_get_debug_mode = $(gtc_utility_get_debug_mode)"
    echo "GoToCloud: [GTC_DEBUG] "
fi

GTC_BASHRC=${HOME}/.bashrc
if [ -e ${GTC_BASHRC} ]; then
    GTC_APPLICATION_DIR=$(gtc_utility_get_application_dir)
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_APPLICATION_DIR=${GTC_APPLICATION_DIR}"; fi
    GTC_BASHRC_BACKUP=${GTC_APPLICATION_DIR}/.bashrc_backup_`date "+%Y%m%d_%H%M%S"`
    echo "GoToCloud: Making a backup of previous ${GTC_BASHRC} as ${GTC_BASHRC_BACKUP}..."
    cp ${GTC_BASHRC} ${GTC_BASHRC_BACKUP}
else
    echo "GoToCloud: [GTC_WARNING] ${GTC_BASHRC} does not exist on this system. Normally, this should not happen!"
fi

echo "GoToCloud: Appending GoToCloud system environment variable settings to ${GTC_BASHRC}..."
GTC_GLOBAL_VARIABLES_FILE=$(gtc_utility_get_global_varaibles_file)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_GLOBAL_VARIABLES_FILE=${GTC_GLOBAL_VARIABLES_FILE}"; fi
# cat > ${GTC_BASHRC} <<'EOS' suppresses varaible replacements 
# cat > ${GTC_BASHRC} <<EOS allows varaible replacements 
cat >> ${GTC_BASHRC} <<EOS

#  GoToCloud system environment variables
source ${GTC_GLOBAL_VARIABLES_FILE}
EOS

echo "GoToCloud: "
echo "GoToCloud: To applying GoToCloud system environment variables, open a new terminal. "
echo "GoToCloud: OR use the following command in this session:"
echo "GoToCloud: "
echo "GoToCloud:   source ${GTC_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: "
echo "GoToCloud: Done"

# Setup tags to Cloud9
# Get related global variables
GTC_TAG_KEY_IAMUSER=$(gtc_utility_get_tag_key_iamuser)
GTC_TAG_KEY_METHOD=$(gtc_utility_get_tag_key_method)
GTC_TAG_KEY_PROJECT=$(gtc_utility_get_tag_key_project)
GTC_TAG_KEY_ACCOUNT=$(gtc_utility_get_tag_key_account)
GTC_IAM_USEAR_NAME=$(gtc_utility_get_iam_user_name)
GTC_METHOD_NAME=$(gtc_utility_get_method_name)
GTC_PROJECT_NAME=$(gtc_utility_get_project_name)
GTC_ACCOUNT_ID=$(gtc_utility_get_account_id)
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_IAMUSER=${GTC_TAG_KEY_IAMUSER}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_METHOD=${GTC_TAG_KEY_METHOD}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_PROJECT=${GTC_TAG_KEY_PROJECT}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_TAG_KEY_ACCOUNT=${GTC_TAG_KEY_ACCOUNT}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GCT_DEBUG] GTC_ACCOUNT_ID=${GTC_ACCOUNT_ID}"; fi

echo "GoToCloud: Settings tags to Cloud9..."
GTC_CLOUD9_INSTANCE_ID=$(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) | jq -r '.Reservations[].Instances[].InstanceId')
echo "GoToCloud: Cloud9 Instance ID: ${GTC_CLOUD9_INSTANCE_ID}"
aws ec2 create-tags --resources ${GTC_CLOUD9_INSTANCE_ID} --tags Key=${GTC_TAG_KEY_METHOD},Value=${GTC_METHOD_NAME} Key=${GTC_TAG_KEY_PROJECT},Value=${GTC_PROJECT_NAME} Key=${GTC_TAG_KEY_IAMUSER},Value=${GTC_IAM_USEAR_NAME} Key=${GTC_TAG_KEY_ACCOUNT},Value=${GTC_ACCOUNT_ID} || {
    echo "GoToCloud: [GCT_WARNING] Failed to setup Cloud9 tags."
    echo "GoToCloud: Exiting(1)..."
    exit 1
}

#echo "GoToCloud: Done"


if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] "; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] Good-bye gtc_setup_cloud9_environment.sh!"; fi
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] --------------------------------------------------"; fi
