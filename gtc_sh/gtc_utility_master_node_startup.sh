#!/bin/bash

# Install basic denpendency 
echo "GoToCloud: Installing basic denpendency for RELION3.1 ..."

sudo apt update -y
sudo apt update
sudo apt install -y cmake git build-essential mpi-default-bin mpi-default-dev libfftw3-dev libtiff-dev

echo "GoToCloud: Setting up environment variables for RELION3.1 ..."
cd
rm .bashrc
cp /efs/em/gtc.bashrc ~/.bashrc

echo "GoToCloud: Changing owners of directories and files in fsx (Lustre) ..."
sudo chown -R ubuntu:ubuntu /fsx

