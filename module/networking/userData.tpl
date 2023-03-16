#!/bin/bash
sudo echo "DB_HOSTNAME=${db_hostname}" >> /home/ec2-user/project/.env
sudo echo "DB_USERNAME=${db_username}" >> /home/ec2-user/project/.env
sudo echo "DB_PASSWORD=${db_password}" >> /home/ec2-user/project/.env
sudo echo "DB_NAME=${db_name}" >> /home/ec2-user/project/.env
sudo echo "DB_ENDPOINT=${db_endpoint}" >> /home/ec2-user/project/.env
sudo echo "Bucket=${bucket_name}" >> /home/ec2-user/project/.env
sudo echo "AWS_DEFAULT_REGION=${aws_default_region}" >> /home/ec2-user/project/.env
sudo echo "AWS_KEY=${aws_key}" >> /home/ec2-user/project/.env
sudo echo "AWS_ID=${aws_id}" >> /home/ec2-user/project/.env
