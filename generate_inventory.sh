#!/bin/bash

# Navega a la carpeta de Terraform
# En Jenkins: infra/ está al mismo nivel que ansible-demoGitea/
# En local: ../TF-INFRA-DEMOGITEA/infra
if [ -d "../infra" ]; then
  # Contexto Jenkins
  cd ../infra || exit 1
else
  # Contexto local
  cd ../TF-INFRA-DEMOGITEA/infra || exit 1
fi

terraform init -reconfigure -backend=true

# Run terraform output to get the public IP address
EC2_IP=$(terraform output -raw ec2_public_ip)

# Verify that a valid IP address was obtained
if [[ -z "$EC2_IP" ]]; then
  echo "Could not obtain the public IP address of the EC2"
  exit 1
fi

# Return to the project's root
if [ -d "../../ansible-demoGitea" ]; then
  # Contexto Jenkins
  cd ../ansible-demoGitea
else
  # Contexto local
  cd ../../ANSIBLE-DEMOGITEA
fi

# Generate the inventory.ini file for Ansible
cat <<EOF2 > inventory.ini
[infraGitea]
ec2-instance ansible_host=$EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/demoCar-jenkins_key.pem
EOF2

echo "inventory.ini file generated with IP: $EC2_IP"
