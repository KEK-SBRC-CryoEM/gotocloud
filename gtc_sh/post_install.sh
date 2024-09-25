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

cd /tmp
sudo apt-get update
sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
yes "" | sudo apt-get -y install ./build/amazon-efs-utils*deb

sudo mkdir /efs
sudo mount -t efs -o tls,mounttargetip=$1 $2 /efs

echo '/efs/em/modulefiles' | sudo tee -a /usr/share/modules/init/.modulespath
echo '/efs/em/modulefiles/oneAPI' | sudo tee -a /usr/share/modules/init/.modulespath