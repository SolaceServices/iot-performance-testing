# Solace - PubSub+ Azure DMR Horizontal Cluster (no HA) deployed with Terraform & Ansible

## Overview

This repository is a collection of Terraform and Ansible configuration files, that automatically provision (on the AZURE Cloud) the infrastructure required to run an Event Mesh composed of Solace Broker nodes (No HA) linked via DMR.

### Warnings

> :warning: This project is intended to serve as a POC for demonstrating the functionality of the Solace PubSub+ Event Mesh, plus the automation capabilities of the Solace Brokers. Therefore, there are several opportunities for improvement.
> :warning: **Please keep in mind that this code has not been tested or coded to be PRODUCTION ready.**


## Getting Started

There are 4 main subdirectories in this repository: 
- [keys](/keys) - Used to store the private & public keys to access via SSH the Solace Broker HOST, as well as the PEM certificate files to configure TLS on the Brokers. For details on Server Certificates supported please visit the following [link](https://docs.solace.com/Security/Managing-Server-Certs.htm)
- [terraform](/terraform) - Contains Terraform configuration & template files to create resources on the cloud as well as files to be used by Ansible (Inventories, Playbooks, Variables)
- [ansible](/ansible) - Contains playbooks, inventories, variables & roles to be used by Ansible to configure the VMs. There are static files that can be modified according to what is needed, as well as files that will get dynamically created by Terraform upon execution, based on the resources terraform creates (ex: public or private IPs, etc.).
- [images](/images) - Contains images for the README files

Inside those subdirectories, there are README files that can provide extra information as well as describing what CAN or HAS TO be configured on each section.

### Prerequisites

General

+ A control host that will run the Terraform & Ansible Scripts 
+ Install Terraform on the Host - Instructions [here](https://learn.hashicorp.com/terraform/getting-started/install.html)
+ Install Ansible on the host - Instructions [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
+ Disable host key checking by the underlying tools Ansible uses to connect to the host 
   ```
     export ANSIBLE_HOST_KEY_CHECKING=false
   ```

Azure

**Configure Terraform to use the credentials of a sufficiently privileged IAM role**  
   The easiest approach is to create a new Service Principal and a Client Secret as described [here](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)

   And specify the following ENV variables:
   ```   
     export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
     export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
     export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
     export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```

   If creating a new Service Principal with the Contributor role is not possible, you can have terraform use the Azure CLI login as described [here](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html), Basically you will have to run the "az loging" command first on the CLI session running Terraform & Ansible, and specify the following ENV variables:
   ```   
     export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
     export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```

   If the Azure CLI has no valid session, when running Terraform plan or apply an error similar to this should be received:
   ```   
   "Error: Error building account: Error getting authenticated object ID: Error parsing json result from the Azure CLI: Error waiting for the Azure CLI: exit status 1"
   ```      
## Updating Variables
[az-variables.tf](/terraform/az-variables.tf) is the variable file where all the following details needs to be varified/updated:
1. az_region - The Azure region where the deployment will take place
2. public_key_path/public_key_path - SSH key file path and name
3. tag_owner,tag_days,tag_purpose - Tags to be associated with resource created
4. tag_name_prefix - All the resource name will be prefixed by this prefix
5. solace_broker_count - numbert of broker nodes to be created
6. sol_messaging_vm_type - The Azure VM type that needs to be created. (for eg.: D2s_v3, D8_v3, etc.)
7. az_resgrp_name - Azure resource group. Leave the default value empty if you want to create a new resource grouop as part of the script.
8. subnet_id - Azure subnet_id. Leave the default value empty if you want to create a new subnet_id as part of the script.
9. solbroker_secgroup_ids - Azure Security group Id. Leave the default value empty if you want to create a new security group as part of the script.

## Configuring SSH Keys and TLS Certificates
SSH Keys

+ Configure the private & public SSH keys required to login & setup the hosts.
+ Take a look at the README file inside [/keys](/keys) for a more detailed description on how to do it.
> :warning: The SSH keys to be used should have restrictive permissions (ex: 600), otherwise Terraform and Ansible could trigger an error while connecting to the VMs

TLS Keys

+ TLS Certificate can be configure on the Solace Brokers to enable a secure channel between them and the applications.
+ To have these scripts configure TLS on the Brokers, copy both the certificate PEM file as well as the RootCA PEM file (that issued the certificate) inside the [/keys](/keys) folder, and modify the ansible variables "tls_cert_file" and "certAuthorityContent" to match their file names respectively inside the ansible playbook file [az-sa-sol-broker-centosnodes.yml](/ansible/playbooks/bootstrap/az-sa-sol-broker-centosnodes.yml)
+ This script can create more than 1 broker nodes. This script will use the same certificate file for all the nodes.

## Running the Script - Creating Resources

Once all the variables and configurations have been set according to our needs, we can have Terraform create all the infrastructure for us, by going into the appropriate PATH where the Terraform resource files are located (in this case: [/terraform](/terraform)) and typing the following commands:

   ```   
     terraform init
     terraform apply
   ```

and typing "yes" when prompted.

## Destroying the resources

Once testing has concluded and the cloud resources are no longer needed, all of them can be destroyed by simply going into the appropriate PATH where the Terraform resource files are located (in this case: [/terraform](/terraform)) and running the Terraform command: 

   ```   
     terraform destroy
   ```

and typing "yes" when prompted.

## Scripts Highlights 

**List of Tasks to be executed by Ansible at bootstrap**:

On Solace Broker nodes:

+ Enable SWAP on the VM 
+ Partition, Format & Mount external disk
+ Create & Assign permissions for the Broker folders on the external disk
+ Install Docker CE
+ Install docker-compose
+ Parse & upload docker-compose template according to the Solace Broker type (Standard, Enterprise or Enterprise Eval) & Node Role (Standalone, Primary, Backup or Monitor)
+ Copy Solace Broker Image to VM (Only for Enterprise or Enterprise Eval)
+ Load Solace Broker Image (Only for Enterprise or Enterprise Eval)
+ Create and Run Solace Docker container according to the created docker-compose file
+ Install performance monitoring tools on the OS: HTOP, sysstat (iostat)
+ Wait for SEMP to be ready
+ SEMP requests to create Solace configurations on the Solace Brokers

## Customizing the Demo

If you need to customize the PS+ Cache configurations, it can be done by modifing the following files:
+ [/ansible/playbooks/bootstrap/vars/solcache-solace-semp-vars.yml](/ansible/playbooks/bootstrap/vars/solcache-solace-semp-vars.yml) - contains all the values to be used on the SEMP calls used to configure our broker (VPN name, clientusernames, cache clusters, etc)
+ [/ansible/playbooks/bootstrap/aws-cache-centosnodes.yml](/ansible/playbooks/bootstrap/aws-cache-centosnodes.yml) - contains the ansible tasks, plus the variables (VPN name, clientusername, cache instance, etc.) to be used while configuring the PS+ Cache nodes
+ [/ansible/playbooks/bootstrap/aws-client-centosnodes.yml](/ansible/playbooks/bootstrap/aws-client-centosnodes.yml) - contains the ansible tasks, plus the variables (VPN name, clientusername, distributed cache name, etc.) to be used while configuring the MarketData node
+ [/ansible/playbooks/bootstrap/roles/md_demo/MDFeedhandler/tasks/main.yml](/ansible/playbooks/bootstrap/roles/md_demo/MDFeedhandler/tasks/main.yml) - contains the ansible tasks, plus the variables to be used while starting the MDFeedHandler processes. Here you could start more than 2 Exchanges, or modify their name.


## Authors

See the list of [contributors](https://github.com/solacese/terraform-ansible-solace-sdkperf/graphs/contributors) who participated in this project.

## Resources

**To tie Terraform and Ansible together, we do two things:**

- Run an Ansible playbook after the Virtual Machine has been provisioned using Terraform's "local_exec" provisioner
- Generate inventory files from our VM instances by formatting Terraform's output

Terraform will automatically use the playbooks under [/ansible/playbooks/bootstrap](/ansible/playbooks/bootstrap)  to set up our VM instances.  

For more information try these resources:

- Introduction to Terraform at: https://www.terraform.io/intro/index.html
- How Ansible Works at: https://www.ansible.com/overview/how-ansible-works
- Ansible Intro to Playbooks at: https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html
- Ansible and HashiCorp (Terraform): Better Togethers at: https://www.hashicorp.com/resources/ansible-terraform-better-together/
- Terraform AWS provider docs at: https://www.terraform.io/docs/providers/aws/index.html
- Install Azure CLI - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
- Amazon EC2 Instance Types at: https://aws.amazon.com/ec2/instance-types/
- Get a better understanding of [Solace technology](http://dev.solace.com/tech/).
- Check out the [Solace blog](http://dev.solace.com/blog/) for other interesting discussions around Solace technology
- Ask the [Solace community.](http://dev.solace.com/community/)
