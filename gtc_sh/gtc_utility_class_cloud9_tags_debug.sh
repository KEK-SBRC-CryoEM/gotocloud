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
# Debug script for gtc_utility_class_cloud9_tags.sh
# 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<< DEBUG_COMMANDS
export GTC_SYSTEM_DEBUG_MODE=1
/efs/em/gtc_sh_ver00/gtc_utility_class_cloud9_tags_debug.sh

# Check current values of GoToCloud sytemwise environment variables from global scope
echo "GTC_SYSTEM_IAM_USEAR_NAME=${GTC_SYSTEM_IAM_USEAR_NAME}"
echo "GTC_SYSTEM_METHOD_NAME=${GTC_SYSTEM_METHOD_NAME}"
echo "GTC_SYSTEM_PROJECT_NAME=${GTC_SYSTEM_PROJECT_NAME}"

DEBUG_COMMANDS
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo "GoToCloud: GTC_SYSTEM_DEBUG_MODE=${GTC_SYSTEM_DEBUG_MODE}"
echo "GoToCloud: "

# Make sure the same varaible names are not defined as systemwise environment variables
unset GTC_IAM_USEAR_NAME
echo "GoToCloud: GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"
unset GTC_METHOD_NAME
echo "GoToCloud: GTC_METHOD_NAME=${GTC_METHOD_NAME}"
unset GTC_PROJECT_NAME
echo "GoToCloud: GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"
echo "GoToCloud: "

# Obtaine GoToCloud shell script directory path from this command line
# Target script file must be in the same directory!
GTC_SH_DIR=`cd $(dirname $0) && pwd`
echo "GoToCloud: GTC_SH_DIR=${GTC_SH_DIR}"
echo "GoToCloud: "

# Call gtc_utility_class_cloud9_tags_get_values
echo "GoToCloud: Calling gtc_utility_class_cloud9_tags_get_values..."
echo "GoToCloud: "
# First import gtc_utility_class_cloud9_tags shell class
. ${GTC_SH_DIR}/gtc_utility_class_cloud9_tags.sh
# source gtc_utility_class_cloud9_tags.sh
# Then call gtc_utility_class_cloud9_tags_get_values function
gtc_utility_class_cloud9_tags_get_values
echo "GoToCloud: "
echo "GoToCloud: Returned from gtc_utility_class_cloud9_tags_get_values"
echo "GoToCloud: "

echo "GoToCloud: Values of global variables within file scope of this debug script"
echo "GoToCloud: GTC_IAM_USEAR_NAME=${GTC_IAM_USEAR_NAME}"
echo "GoToCloud: GTC_METHOD_NAME=${GTC_METHOD_NAME}"
echo "GoToCloud: GTC_PROJECT_NAME=${GTC_PROJECT_NAME}"
echo "GoToCloud: "

echo "GoToCloud: Done"
