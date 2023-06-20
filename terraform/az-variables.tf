####################################################################################################
# INSTRUCTIONS:
# (1) Customize these variables to your perference
# (2) Make sure the account you're running terraform with has proper permissions in your Azure env
####################################################################################################

# Azure config
variable "az_region" {
  default = "East US"   # DSv2 10, DSv3 51  Supports AZ
#  default = "West US"  # DSv2 100, DSv3 10  No AZ Supports, Supports UltraD not in AZ - Total Regional vCPUs 130
#  default = "West US 2" # DSv2 10, DSv3 10  Supports AZ, Supports UltraD in 3 AZ    - Total Regional vCPUs 10 
#  default = "Japan East" # DSv2 100, DSv3 10 Supports AZ, Supports UltraD in 2 AZ   - Total Regional vCPUs 160
}

# ssh config
# If no  Private and Public Keys exist, they can be created with the "ssh-keygen -f ../aws_key" command
variable "public_key_path" {
  default = "../keys/SolAzure_key.pub"
  description = "Local path to the public key to be used on the Azure VMs"
}
variable "private_key_path" {
  default = "../keys/SolAzure_key"
  description = "Local path to the private key used to connect to the Instances (Not to be uploaded to AWS)"
}
variable "az_admin_username" {
  default = "centos"
  type        = string
  description = "The admin username to be used for accesing this Azure VM"
}

# General Variables
variable "tag_owner" {
  default = "Manuel Moreno"
}
variable "tag_days" {
  default = "5"
}
variable "tag_purpose" {
  default = "EventMesh Testing"
}
variable "tag_name_prefix" {
  default = "mmoreno-eventmesh"
}

# solace broker nodes count
variable "solace_broker_count" {
    default = "3"
    type        = string
    description = "The number of Solace Broker nodes to be created."
}
variable "sol_messaging_vm_type" {

#  default = "Standard_DS2_v2"   # (2 cpus  7G Ram, Max  6400 IOPs  96 MB/s - General Purpose VM)
  default = "Standard_D2s_v3"   # (2 cpus  8G Ram, Max  3200 IOPs  48 MB/s - General Purpose VM)
#  default = "Standard_DS3_v2"   # (4 cpus 14G Ram, Max 12800 IOPs 192 MB/s - General Purpose VM)
#  default = "Standard_D4s_v3"   # (4 cpus 16G Ram, Max 6400 IOPs 96 MB/s - General Purpose VM) - Supports Ultradisks
#  default = "Standard_F4s_v2"    # (4 cpus  8G Ram, Max  6400 IOPs  95 MB/s - Compute Optimized VM)
#  default = "Standard_L4s"       # (4 cpus  32G Ram, Max  5000 IOPs  ?? MB/s - Storage Optimized VM)
}
variable "sol_monitor_vm_type" {
  default = "Standard_DS2_v2"   # (2 cpus  7G Ram, Max  6400 IOPs  96 MB/s - General Purpose VM)
}

variable "az_resgrp_name" {
  default = ""
  #default = "subnet-0db7d4f1da1d01bd8"
  type        = string
  description = "The Azure Resource Group Name to be used for containing the resources - Leave the value empty for automatically creating one."
}

variable "subnet_id" {
  default = ""
  #default = "subnet-0db7d4f1da1d01bd8"
  type        = string
  description = "The Azure subnet_id to be used for creating the nodes - Leave the value empty for automatically creating one."
}
variable "solbroker_secgroup_ids" {
  default = [""]
  #default = ["sg-08a5f21a2e6ebf19e"]
  description = "The Azure security_group_ids to be asigned to the Solace broker nodes - Leave the value empty for automatically creating one."
}

# Solace Broker External Storage Variables
variable "solbroker_storage_device_name" {
  default = "/dev/sdc"
  description = "device name to assign to the storage device"
}
variable "solbroker_storage_size" {
#  default         = "128"  # (  500 IOPs 	100 MB/second Throughput)
#  default         = "256"  # (1,100 IOPs 	125 MB/second Throughput)
  default         = "512"  # (2,300 IOPs 	150 MB/second Throughput)
#  default         = "1024" # (5,000 IOPs 	200 MB/second Throughput)  

  description = "Size of the Storage Device in GB"
}
variable "solbroker_storage_iops" {
  default = "3000"
  description = "Number of IOPs to allocate to the Storage device - must be a MAX ratio or 1:50 of the Storage Size"
}

