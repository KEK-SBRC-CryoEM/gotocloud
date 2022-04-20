#!/bin/bash
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
#   $ gtc_utility_get_iam_user_name
#   $ gtc_utility_get_method_name
#   $ gtc_utility_get_project_name
#   $ gtc_utility_get_account_id
#   $ gtc_utility_get_pcluster_name
#   $ gtc_utility_get_s3_name
#   $ gtc_utility_get_key_name
#   $ gtc_utility_get_key_dir
#   $ gtc_utility_get_key_file
#   $ gtc_utility_get_application_dir
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
    # Get GoToCloud meta info as global variables within file scope
    # i.e. GTC_IAM_USEAR_NAME GTC_METHOD_NAME GTC_PROJECT_NAME GTC_ACCOUNT_ID GTC_TAG_KEY_*
    gtc_utility_account_identity_get_values
    gtc_utility_project_name_get_values
    if [ ${GTC_PROJECT_NAME_INIT} == "cloud9-name" ]; then
        GTC_PROJECT_NAME=${GTC_CLOUD9_NAME};
    else
        GTC_PROJECT_NAME=${GTC_PROJECT_NAME_INIT};
    fi
    GTC_TAG_KEY_IAMUSER="iam-user"
    GTC_TAG_KEY_METHOD="method"
    GTC_TAG_KEY_PROJECT="project"
    GTC_TAG_KEY_ACCOUNT="account"
    GTC_METHOD_NAME="cryoem"
    GTC_PCLUSTER_NAME=${GTC_IAM_USEAR_NAME}-${GTC_ACCOUNT_ID}-${GTC_PROJECT_NAME}
    GTC_S3_NAME=${GTC_PCLUSTER_NAME}
    GTC_KEY_NAME=${GTC_PCLUSTER_NAME}
    GTC_SUBNET_NAME="kek-analysis-subnet4a"
    GTC_SUBNET_ID=$(aws ec2 describe-subnets | jq '.Subnets[]' | jq -r 'select(.Tags[]?.Value == "'${GTC_SUBNET_NAME}'").SubnetId')
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_IAMUSER=${GTC_TAG_KEY_IAMUSER}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_METHOD=${GTC_TAG_KEY_METHOD}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_PROJECT=${GTC_TAG_KEY_PROJECT}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_TAG_KEY_ACCOUNT=${GTC_TAG_KEY_ACCOUNT}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_METHOD_NAME=${GTC_METHOD_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_ACCOUNT_ID=${GTC_ACCOUNT_ID}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_S3_NAME=${GTC_S3_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_KEY_NAME=${GTC_KEY_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SUBNET_NAME=${GTC_SUBNET_NAME}"; fi
    if [[ ${GTC_SYSTEM_DEBUG_MODE} != 0 ]]; then echo "GoToCloud: [GTC_DEBUG] GTC_SUBNET_ID=${GTC_SUBNET_ID}"; fi

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
export GTC_SYSTEM_IAM_USEAR_NAME=XXX_GTC_IAM_USEAR_NAME_XXX
export GTC_SYSTEM_METHOD_NAME=XXX_GTC_METHOD_NAME_XXX
export GTC_SYSTEM_PROJECT_NAME=XXX_GTC_PROJECT_NAME_XXX
export GTC_SYSTEM_ACCOUNT_ID=XXX_GTC_ACCOUNT_ID_XXX
export GTC_SYSTEM_PCLUSTER_NAME=XXX_GTC_PCLUSTER_NAME_XXX
export GTC_SYSTEM_S3_NAME=XXX_GTC_S3_NAME_XXX
export GTC_SYSTEM_KEY_NAME=XXX_GTC_KEY_NAME_XXX
export GTC_SYSTEM_SUBNET_NAME=XXX_GTC_SUBNET_NAME_XXX
export GTC_SYSTEM_SUBNET_ID=XXX_GTC_SUBNET_ID_XXX
export GTC_SYSTEM_KEY_DIR=XXX_GTC_KEY_DIR_XXX
export GTC_SYSTEM_KEY_FILE=XXX_GTC_KEY_FILE_XXX
export GTC_SYSTEM_APPLICATION_DIR=XXX_GTC_APPLICATION_DIR_XXX
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
    # XXX_GTC_TAG_KEY_ACCOUNT_XXX -> ${GTC_TAG_KEY_PROJECT}
    sed -i "s@XXX_GTC_TAG_KEY_ACCOUNT_XXX@${GTC_TAG_KEY_ACCOUNT}@g" ${GTC_GLOBAL_VARIABLES_FILE}
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
    # XXX_GTC_SUBNET_NAME_XXX -> ${GTC_SUBNET_NAME}
    sed -i "s@XXX_GTC_SUBNET_NAME_XXX@${GTC_SUBNET_NAME}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_SUBNET_NAME_XXX -> ${GTC_SUBNET_NAME}
    sed -i "s@XXX_GTC_SUBNET_ID_XXX@${GTC_SUBNET_ID}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_KEY_DIR_XXX -> ${GTC_KEY_DIR}
    sed -i "s@XXX_GTC_KEY_DIR_XXX@${GTC_KEY_DIR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_KEY_FILE_XXX -> ${GTC_KEY_FILE}
    sed -i "s@XXX_GTC_KEY_FILE_XXX@${GTC_KEY_FILE}@g" ${GTC_GLOBAL_VARIABLES_FILE}
    # XXX_GTC_APPLICATION_DIR_XXX -> ${GTC_APPLICATION_DIR}
    sed -i "s@XXX_GTC_APPLICATION_DIR_XXX@${GTC_APPLICATION_DIR}@g" ${GTC_GLOBAL_VARIABLES_FILE}
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

function gtc_utility_get_global_varaibles_file() {
    echo ${GTC_SYSTEM_GLOBAL_VARIABLES_FILE}
}

function gtc_utility_get_debug_mode() {
    echo ${GTC_SYSTEM_DEBUG_MODE}
}

