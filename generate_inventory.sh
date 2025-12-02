#!/bin/bash

# Navega a la carpeta de Terraform
cd ../tf-infra-demoCar/infra || exit 1

terraform init -reconfigure -backend=true

# Run terraform output to get the public IP address
EC2_IP=$(terraform output -raw ec2_public_ip)

# Verify that a valid IP address was obtained
if [[ -z "$EC2_IP" ]]; then
  echo "Could not obtain the public IP address of the EC2"
  exit 1
fi

# Return to the project's root
cd ..

# Generate the inventory.ini file for Ansible
cat <<EOF2 > inventory.ini
[infraGitea]
ec2-instance ansible_host=$EC2_IP ansible_user=ec2-user
EOF2

echo "inventory.ini file generated with IP: $EC2_IP"
