# aws-infra
Setting up AWS Infrastructure to deploy a webapp created as part of CSYE 6225 curriculam

To start off, you will need to have aws cli and terraform installed.
Also you will need to have an aws account setup and access keys configured using aws configure

#To initialise run:
terraform init

#To check how things will work before actually creating run:
terraform plan

#To finally setup the aws environment run:
terraform apply
