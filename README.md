# aws-infra
Prerequisites:

AWS Command Line Interface (CLI):
. Configure AWS for IAM profile.
  Command: AWS CONFIGURE --profile <#profileName>
. Set AWS Credentials.
   AWS Access Key ID [None]: XXXXXXXXXXXXXXXXXXXX
   AWS Secret Access Key [None]: YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
   Default region name [None]: xx-xxxx-x
   Default output format [None]: 

. Set Profile:
  Set profileName in provider.tf
  
. Set CIDR:
  Set CIDR value in main.tf
  
 Terraform:
. Install Terraform 
. Initialize Terraform 
  Command: terraform init
. Create Infrastructure
  Command: terraform apply
. Delete Infrastructure
  Command: terraform destroy 

Networking Resources:
. Create Virtual Private Cloud (VPC)
. Create Public Subnets (3)
. Create Private Subnets (3)
. Create Internet Gateway
. Create Private Route Table
. Create Public Route Table
