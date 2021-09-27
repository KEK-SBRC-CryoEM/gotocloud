#!/bin/bash
# 
# Debug script for gtc_utility_master_node_startup.sh
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS
# --------------------------------------------------
# [*] Check on pcluster head-node
# --------------------------------------------------
# [*] Log-in to pcluster head-node from cloud9
$ pcluster ssh kek-moriya-protein210720 -i ~/environment/kek-moriya-protein210720.pem -oStrictHostKeyChecking=no

# [*] IMPORTANT! Do this ONLY-ONCE before starting debugging!
cat ~/.bashrc
cp ~/.bashrc ~/.bashrc_debug_backup
cat ~/.bashrc_debug_backup
### # Do this only if necessary
### cp ~/.bashrc_debug_backup ~/.bashrc

echo $PATH
/opt/amazon/openmpi/bin/:/opt/amazon/efa/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/slurm/bin
PATH_DEBUG_BACKUP=$PATH
echo $PATH_DEBUG_BACKUP
/opt/amazon/openmpi/bin/:/opt/amazon/efa/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/slurm/bin
### # Do this only if necessary
### export PATH=$PATH_DEBUG_BACKUP
### # OR 
### export PATH=/opt/amazon/openmpi/bin/:/opt/amazon/efa/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/slurm/bin

which gtc_utility_master_node_startup_debug.sh

ls -al ~/.gtc*
rm -r ~/.gtc*
ls -al ~/.gtc*

# Do this when you want to debug installation of dependencies (takes long time...)
# Uninstall packages
sudo apt --yes --force-yes remove cmake git build-essential mpi-default-bin mpi-default-dev libfftw3-dev libtiff-dev
sudo apt-get --yes --force-yes remove python3-venv
sudo apt-get --yes --force-yes remove /efs/em/ucsf-chimerax_1.2.5-1_amd64.deb

# # Uninstall packages including their dependencies
# sudo apt  --yes --force-yes --purge remove cmake git build-essential mpi-default-bin mpi-default-dev libfftw3-dev libtiff-dev
# sudo apt-get --yes --force-yes --purge remove python3-venv
# sudo apt-get --yes --force-yes --purge remove /efs/em/ucsf-chimerax_1.2.5-1_amd64.deb

# ~~~~~~~~~~~~~~~~~~~~
# [*] Run debug script
# ~~~~~~~~~~~~~~~~~~~~
export GTC_SYSTEM_DEBUG_MODE=1
/efs/em/gtc_sh_ver00/gtc_utility_master_node_startup_debug.sh GTC_RESTORE

# When you want to test the case where .gtc exists already
# do the following once before the above procedure
/efs/em/gtc_sh_ver00/gtc_utility_master_node_startup_debug.sh GTC_NO_RESTORE

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [*] Run debug script and check the settings
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/efs/em/gtc_sh_ver00/gtc_utility_master_node_startup_debug.sh GTC_NO_RESTORE

# [*] Check using Nice DCV
pcluster dcv connect kek-moriya-protein210720 -k ~/environment/kek-moriya-protein210720.pem

# [*] Log-out from pcluster head-node to cloud9
exit 
pcluster ssh kek-moriya-protein210720 -i ~/environment/kek-moriya-protein210720.pem -oStrictHostKeyChecking=no

# Check GoToCloud global varaible file
cat ~/.bashrc
ls -al ~/.gtc
cat ~/.gtc/global_variables.sh
cat ~/.gtc/relion_settings.sh
cat ~/.gtc/chimera_settings.sh
echo ${PATH}

# Check current values of GoToCloud sytemwise environment variables from global scope
echo "GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"

which gtc_utility_master_node_startup.sh
which relion
which chimera
source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate
python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h
deactivate

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [*] Run debug through SSH from cloud9
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [Trial A] Execute a command without debug option through SSH
pcluster ssh kek-moriya-protein210720 -i ~/environment/kek-moriya-protein210720.pem -oStrictHostKeyChecking=no /efs/em/gtc_sh_ver00/gtc_utility_master_node_startup.sh

# [Trial B] Execute a command without debug option through SSH
pcluster ssh kek-moriya-protein210720 -i ~/environment/kek-moriya-protein210720.pem -oStrictHostKeyChecking=no "/efs/em/gtc_sh_ver00/gtc_utility_master_node_startup.sh -d"

# [Trial C] Execute a command without debug option through SSH using variables
GTC_INSTANCE_NAME=kek-moriya-protein210720
GTC_KEY_FILE=${HOME}/environment/kek-moriya-protein210720.pem
GTC_CMD=/efs/em/gtc_sh_ver00/gtc_utility_master_node_startup.sh
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no ${GTC_CMD}

# [Trial D] Execute a command with debug option through SSH using variables
GTC_INSTANCE_NAME=kek-moriya-protein210720
GTC_KEY_FILE=${HOME}/environment/kek-moriya-protein210720.pem
GTC_CMD="/efs/em/gtc_sh_ver00/gtc_utility_master_node_startup.sh -d"
pcluster ssh ${GTC_INSTANCE_NAME} -i ${GTC_KEY_FILE} -oStrictHostKeyChecking=no "${GTC_CMD}"

# [*] Log-out from pcluster head-node to cloud9
pcluster ssh kek-moriya-protein210720 -i ~/environment/kek-moriya-protein210720.pem -oStrictHostKeyChecking=no

# Check GoToCloud global varaible file
cat ~/.bashrc
ls -al ~/.gtc
cat ~/.gtc/global_variables.sh
cat ~/.gtc/relion_settings.sh
cat ~/.gtc/chimera_settings.sh
echo ${PATH}

# Check current values of GoToCloud sytemwise environment variables from global scope
echo "GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"

which gtc_utility_master_node_startup.sh
which relion
which chimera
source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate
python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h
deactivate




DEBUG_COMMANDS
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Preparation"
echo "GoToCloud: ========================================================================="

GTC_TAIL_N=10

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Store original .bashrc file"
echo "GoToCloud: -------------------------------------------------------------------------"

GTC_BASHRC=${HOME}/.bashrc
echo "GoToCloud: Check contents of ${GTC_BASHRC}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

GTC_BASHRC_DEBUG_ORIGINAL=${HOME}/.bashrc_debug_original
if [ -e ${GTC_BASHRC_DEBUG_ORIGINAL} ]; then
    echo "GoToCloud: [GTC_ERROR] Logically ${GTC_BASHRC_DEBUG_ORIGINAL} should not exists!"
    echo "GoToCloud: Delete ${GTC_BASHRC_DEBUG_ORIGINAL} and re-run this script."
    echo "GoToCloud: Exiting(1)..."
    exit 1
else
    echo "GoToCloud: Making copy of original ${GTC_BASHRC} as ${GTC_BASHRC_DEBUG_ORIGINAL}..."
    cp ${GTC_BASHRC} ${GTC_BASHRC_DEBUG_ORIGINAL}
fi

echo "GoToCloud: Check contents of ${GTC_BASHRC_DEBUG_ORIGINAL}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Store original PATH setting"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: Making a backup of original PATH as PATH_DEBUG_BACKUP..."
PATH_DEBUG_ORIGINAL=${PATH}

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Store original values of GoToCloud enverinment varaibles"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check contents of PATH_DEBUG_ORIGINAL..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: Check original values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: Storing original values of GoToCloud sytemwise environment variables..."
GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_SH_DIR}
GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL=${GTC_SYSTEM_DEBUG_MODE}

echo "GoToCloud: Check stored values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL=${GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL}"
echo "GoToCloud: "

echo "GoToCloud: Unsetting GoToCloud sytemwise environment variables..."
unset GTC_SYSTEM_SH_DIR
unset GTC_SYSTEM_GLOBAL_VARIABLES_FILE
# unset GTC_SYSTEM_DEBUG_MODE  # Exclue this for debugging
echo "GoToCloud: "

echo "GoToCloud: Check usetted values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: Check RELION enviroment settings..."
echo "GoToCloud: which relion"
which relion
echo "GoToCloud: "

echo "GoToCloud: Check Follow_Relion_gracefully enviroment settings..."
echo "GoToCloud: source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate"
source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate
echo "GoToCloud: python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h"
python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h
echo "GoToCloud: deactivate"
deactivate
echo "GoToCloud: "

echo "GoToCloud: Check UCFS Chimera enviroment settings..."
echo "GoToCloud: which chimera"
which chimera
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Store original .gtc directory"
echo "GoToCloud: -------------------------------------------------------------------------"

GTC_APPLICATION_DIR=${HOME}/.gtc
echo "GoToCloud: GTC_APPLICATION_DIR=${GTC_APPLICATION_DIR}"
GTC_APPLICATION_DIR_DEBUG_ORIGINAL=${HOME}/.gtc_debug_original
echo "GoToCloud: GTC_APPLICATION_DIR_DEBUG_ORIGINAL=${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}"
if [ -e ${GTC_APPLICATION_DIR} ]; then
    echo "GoToCloud: ${GTC_APPLICATION_DIR} exists already!"
    echo "GoToCloud: Temporarily moving ${GTC_APPLICATION_DIR} to ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}"
    mv ${GTC_APPLICATION_DIR} ${GTC_APPLICATION_DIR_DEBUG_ORIGINAL}
else
    echo "GoToCloud: ${GTC_APPLICATION_DIR} does not exist yet!"
fi
echo "GoToCloud: "

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Run the target script"
echo "GoToCloud: ========================================================================="

# Obtaine GoToCloud shell script directory path from this command line
# Target script file must be in the same directory!
GTC_SH_DIR=`cd $(dirname $0) && pwd`
echo "GoToCloud: GTC_SH_DIR=${GTC_SH_DIR}"
echo "GoToCloud: "

# Run gtc_utility_master_node_startup.sh
if [[ ${GTC_SYSTEM_DEBUG_MODE} != 1 ]]; then
    echo "GoToCloud: Running ${GTC_SH_DIR}/gtc_utility_master_node_startup.sh..."
    echo "GoToCloud: "
    ${GTC_SH_DIR}/gtc_utility_master_node_startup.sh
    echo "GoToCloud: "
    echo "GoToCloud: Returned from ${GTC_SH_DIR}/gtc_utility_master_node_startup.sh"
    echo "GoToCloud: "
else
    echo "GoToCloud: Running ${GTC_SH_DIR}/gtc_utility_master_node_startup.sh -d..."
    echo "GoToCloud: "
    ${GTC_SH_DIR}/gtc_utility_master_node_startup.sh -d
    echo "GoToCloud: "
    echo "GoToCloud: Returned from ${GTC_SH_DIR}/gtc_utility_master_node_startup.sh -d"
    echo "GoToCloud: "
fi

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Check results"
echo "GoToCloud: ========================================================================="

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check envrinment variable settings and thier activeation by source"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check values of GoToCloud sytemwise environment variables right after running script..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "
echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: GTC_APPLICATION_DIR=${GTC_APPLICATION_DIR}"
GTC_GLOBAL_VARIABLES_FILE=${GTC_APPLICATION_DIR}/global_variables.sh
echo "GoToCloud: GTC_GLOBAL_VARIABLES_FILE=${GTC_GLOBAL_VARIABLES_FILE}"

echo "GoToCloud: "
echo "GoToCloud: Activating GoToCloud sytemwise environment variables..."
echo "GoToCloud: source ${GTC_GLOBAL_VARIABLES_FILE}"
source ${GTC_GLOBAL_VARIABLES_FILE}

echo "GoToCloud: "
echo "GoToCloud: Check values of GoToCloud sytemwise environment variables right after activation..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "
echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: which gtc_utility_master_node_startup.sh"
which gtc_utility_master_node_startup.sh
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check RELION environment settings and thier activeation by source"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check RELION enviroment settings right after running script..."
echo "GoToCloud: which relion"
which relion
echo "GoToCloud: "
echo "GoToCloud: Check Follow_Relion_gracefully enviroment settings after running script..."
echo "GoToCloud: Note Follow_Relion_gracefully is active regardless of activation of RELION environment settings"
echo "GoToCloud: source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate"
source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate
echo "GoToCloud: python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h"
python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h
echo "GoToCloud: deactivate"
deactivate
echo "GoToCloud: "

GTC_RELION_SETTINGS_FILE=${GTC_APPLICATION_DIR}/relion_settings.sh
echo "GoToCloud: GTC_RELION_SETTINGS_FILE=${GTC_RELION_SETTINGS_FILE}"
echo "GoToCloud: "

echo "GoToCloud: Activating RELION environment settings..."
echo "GoToCloud: source ${GTC_RELION_SETTINGS_FILE}"
source ${GTC_RELION_SETTINGS_FILE}
echo "GoToCloud: "

echo "GoToCloud: Check RELION enviroment settings right after activation..."
echo "GoToCloud: which relion"
which relion
echo "GoToCloud: "
# echo "GoToCloud: Check Follow_Relion_gracefully enviroment settings right after activation..."
# echo "GoToCloud: Note Follow_Relion_gracefully is active regardless of activation of RELION environment settings"
# echo "GoToCloud: source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate"
# source /efs/em/Follow_Relion_gracefully/env_follow_relion_gracefully/bin/activate
# echo "GoToCloud: python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h"
# python3 /efs/em/Follow_Relion_gracefully/follow_relion_gracefully.py -h
# echo "GoToCloud: deactivate"
# deactivate
# echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check UCFS Chimera environment settings and thier activeation by source"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check UCFS Chimera enviroment settings right after running script..."
echo "GoToCloud: which chimera"
which chimera
echo "GoToCloud: "

GTC_CHIMERA_SETTINGS_FILE=${GTC_APPLICATION_DIR}/chimera_settings.sh
echo "GoToCloud: GTC_CHIMERA_SETTINGS_FILE=${GTC_CHIMERA_SETTINGS_FILE}"
echo "GoToCloud: "

echo "GoToCloud: Activating UCFS Chimera environment settings..."
echo "GoToCloud: source ${GTC_CHIMERA_SETTINGS_FILE}"
source ${GTC_CHIMERA_SETTINGS_FILE}
echo "GoToCloud: "

echo "GoToCloud: Check UCFS Chimera enviroment settings right after activation..."
echo "GoToCloud: which chimera"
which chimera
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check .bashrc file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_BASHRC}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check GoToCloud global varaible file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_GLOBAL_VARIABLES_FILE}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cat ${GTC_GLOBAL_VARIABLES_FILE}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "
echo "GoToCloud: ls -al ${GTC_GLOBAL_VARIABLES_FILE}"
ls -al ${GTC_GLOBAL_VARIABLES_FILE}
echo "GoToCloud: "
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check RELION environment settings file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_RELION_SETTINGS_FILE}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cat ${GTC_RELION_SETTINGS_FILE}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "
echo "GoToCloud: ls -al ${GTC_RELION_SETTINGS_FILE}"
ls -al ${GTC_RELION_SETTINGS_FILE}
echo "GoToCloud: "
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check UCFS Chimera enviroment settings file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_CHIMERA_SETTINGS_FILE}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cat ${GTC_CHIMERA_SETTINGS_FILE}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "
echo "GoToCloud: ls -al ${GTC_CHIMERA_SETTINGS_FILE}"
ls -al ${GTC_CHIMERA_SETTINGS_FILE}
echo "GoToCloud: "

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Restore original settings"
echo "GoToCloud: ========================================================================="

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Restore original .gtc directory"
echo "GoToCloud: -------------------------------------------------------------------------"
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
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Restore original values of GoToCloud enverinment varaibles"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check stored original values of GoToCloud sytemwise environment variables..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL=${GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL=${GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL}"
echo "GoToCloud: "

if [[ $1 == GTC_RESTORE ]]; then
    echo "GoToCloud: Restoring original values of GoToCloud sytemwise environment variables from stored values..."
    GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL}
    GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL}
fi
unset GTC_SYSTEM_SH_DIR_DEBUG_ORIGNAL
unset GTC_SYSTEM_DEBUG_MODE_DEBUG_ORIGNAL

echo "GoToCloud: Check values of GoToCloud sytemwise environment variables after restration..."
echo "GoToCloud: GTC_SYSTEM_SH_DIR=${GTC_SYSTEM_SH_DIR}"
echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Restore original PATH setting"
echo "GoToCloud: -------------------------------------------------------------------------"

echo "GoToCloud: Check contents of PATH_DEBUG_ORIGINAL..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

if [[ $1 == GTC_RESTORE ]]; then
    echo "GoToCloud: Restore original PATH from PATH_DEBUG_BACKUP..."
    PATH=${PATH_DEBUG_ORIGINAL}
fi
unset PATH_DEBUG_ORIGINAL

echo "GoToCloud: Check contents of PATH..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ${PATH}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Restore original .bashrc file"
echo "GoToCloud: -------------------------------------------------------------------------"
echo "GoToCloud: Check contents of ${GTC_BASHRC_DEBUG_ORIGINAL}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC_DEBUG_ORIGINAL}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

if [[ $1 == GTC_RESTORE ]]; then
    echo "GoToCloud: Restore contents of original ${GTC_BASHRC} from ${GTC_BASHRC_DEBUG_ORIGINAL}..."
    cp ${GTC_BASHRC_DEBUG_ORIGINAL} ${GTC_BASHRC}
fi
rm ${GTC_BASHRC_DEBUG_ORIGINAL}

echo "GoToCloud: Check contents of ${GTC_BASHRC}..."
echo "GoToCloud: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
tail -n ${GTC_TAIL_N} ${GTC_BASHRC}
echo "GoToCloud: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "GoToCloud: "

echo "GoToCloud: ========================================================================="
echo "GoToCloud: Done"
echo "GoToCloud: ========================================================================="
