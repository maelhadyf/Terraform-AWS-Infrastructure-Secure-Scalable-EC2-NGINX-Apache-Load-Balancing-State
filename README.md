# Terraform Infrastructure Setup

This project sets up an AWS environment using Terraform, creating a secure, scalable infrastructure with a mix of public and private resources.

## Project Overview

The infrastructure includes:

- **State Management**: 
  - A remote S3 bucket is used for storing the Terraform state file, preventing multiple users from applying changes simultaneously and ensuring state consistency. The bucket configuration also avoids accidental destruction.
  
- **EC2 Instances**:
  - Four EC2 instances are deployed, each in its own subnet.
  - **Public Instances**: Two EC2 instances are in public subnets, configured as NGINX reverse proxies to handle external traffic.
  - **Private Instances**: Two EC2 instances are in private subnets, running Apache servers that display a success message, `"Well done King Memo"`, when accessed.
  
- **Subnets**:
  - **Public Subnets**: Two subnets are configured for public access, hosting the NGINX reverse proxy instances.
  - **Private Subnets**: Two subnets are configured for private access, hosting the Apache servers.

- **Load Balancers**:
  - **External Load Balancer**: Routes incoming traffic to the public EC2 instances running NGINX.
  - **Internal Load Balancer**: Distributes traffic between the private EC2 instances running Apache.

## Technical Implementation

- **AMI Data Source**:
  - The Amazon Linux AMI ID is dynamically fetched using the AWS AMI data source to ensure compatibility and updated security patches for the EC2 instances.

- **Provisioning**:
  - **Remote Provisioner**: Installs and configures NGINX on the two EC2 instances in public subnets.
  - **User Data**: Configures Apache on the two EC2 instances in private subnets, including the success message.

- **Outputs**:
  - DNS names of the load balancers and IP addresses of the EC2 instances are output for easy reference.

## Outputs

- **Load Balancer DNS**: Displayed for both external (public) and internal (private) load balancers.
- **EC2 Instance IPs**: Shows the public and private IPs of each EC2 instance.

---
