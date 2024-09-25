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
# Debug script for gtc_utility_global_varaibles.sh
# 
# Dependencies:
#   gtc_setup_cloud9_environment.sh
#
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS_GET
[*] IMPORTANT! Do this ONLY-ONCE before starting debugging!
tail -n 6 ~/.bashrc
### cp ~/.bashrc ~/.bashrc_debug_backup
tail -n 6 ~/.bashrc_debug_backup

echo $PATH
### PATH_DEBUG_BACKUP=$PATH
echo $PATH_DEBUG_BACKUP

# [*] Run debug script
gtc_utility_global_varaibles_debug_get.sh
=> bash: gtc_utility_global_varaibles_debug_get.sh: command not found

export GTC_SYSTEM_DEBUG_MODE=0
/efs/em/gtc_sh_ver00/gtc_setup_cloud9_environment.sh
tail -n 6 ~/.bashrc
echo $PATH

# [*] Check open new terminal method
gtc_utility_global_varaibles_debug_get.sh
=> Should run!

tail -n 6 ~/.bashrc
echo $PATH
echo $PATH | grep "/efs/em/gtc_sh_ver00"

gtc_utility_global_varaibles_debug_get.sh

# [*] Check source method
gtc_utility_global_varaibles_debug_get.sh
=> bash: gtc_utility_global_varaibles_debug_get.sh: command not found

source /home/ec2-user/.gtc/global_variables.sh

export GTC_SYSTEM_DEBUG_MODE=1
gtc_utility_global_varaibles_debug_get.sh
=> Should run!

# [*] Clean up
# Unsetting GoToCloud sytemwise environment variables
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
# unset GTC_SYSTEM_DEBUG_MODE

tail -n 6 ~/.bashrc
tail -n 6 ~/.bashrc_debug_backup
cp ~/.bashrc_debug_backup ~/.bashrc
tail -n 6 ~/.bashrc

echo $PATH
echo $PATH_DEBUG_BACKUP
export PATH=$PATH_DEBUG_BACKUP
echo $PATH



# => Finally, open new terminal!

DEBUG_COMMANDS_GET

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

echo "GoToCloud: Check PATH settings for GoToCloud shell commands"
echo "GoToCloud: which gtc_utility_global_varaibles.sh"
which gtc_utility_global_varaibles.sh
echo "GoToCloud: "

# First import gtc_utility_global_varaibles shell functions
source gtc_utility_global_varaibles.sh
# . gtc_utility_global_varaibles.sh
echo "GoToCloud: "
echo "GoToCloud: Call get functions in gtc_utility_global_varaibles.sh"
echo "GoToCloud: gtc_utility_get_sh_dir = $(gtc_utility_get_sh_dir)"
echo "GoToCloud: gtc_utility_get_iam_user_name = $(gtc_utility_get_iam_user_name)"
echo "GoToCloud: gtc_utility_get_method_name = $(gtc_utility_get_method_name)"
echo "GoToCloud: gtc_utility_get_project_name = $(gtc_utility_get_project_name)"
echo "GoToCloud: gtc_utility_get_pcluster_name = $(gtc_utility_get_pcluster_name)"
echo "GoToCloud: gtc_utility_get_s3_name = $(gtc_utility_get_s3_name)"
echo "GoToCloud: gtc_utility_get_key_name = $(gtc_utility_get_key_name)"
echo "GoToCloud: gtc_utility_get_key_dir = $(gtc_utility_get_key_dir)"
echo "GoToCloud: gtc_utility_get_key_file = $(gtc_utility_get_key_file)"
echo "GoToCloud: gtc_utility_get_application_dir = $(gtc_utility_get_application_dir)"
echo "GoToCloud: gtc_utility_get_global_varaibles_file = $(gtc_utility_get_global_varaibles_file)"
echo "GoToCloud: gtc_utility_get_debug_mode = $(gtc_utility_get_debug_mode)"
echo "GoToCloud: "

echo "GoToCloud: Done"
