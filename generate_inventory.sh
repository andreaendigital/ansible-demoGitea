#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to Terraform infra directory
# Jenkins workspace structure: workspace/Gitea/infra/
cd "$SCRIPT_DIR/../infra" || exit 1

terraform init -reconfigure -backend=true

# Run terraform output to get the public IP address
EC2_IP=$(terraform output -raw ec2_public_ip)

# Verify that a valid IP address was obtained
if [[ -z "$EC2_IP" ]]; then
  echo "Could not obtain the public IP address of the EC2"
  exit 1
fi

# Return to ansible directory
cd "$SCRIPT_DIR" || exit 1

# Generate the inventory.ini file for Ansible
cat <<EOF2 > inventory.ini
[infraGitea]
ec2-instance ansible_host=$EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/demoCar-jenkins_key.pem
EOF2

echo "inventory.ini file generated with IP: $EC2_IP"
