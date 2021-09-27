#!/bin/bash
# 
# Debug script for gtc_utility_global_varaibles.sh
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS_SETUP
export GTC_SYSTEM_DEBUG_MODE=1
/efs/em/gtc_sh_ver00/gtc_utility_global_varaibles_debug_setup.sh GTC_RESTORE

# When you want to test the case where .gtc exists already
# do the following once before the above procedure
/efs/em/gtc_sh_ver00/gtc_utility_global_varaibles_debug_setup.sh GTC_NO_RESTORE

# Check current values of GoToCloud sytemwise environment variables from global scope
echo "GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"

ls -al ~/
ls -al ~/.gtc
ls -al ~/.gtc/global_variables.sh
cat ~/.gtc/global_variables.sh

# Do this when GTC_SYSTEM environment variables are set already
unset GTC_SYSTEM_SH_DIR
unset GTC_SYSTEM_IAM_USEAR_NAME
unset GTC_SYSTEM_METHOD_NAME
unset GTC_SYSTEM_PROJECT_NAME
unset GTC_SYSTEM_PCLUSTER_NAME
unset GTC_SYSTEM_S3_NAME
unset GTC_SYSTEM_KEY_NAME
unset GTC_SYSTEM_KEY_DIR
unset GTC_SYSTEM_KEY_FILE
unset GTC_SYSTEM_APPLICATION_DIR
unset GTC_SYSTEM_GLOBAL_VARIABLES_FILE

# When this shell script exit with error
# Do the following roll-back
ls -al ~/
ls -al ~/.gtc
ls -al /home/ec2-user/.gtc/global_variables.sh
cat 
rm -r ~/.gtc

DEBUG_COMMANDS_SETUP
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS_GET
export GTC_SYSTEM_DEBUG_MODE=1
/efs/em/gtc_sh_ver00/gtc_utility_global_varaibles_debug_setup.sh GTC_NO_RESTORE
/efs/em/gtc_sh_ver00/gtc_utility_global_varaibles_debug_get.sh

DEBUG_COMMANDS_GET
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

# Obtaine GoToCloud shell script directory path from this command line
# Target script file must be in the same directory!
GTC_SH_DIR=`cd $(dirname $0) && pwd`
echo "GoToCloud: GTC_SH_DIR=${GTC_SH_DIR}"
echo "GoToCloud: "

GTC_APPLICATION_DIR=${HOME}/.gtc
echo "GoToCloud: GTC_APPLICATION_DIR=${GTC_APPLICATION_DIR}"
GTC_APPLICATION_DIR_DEBUG_ORIGINAL=${HOME}/.gtc_debug_original
echo "GoToCloud: GTC_APPLICATION_DIR_DEBUG_ORIGINAL=${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}"
if [ -e ${GTC_APPLICATION_DIR} ]; then
    echo "GoToCloud: ${GTC_APPLICATION_DIR} exists already!"
    echo "GoToCloud: Temporarily moving ${GTC_APPLICATION_DIR} to ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}"
    mv ${GTC_APPLICATION_DIR} ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}
fi

# Call gtc_utility_setup_global_variables
echo "GoToCloud: Calling gtc_utility_setup_global_variables..."
echo "GoToCloud: "
# First import gtc_utility_global_varaibles shell functions
source ${GTC_SH_DIR}/gtc_utility_global_varaibles.sh
# . ${GTC_SH_DIR}/gtc_utility_global_varaibles.sh
# Then call gtc_utility_setup_global_variables function
gtc_utility_setup_global_variables
echo "GoToCloud: "
echo "GoToCloud: Returned from gtc_utility_setup_global_variables"
echo "GoToCloud: "

GTC_GLOBAL_VARIABLES_FILE=${GTC_APPLICATION_DIR}/global_variables.sh
echo "GoToCloud: Check contents of ${GTC_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cat ${GTC_GLOBAL_VARIABLES_FILE}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: Check current values of GoToCloud sytemwise environment variables from this file scope..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GoToCloud: GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GoToCloud: GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"
echo "GoToCloud: GTC_SYSTEM_PCLUSTER_NAME=${GTC_SYSTEM_PCLUSTER_NAME}"
echo "GoToCloud: GTC_SYSTEM_S3_NAME=${GTC_SYSTEM_S3_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_NAME=${GTC_SYSTEM_KEY_NAME}"
echo "GoToCloud: GTC_SYSTEM_KEY_DIR=${GTC_SYSTEM_KEY_DIR}"
echo "GoToCloud: GTC_SYSTEM_KEY_FILE=${GTC_SYSTEM_KEY_FILE}"
echo "GoToCloud: GTC_SYSTEM_APPLICATION_DIR=${GTC_SYSTEM_APPLICATION_DIR}"
echo "GoToCloud: GTC_SYSTEM_GLOBAL_VARIABLES_FILE=${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: GTC_BACKUP_OPTION=$1"
if [[ $1 == GTC_NO_RESTORE ]]; then
    if [ -e ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL} ]; then
        echo "GoToCloud: Deleting stored original directory ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}..."
        rm -r ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}
    fi
else
    echo "GoToCloud: Deleting directory ${GTC_APPLICATION_DIR} just created with this debug run..."
    rm -r ${GTC_APPLICATION_DIR}
    if [ -e ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL} ]; then
        echo "GoToCloud: Restoring directory ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL} as ${GTC_APPLICATION_DIR}"
        mv ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL} ${GTC_APPLICATION_DIR}
    fi
fi


echo "GoToCloud: Done"
