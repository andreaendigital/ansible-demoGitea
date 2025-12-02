#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to Terraform infra directory
# Jenkins workspace structure: workspace/Gitea/infra/
cd "$SCRIPT_DIR/../infra" || exit 1

terraform init -reconfigure -backend=true

# Run terraform output to get EC2 IP and RDS credentials
EC2_IP=$(terraform output -raw ec2_public_ip)
RDS_ENDPOINT=$(terraform output -raw infraGitea_rds_endpoint)
RDS_ADDRESS=$(terraform output -raw infraGitea_rds_address)
MYSQL_USERNAME=$(terraform output -raw infraGitea_mysql_username)
MYSQL_PASSWORD=$(terraform output -raw infraGitea_mysql_password)
MYSQL_DBNAME=$(terraform output -raw infraGitea_mysql_dbname)

# Verify that a valid IP address was obtained
if [[ -z "$EC2_IP" ]]; then
  echo "Could not obtain the public IP address of the EC2"
  exit 1
fi

# Return to ansible directory
cd "$SCRIPT_DIR" || exit 1

# Generate the inventory.ini file for Ansible with RDS variables
cat <<EOF2 > inventory.ini
[infraGitea]
ec2-instance ansible_host=$EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/demoCar-jenkins_key.pem

[infraGitea:vars]
rds_endpoint=$RDS_ENDPOINT
rds_address=$RDS_ADDRESS
mysql_username=$MYSQL_USERNAME
mysql_password=$MYSQL_PASSWORD
mysql_dbname=$MYSQL_DBNAME
EOF2

echo "inventory.ini file generated with IP: $EC2_IP"
echo "RDS endpoint configured: $RDS_ENDPOINT"
