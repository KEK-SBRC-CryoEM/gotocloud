#!/bin/bash
#
# Usage:
#  gtc_dependencies_install.sh
#   
# Arguments & Options:
#   -h                 : Help option displays usage
#   
# Examples:
#   $ gtc_dependencies_install.sh
#   
# Debug Script:
#   
# 
#Installe jq
function gtc_dependency_jq_install() {
    jq -V &>/dev/null || {
        echo "GoToCloud: Installing jq ..."
        sudo yum -y install jq
        #echo "GoToCloud: Done"
        }
}

#Installe python
function gtc_dependency_virtualenv_create() {
    echo "GoToCloud: Installing python3.8 ..."
    sudo amazon-linux-extras install -y python3.8
    python3 -m virtualenv -p python3.8 ~/$1    #Create virtualenv for parallelcluster with python3.8
}

#Installe pcluster
function gtc_dependency_pcluster_install() {
    echo "GoToCloud: Installing parallelcluster ..."
    pcluster version &>/dev/null && {
        PV=$(pcluster version | jq -r '.version')
        echo "GoToCloud: Parallelcluster "${PV}" is already installed."
        #echo "GoToCloud: Done"
    } || {
        #python3 -m pip install --use-feature=2020-resolver "aws-parallelcluster<3.7.1" --upgrade --user
        python3 -m pip install --upgrade "aws-parallelcluster<3.7.1"
        echo "GoToCloud: "
        echo "GoToCloud: Check PATH settings for parallelcluster"
        echo "GoToCloud: which pcluster "
        which pcluster
        echo "GoToCloud: "
        PV=$(pcluster version | jq -r '.version')
        echo "GoToCloud: Parallelcluster "${PV}" is installed."
        #echo "GoToCloud: Done"
    }
}

#Installe pcluster latest version
function gtc_dependency_pcluster_latestver_install() {
    echo "GoToCloud: Installing parallelcluster ..."
    pcluster version &>/dev/null && {
        PV=$(pcluster version | jq -r '.version')
        echo "GoToCloud: Parallelcluster "${PV}" is already installed."
        #echo "GoToCloud: Done"
    } || {
        python3 -m pip install --upgrade "aws-parallelcluster"
        #pip3 install --use-feature=2020-resolver aws-parallelcluster --upgrade --user
        echo "GoToCloud: "
        echo "GoToCloud: Check PATH settings for parallelcluster"
        echo "GoToCloud: which pcluster "
        which pcluster
        echo "GoToCloud: "
        PV=$(pcluster version | jq -r '.version')
        echo "GoToCloud: Parallelcluster "${PV}" is installed."
        #echo "GoToCloud: Done"
    }
}

#Installe Node.js
function gtc_dependency_node_install() {
    echo "GoToCloud: Installing Node.js ..."
    source ~/.nvm/nvm.sh
    if [[ $? != 0 ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        chmod 755 ~/.nvm/nvm.sh
        source ~/.nvm/nvm.sh
        GTC_NODE_VERSION_BF=$(node --version)  #nvm install node  #install latest version
        nvm install ${GTC_NODE_INST_VER}  #install specific version
        nvm alias default ${GTC_NODE_INST_VER}  #set lts version to default
        nvm uninstall ${GTC_NODE_VERSION_BF}
        GTC_NODE_VERSION=$(node --version)
        echo "GoToCloud: Node.js "${GTC_NODE_VERSION}" is installed"
    else
        nvm use ${GTC_NODE_INST_VER} &>/dev/null
        if [[ $? != 0 ]]; then
            GTC_NODE_VERSION_BF=$(node --version)  #nvm install node  #install latest version
            nvm install ${GTC_NODE_INST_VER}  #install specific version
            nvm alias default ${GTC_NODE_INST_VER}  #set lts version to default
            nvm uninstall ${GTC_NODE_VERSION_BF}
            GTC_NODE_VERSION=$(node --version)
            echo "GoToCloud: Node.js "${GTC_NODE_VERSION}" is installed"
        else
            GTC_NODE_VERSION=$(node --version)
            echo "GoToCloud: Node.js version "${GTC_NODE_VERSION}" is already installed"
        fi
    fi
}

#Check if Service-Linked Role "AWSServiceRoleForEC2Spot" exists
function gtc_ec2spotrole_check() {
    echo "GoToCloud: Checking if Service-Linked Role 'AWSServiceRoleForEC2Spot' exists..."
    aws iam get-role --role-name AWSServiceRoleForEC2Spot > /dev/null 2>&1 && {
        echo "GoToCloud: OK! Service-Linked Role 'AWSServiceRoleForEC2Spot' exists."
    } || {
        echo "GoToCloud: Service-Linked Role 'AWSServiceRoleForEC2Spot' doesn't exist."
        echo "GoToCloud: Creating Service-Linked Role 'AWSServiceRoleForEC2Spot'..."
        aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
        echo "GoToCloud: Created Service-Linked Role 'AWSServiceRoleForEC2Spot'."
    }
}