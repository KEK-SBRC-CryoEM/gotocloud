#/bin/bash

cd /tmp
sudo apt-get update
sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils
. /tmp/efs-utils/build-deb.sh
sudo apt-get -y install /tmp/efs-utils/build/amazon-efs-utils*deb

mkdir /efs
mount -t efs -o tls,mounttargetip=10.2.4.87 fs-09c4bbb5f7e489d85 /efs

echo '/efs/em/modulefiles' | sudo tee -a /usr/share/modules/init/.modulespath
echo '/efs/em/modulefiles/oneAPI' | sudo tee -a /usr/share/modules/init/.modulespath