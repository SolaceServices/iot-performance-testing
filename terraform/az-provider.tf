# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.61.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "solace_az_resgrp" {
  count = var.az_resgrp_name == "" ? 1 : 0

  name     = "${var.tag_name_prefix}-solace_resgrp"
  location = var.az_region
}

#Query the AZ Res Group location for the specified AZ Res Group Name
data "azurerm_resource_group" "input_resgroup" {
  count = var.az_resgrp_name == "" ? 0 : 1
  
  name = var.az_resgrp_name
}


