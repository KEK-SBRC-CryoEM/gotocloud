#!/bin/bash
#
# Example:
# $ /efs/em/gtc_sh_ver00/gtc_aws_ec2_create_key_pair.sh
# 
# Debug Commands:
# 
# $ /efs/em/gtc_sh_ver00/gtc_aws_ec2_create_key_pair.sh
# $ ls -l ~/environment/kek-moriya-protein210720.pem
# $ cat ~/environment/kek-moriya-protein210720.pem
# $ 
# $ aws ec2 describe-key-pairs --key-name kek-moriya-protein210720
# $ 
# $ aws ec2 delete-key-pair --key-name kek-moriya-protein210720
# $ rm ~/environment/kek-moriya-protein210720.pem
# $ 

GTC_KEY_PAIR_DIR="${HOME}/environment/"
GTC_SH_DIR="/efs/em/gtc_sh_ver00/"

echo "GoToCloud [DEBUG]: GTC_KEY_PAIR_DIR=${GTC_KEY_PAIR_DIR}"
echo "GoToCloud [DEBUG]: GTC_SH_DIR=${GTC_SH_DIR}"

GTC_PCLUSTER_NAME=`${GTC_SH_DIR}gtc_utility_generate_pcluster_name.sh`
echo "GoToCloud [DEBUG]: GTC_PCLUSTER_NAME=${GTC_PCLUSTER_NAME}"

mkdir -p ${GTC_KEY_PAIR_DIR}

echo "GoToCloud: Generating keypair ${GTC_PCLUSTER_NAME}..."
aws ec2 create-key-pair --key-name ${GTC_PCLUSTER_NAME} --region ap-northeast-1 --query 'KeyMaterial' --output text > ${GTC_KEY_PAIR_DIR}${GTC_PCLUSTER_NAME}.pem || {
        echo "GoToCloud: GCT_ERROR! Keypair ${GTC_PCLUSTER_NAME} exists already!"
        echo "GoToCloud: Exiting..."
        exit 1
}
chmod 600 ${GTC_KEY_PAIR_DIR}${GTC_PCLUSTER_NAME}.pem

echo "GoToCloud: Saved keypair file as ${GTC_KEY_PAIR_DIR}${GTC_PCLUSTER_NAME}.pem"
echo "GoToCloud: Done"
