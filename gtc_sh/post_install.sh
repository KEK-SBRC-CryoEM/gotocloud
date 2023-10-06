#!/bin/bash

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