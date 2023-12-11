#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Create EFS Shared path
sudo mkdir -p /app
sudo mount -t efs ${efs_id}:/ /app
sudo yum -y install git rpm-build make
git clone https://github.com/aws/efs-utils
cd efs-utilss
make rpm
sudo yum -y install build/amazon-efs-utils*rpm
sudo chown -R 755 /app


# Edit /etc/fstab to add the following lines
sudo echo "${efs_id}    /app     efs _netdev,noresvport      0       0" >> /etc/fstab
# Remount filesystems
sudo mount -a
