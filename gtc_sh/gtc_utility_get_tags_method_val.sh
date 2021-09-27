#!/bin/sh
# 
# Usage
# /efs/em/gtc_sh_ver00/gtc_utility_get_tags_method_val.sh
# 

# return generated cluster name
echo $(aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) | jq -r '.Reservations[].Instances[].Tags[] | select(.Key == "method").Value')
