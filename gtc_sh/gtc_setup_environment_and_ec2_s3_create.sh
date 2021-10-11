#!/bin/bash
#
#

#Mount the file system /efs 

sudo yum -y install amazon-efs-utils
sudo mkdir /efs
echo 'fs-0a8524613d2736fb6:/ /efs efs _netdev,noresvport,tls,mounttargetip=10.2.4.117 1 1' | sudo tee -a /etc/fstab
sudo mount -a

echo "GoToCloud: "
echo "GoToCloud: Check if /efs is mounted ..."
df -h
echo "GoToCloud: "

#Installe pcluster
echo "GoToCloud: Installe parallelcluster ..."
pip3 install "aws-parallelcluster" --upgrade --user

#Installe Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
chmod 755 ~/.nvm/nvm.sh
source ~/.nvm/nvm.sh
nvm install node
node --version

echo "GoToCloud: "
echo "GoToCloud: Check PATH settings for parallelcluster"
echo "GoToCloud: which pcluster "
which pcluster
echo "GoToCloud: "

PV=$(pcluster version)
echo "GoToCloud: Check parallelcluster version"
echo "GoToCloud: pcluster version = ${PV}"
echo "GoToCloud: "

#Installe jq
sudo yum -y install jq

#Setup Cloud9 environment 
/efs/em/gtc_sh_ver00o03/gtc_setup_cloud9_environment.sh

source /home/ec2-user/.gtc/global_variables.sh

#Create s3 bucket
/efs/em/gtc_sh_ver00o03/gtc_aws_s3_create.sh

#Create ec2 key pair
/efs/em/gtc_sh_ver00o03/gtc_aws_ec2_create_key_pair.sh

#Create config 
/efs/em/gtc_sh_ver00o03/gtc_config_create.sh -s 2400 -m 8

echo "GoToCloud: "
echo "GoToCloud: Check config settings... "
cat ~/.parallelcluster/config.yaml
echo "GoToCloud: "
echo "GoToCloud: Done "


