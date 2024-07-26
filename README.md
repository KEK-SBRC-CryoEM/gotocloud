# GoToCloud

GoToCloud is a cloud-computing-based platform for advanced data analysis and data management for Cryo-EM SPA.

## Getting Start
The following instructions are for using the GoToCloud platform provided by KEK.
<br>
Instructions on how to build your own GoToCloud platform are provided at the end.
<br>
For more information, see: https://sites.google.com/sbrc.jp/gotocloud-doc/procedure
<br>
### Preparation: Create AWS Cloud9
You should create Cloud9 from AWS console first.
1. Navigate to Cloud9 console page.
1. Create environment.
	1. Enter "Project name" (e.g. protein-240101) into "Name" box.
	1. Select "Amazon Linux 2" in "Platform".
	1. Select "Secure Shell (SSH)"  in "Connection".
	1. Select "Name - kek-gtc-user-vpc" in "Amazon Virtual Private Cloud (VPC)".
	1. Select "Name - kek-gtc-user-subnet1" in "Subnet".
	1. Create Cloud9.
1. Open Cloud9 IDE.

### Step1: Set up GoToCloud envornment on Cloud9
Then, execute the following commands in Cloud9 terminal to setup GoToCloud envornment. 
```
cd ~/environment
wget https://kek-gtc-master-s3-bucket.s3.ap-northeast-1.amazonaws.com/gtc_setup_gotocloud_environment.sh
chmod 755 ~/environment/gtc_setup_gotocloud_environment.sh
./gtc_setup_gotocloud_environment.sh
``` 
### Step2: Create AWS arallelCluster instance
Open the new Cloud9 terminal and create parallelcluster using the following command.
```
gtc_pcluster_create.sh
``` 
### Step3: Connect to head node of AWS ParallelCluster instance
Connect to the ParallelCluster head ndoe created above via niceDCV.
```
gtc_pcluster_dcv_connect.sh
```
**or** via SSH
```
gtc_pcluster_ssh.sh
``` 
### Step4: AWS ParallelCluster Termination 
If you won't be using Parallelcluster it is recommended to delete the ParallelCluster to stop billing for the relatively expensive head node and Lustre.
you can delete parallelcluster using the following command.
```
gtc_pcluster_delete.sh
``` 
### Step5: Delete GoToCloud environment from Cloud9
you can delete　delete GoToCloud after the project is completed.
Delete AWS S3 bucket and EC2 key pair.
```
gtc_aws_delete_s3_and_key_pair.sh
``` 
Finally, delete Cloud9 instance from the AWS Cloud9 console page.

## Building your own GoToCloud platform
You can construct your own GoToCloud platform by AWS CloudFormation.
Our Web site describes the following steps are required.
You can find more eraborated instruction here: https://sites.google.com/sbrc.jp/gotocloud-doc/build

### Step1.Creating Master EFS
### Step2.Creating Shared EFS
### Step3.Creating VPC peering to data analysis VPC
### Step4.Installation to master EFS

