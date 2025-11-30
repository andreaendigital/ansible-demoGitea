# CarPrice Prediction Application - Ansible Deployment

## Overview

This project provides automated deployment of a Flask-based car price prediction application using Ansible configuration management. The deployment includes a machine learning backend API, web frontend interface, and comprehensive monitoring solution.

## Architecture

The application follows a microservices architecture with the following components:

- **Backend API Service**: Flask REST API serving ML predictions on port 5002
- **Frontend Web Service**: User interface for car price predictions on port 3000  
- **Monitoring Stack**: Splunk OpenTelemetry Collector for observability and metrics

## Prerequisites

- **Ansible**: Version 2.9 or higher
- **Python**: Version 3.6 or higher
- **Terraform**: For infrastructure provisioning (EC2 instance)
- **SSH Access**: Private key for EC2 instance authentication
- **AWS Account**: With appropriate permissions for EC2 deployment

## Project Structure

```
configManagement-carPrice/
├── roles/deploy/                    # Ansible deployment role
│   ├── tasks/main.yml              # Complete deployment workflow
│   └── templates/                  # Systemd service templates
│       ├── backend.service         # Backend API service configuration
│       └── frontend.service        # Frontend web service configuration
├── ansible.cfg                     # Ansible configuration settings
├── generate_inventory.sh           # Dynamic inventory generation script
├── inventory.ini                   # Ansible inventory file (auto-generated)
├── playbook.yml                   # Main deployment playbook
└── README.md                      # Project documentation
```

## Deployment Instructions

### Step 1: Infrastructure Setup
Ensure your EC2 infrastructure is provisioned via Terraform in the parent `infra/` directory.

### Step 2: Generate Dynamic Inventory
```bash
chmod +x generate_inventory.sh
./generate_inventory.sh
```
This script automatically retrieves the EC2 public IP from Terraform state and generates the Ansible inventory.

### Step 3: Execute Deployment
```bash
# Dry run to validate configuration
ansible-playbook playbook.yml --check

# Production deployment
ansible-playbook playbook.yml
```

### Step 4: Verify Deployment
After successful deployment, verify services are running:
```bash
# Check service status
ansible infraCar -m shell -a "systemctl status backend frontend"

# Test API endpoints
curl http://<EC2_IP>:5002/health
curl http://<EC2_IP>:3000
```

## Service Configuration

### Backend API Service
- **Port**: 5002
- **Environment**: Production
- **Runtime**: Python 3 with virtual environment
- **Auto-restart**: Enabled via systemd

### Frontend Web Service  
- **Port**: 3000
- **Dependencies**: Backend API service
- **Runtime**: Python 3 with virtual environment
- **Auto-restart**: Enabled via systemd

### Monitoring Service
- **Provider**: Splunk OpenTelemetry Collector
- **Metrics**: System metrics (CPU, memory, disk, network)
- **Application Metrics**: Custom Flask application metrics
- **Realm**: us1

## Troubleshooting

### Common Issues

**SSH Connection Failed**
```bash
# Verify SSH key permissions
chmod 600 ~/.ssh/demoCar-jenkins_key.pem

# Test SSH connectivity
ssh -i ~/.ssh/demoCar-jenkins_key.pem ec2-user@<EC2_IP>
```

**Service Start Failures**
```bash
# Check service logs
ansible infraCar -m shell -a "journalctl -u backend -f"
ansible infraCar -m shell -a "journalctl -u frontend -f"
```

**Inventory Generation Issues**
```bash
# Verify Terraform state
cd ../infra && terraform output ec2_public_ip
```

## Security Considerations

- SSH keys are stored locally and referenced via absolute paths
- Services run under `ec2-user` with minimal privileges
- Systemd services include restart policies for high availability
- Monitoring tokens are embedded for demonstration purposes

## Maintenance

### Service Management
```bash
# Restart services
ansible infraCar -m systemd -a "name=backend state=restarted" --become
ansible infraCar -m systemd -a "name=frontend state=restarted" --become

# View service status
ansible infraCar -m systemd -a "name=backend" --become
```

### Log Management
```bash
# View application logs
ansible infraCar -m shell -a "journalctl -u backend --since '1 hour ago'"
```

## Contributing

1. Follow Ansible best practices for task organization
2. Test deployments in development environment before production
3. Update documentation for any configuration changes
4. Ensure idempotent task execution

## License

This project is developed for educational purposes as part of DevOps coursework.

---

**Author**: DevOps Engineering Student  
**Course**: Infrastructure as Code & Configuration Management  
**Institution**: [Your Institution Name]

<!-- Version: 1.0.1 - Updated GitHub templates -->