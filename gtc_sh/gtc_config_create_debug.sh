#!/bin/bash
# 
# Debug script for gtc_config_create.sh
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS_GET
# [*] IMPORTANT! Do this ONLY-ONCE before starting debugging!
ls -al ~/.parallelcluster
rm ~/.parallelcluster/config
rm ~/.parallelcluster/config_*
ls -al ~/.parallelcluster

# [*] Run debug script
export GTC_SYSTEM_DEBUG_MODE=1
gtc_config_create_debug.sh

# [*] Check error cases manyally
export GTC_SYSTEM_DEBUG_MODE=0
gtc_config_create.sh -h
gtc_config_create.sh -s 1200 -m 2 -i 00 -s 2400
gtc_config_create.sh -s 1200 -m 2 -i 00  -h
gtc_config_create.sh -s 1200 -i 00 -h

DEBUG_COMMANDS_GET
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

# Define global constant within this file scope
GTC_CONFIG_DIR=${HOME}/.parallelcluster
echo "GoToCloud: GTC_CONFIG_DIR=${GTC_CONFIG_DIR}"

# Initialize global variables with default values within this file scope
GTC_CMD_TARGET="gtc_config_create.sh"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config
echo "GoToCloud: GTC_CMD_TARGET=${GTC_CMD_TARGET}"
echo "GoToCloud: GTC_CONFIG_FILE=${GTC_CONFIG_FILE}"

GTC_CMD_SHOW_CONFIG_ALL=1
GTC_CHECK_REPEATED_RUN=0

function gtc_config_create_debug_case() {
    echo "GoToCloud: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "GoToCloud: Start testing ${GTC_CMD_TARGET}"
    echo "GoToCloud: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
    echo "GoToCloud: GTC_CMD_SHOW_CONFIG_ALL=${GTC_CMD_SHOW_CONFIG_ALL}"
    echo "GoToCloud: GTC_CHECK_REPEATED_RUN=${GTC_CHECK_REPEATED_RUN}"
    echo "GoToCloud: "

    GTC_CONFIG_FILE_DEBUG_ORIGINAL=${GTC_CONFIG_FILE}_debug_original
    echo "GoToCloud: GTC_CONFIG_FILE=${GTC_CONFIG_FILE}"
    echo "GoToCloud: GTC_CONFIG_FILE_DEBUG_ORIGINAL=${GTC_CONFIG_FILE_DEBUG_ORIGINAL}"
    echo "GoToCloud: "
    
    echo "GoToCloud: ========================================================================="
    echo "GoToCloud: Preparation"
    echo "GoToCloud: ========================================================================="
    
    echo "GoToCloud: -------------------------------------------------------------------------"
    echo "GoToCloud: Store original config file ${GTC_CONFIG_FILE} if necessary"
    echo "GoToCloud: -------------------------------------------------------------------------"
    
    echo "GoToCloud: Checking if config directory ${GTC_CONFIG_DIR} exists already"
    if [ -e ${GTC_CONFIG_DIR} ]; then
        echo "GoToCloud: Config directory ${GTC_CONFIG_DIR} exists already as it should!"
        echo "GoToCloud: Check the contents of ${GTC_CONFIG_DIR}!"
        echo "GoToCloud: ls -l ${GTC_CONFIG_DIR}"
        ls -l ${GTC_CONFIG_DIR}
        if [ -e ${GTC_CONFIG_FILE} ]; then
            ### echo "GoToCloud: Check contents of existing config file ${GTC_CONFIG_FILE}!"
            ### echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            ### cat ${GTC_CONFIG_FILE}
            ### echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo "GoToCloud: Temporarily rename original ${GTC_CONFIG_FILE} to ${GTC_CONFIG_FILE_DEBUG_ORIGINAL}..."
            mv ${GTC_CONFIG_FILE} ${GTC_CONFIG_FILE_DEBUG_ORIGINAL}
        else
            echo "GoToCloud: Config file ${GTC_CONFIG_FILE} does not exist yet!"
        fi
    fi
    
    echo "GoToCloud: ========================================================================="
    echo "GoToCloud: Run the target script"
    echo "GoToCloud: ========================================================================="
    echo "GoToCloud: Creating config with following commands..."
    echo "GoToCloud: "
    echo "GoToCloud: ${GTC_CMD_TARGET}"
    echo "GoToCloud: "
    ${GTC_CMD_TARGET}
    
    if [[ ${GTC_CHECK_REPEATED_RUN} == 1 ]]; then
        echo "GoToCloud: ========================================================================="
        echo "GoToCloud: Testing repeated run..."
        echo "GoToCloud: ========================================================================="
        echo "GoToCloud: "
        ${GTC_CMD_TARGET}
        echo "GoToCloud: "
    fi
    
    echo "GoToCloud: ========================================================================="
    echo "GoToCloud: Check results"
    echo "GoToCloud: ========================================================================="
    
    if [ ! -e ${GTC_CONFIG_DIR} ]; then
        echo "GoToCloud: GTC_UNIT_TEST_FAIL"
        echo "GoToCloud: Failed to create config directory ${GTC_CONFIG_DIR}."
        echo "GoToCloud: This should not happen!"
        echo "GoToCloud: Do debug again, DUDE!!!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
    fi
    
    if [ ! -e ${GTC_CONFIG_FILE} ]; then
        echo "GoToCloud: GTC_UNIT_TEST_FAIL"
        echo "GoToCloud: Failed to create config file ${GTC_CONFIG_FILE}."
        echo "GoToCloud: This should not happen!"
        echo "GoToCloud: Do debug again, DUDE!!!"
        echo "GoToCloud: Exiting(1)..."
        exit 1
    fi
    
    echo "GoToCloud: Check the contents of ${GTC_CONFIG_DIR}!"
    echo "GoToCloud: ls -l ${GTC_CONFIG_DIR}"
    ls -l ${GTC_CONFIG_DIR}
    if [ -e ${GTC_CONFIG_FILE} ]; then
        if [[ ${GTC_CMD_SHOW_CONFIG_ALL} == 1 ]]; then
            echo "GoToCloud: Check all contents of created config file ${GTC_CONFIG_FILE}!"
            echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            cat ${GTC_CONFIG_FILE}
            echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo "GoToCloud: "
       fi
        echo "GoToCloud: Check related contents of created config file ${GTC_CONFIG_FILE}!"
        echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        grep "key_name" ${GTC_CONFIG_FILE}
        grep "tags" ${GTC_CONFIG_FILE}
        grep "s3_read_write_resource" ${GTC_CONFIG_FILE}
        grep "max_count" ${GTC_CONFIG_FILE}
        grep "storage_capacity" ${GTC_CONFIG_FILE}
        grep "import_path" ${GTC_CONFIG_FILE}
        grep "export_path" ${GTC_CONFIG_FILE}
        echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        echo "GoToCloud: "
    fi
    
    echo "GoToCloud: GTC_UNIT_TEST_SUCCESS"
    echo "GoToCloud: Config file ${GTC_CONFIG_FILE} are successfully created!"
    echo "GoToCloud: "
    
    if [[ ${GTC_CHECK_REPEATED_RUN} == 1 ]]; then
        echo "GoToCloud: -------------------------------------------------------------------------"
        echo "GoToCloud: Deleting backup config file ${GTC_CONFIG_FILE} of repeated runs"
        echo "GoToCloud: -------------------------------------------------------------------------"
        echo "GoToCloud: "
        rm ${GTC_CONFIG_FILE}_backup*
        echo "GoToCloud: "
    fi

    echo "GoToCloud: -------------------------------------------------------------------------"
    echo "GoToCloud: Restore original config file ${GTC_CONFIG_FILE} if necessary"
    echo "GoToCloud: -------------------------------------------------------------------------"
    if [ -e ${GTC_CONFIG_FILE_DEBUG_ORIGINAL} ]; then
        ### echo "GoToCloud: Check contents of existing config file ${GTC_CONFIG_FILE_DEBUG_ORIGINAL}!"
        ### echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        ### cat ${GTC_CONFIG_FILE_DEBUG_ORIGINAL}
        ### echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        echo "GoToCloud: Restore contents of original config file ${GTC_CONFIG_FILE} from ${GTC_CONFIG_FILE_DEBUG_ORIGINAL}..."
        mv ${GTC_CONFIG_FILE_DEBUG_ORIGINAL} ${GTC_CONFIG_FILE}
        ### echo "GoToCloud: Check contents of existing config file ${GTC_CONFIG_FILE}!"
        ### echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        ### cat ${GTC_CONFIG_FILE}
        ### echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    else
        echo "GoToCloud: Nothing to restore!"
        echo "GoToCloud: Deleting config file ${GTC_CONFIG_FILE} just created with this debug script..."
        rm ${GTC_CONFIG_FILE}
    fi
    echo "GoToCloud: "

    echo "GoToCloud: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "GoToCloud: Done testing ${GTC_CMD_TARGET}"
    echo "GoToCloud: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: Common cases"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: "
GTC_CMD_SHOW_CONFIG_ALL=1
GTC_CHECK_REPEATED_RUN=0

GTC_CMD_TARGET="gtc_config_create.sh"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config
gtc_config_create_debug_case
echo "GoToCloud: "

export GTC_SYSTEM_DEBUG_MODE=0
GTC_CMD_SHOW_CONFIG_ALL=0

GTC_CMD_TARGET="gtc_config_create.sh -s 1200 -m 2"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config
gtc_config_create_debug_case
echo "GoToCloud: "

GTC_CMD_TARGET="gtc_config_create.sh -s 1200 -m 2 -i 00"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config_00
gtc_config_create_debug_case
echo "GoToCloud: "

GTC_CMD_TARGET="gtc_config_create.sh -i 01"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config_01
gtc_config_create_debug_case
echo "GoToCloud: "

GTC_CMD_TARGET="gtc_config_create.sh -i 00 -s 1200 -m 2"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config_00
gtc_config_create_debug_case
echo "GoToCloud: "

echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: Repeated runs cases"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: "
GTC_CHECK_REPEATED_RUN=1

GTC_CMD_TARGET="gtc_config_create.sh"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config
gtc_config_create_debug_case
echo "GoToCloud: "

GTC_CMD_TARGET="gtc_config_create.sh -s 1200 -m 2 -i 00"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config_00
gtc_config_create_debug_case
echo "GoToCloud: "

GTC_CMD_TARGET="gtc_config_create.sh -i 01"
GTC_CONFIG_FILE=${GTC_CONFIG_DIR}/config_01
gtc_config_create_debug_case
echo "GoToCloud: "

echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: Done"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "GoToCloud: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"



