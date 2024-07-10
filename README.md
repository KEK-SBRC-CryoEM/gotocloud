# GoToCloud

GoToCloud is a cloud-computing-based platform for advanced data analysis and data management for Cryo-EM SPA.


## Installation

```
git clone https://github.com/KEK-SBRC-CryoEM/gotocloud.git
``` 


For installation, please see here: https://sites.google.com/sbrc.jp/gotocloud/installation

## Getting Start

### AWS Cloud9 creation
You should create Cloud9 from AWS console first.

### GoToCloud envornment setup
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
Connect to the ParallelCluster head ndoe created above via SSH or niceDCV.
```
gtc_pcluster_ssh.sh
gtc_pcluster_dcv_connect.sh
``` 
### AWS arallelCluster Termination 
If you won't be using Parallelcluster it is recommended to delete the ParallelCluster to stop billing for the relatively expensive head node and Lustre.
you can delete parallelcluster using the following command.
```
gtc_pcluster_delete.sh
``` 

For more information, see: https://sites.google.com/sbrc.jp/gotocloud/procedure



