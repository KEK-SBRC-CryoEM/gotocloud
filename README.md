# GoToCloud

GoToCloud is a cloud-computing-based platform for advanced data analysis and data management for Cryo-EM SPA.


## Installation

```
git clone https://github.com/KEK-SBRC-CryoEM/gotocloud.git
``` 


For installation, please see here: https://sites.google.com/sbrc.jp/gotocloud-doc/installation

## Getting Start

### AWS Cloud9 Creation
You should create Cloud9 from AWS console first.
1. Go to Cloud9 service page in AWS console.
1. Create environment.
	1. Enter "Project name" (e.g. protein-240101) into "Name" box.
	1. Select "Amazon Linux 2" in "Platform".
	1. Select "Secure Shell (SSH)"  in "Connection".
	1. Select "Name - kek-gtc-user-vpc" in "Amazon Virtual Private Cloud (VPC)".
	1. Select "Name - kek-gtc-user-subnet1" in "Subnet".
	1. Create Cloud9.
1. Open Cloud9 IDE.

### GoToCloud envornment Setup
Then, execute the following commands in Cloud9 terminal to setup GoToCloud envornment. 
```
cd ~/environment
wget https://kek-gtc-master-s3-bucket.s3.ap-northeast-1.amazonaws.com/gtc_setup_gotocloud_environment.sh
chmod 755 ~/environment/gtc_setup_gotocloud_environment.sh
./gtc_setup_gotocloud_environment.sh
``` 
### AWS arallelCluster Creation
Open the new Cloud9 terminal and create parallelcluster using the following command.
```
gtc_pcluster_create.sh
``` 
### Connection to AWS ParallelCluster
Connect to the ParallelCluster head ndoe created above via niceDCV.
```
gtc_pcluster_dcv_connect.sh
```
**or** via SSH
```
gtc_pcluster_ssh.sh
``` 
### AWS ParallelCluster Termination 
If you won't be using Parallelcluster it is recommended to delete the ParallelCluster to stop billing for the relatively expensive head node and Lustre.
you can delete parallelcluster using the following command.
```
gtc_pcluster_delete.sh
``` 

For more information, see: https://sites.google.com/sbrc.jp/gotocloud-doc/procedure



