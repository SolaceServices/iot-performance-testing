####################################################################################################
# NOTE: The following network resources will only get created if:
# The "sdkperf_secgroup_ids" variable is left "empty"
####################################################################################################


resource "azurerm_network_security_group" "solbroker_secgrp" {

  name                = "${var.tag_name_prefix}-solbroker_secgrp"
  location            = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name
  
  tags = {
    Name    = "${var.tag_name_prefix}-solbroker_secgrp"
    Owner   = var.tag_owner
    Purpose = "${var.tag_purpose}"
    Days    = var.tag_days
  }
}

resource "azurerm_network_security_rule" "solbroker-ssh" {
  name                        = "SSH"
  priority                    = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solbroker_secgrp.name
}

resource "azurerm_network_security_rule" "solbroker-sshcli" {
  name                        = "SSH-CLI"
  priority                    = 101
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "2222"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solbroker_secgrp.name
}

resource "azurerm_network_security_rule" "solbroker-webportal-pt" {
  name                        = "WebPortal-PT"
  priority                    = 102
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "8080"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solbroker_secgrp.name
}

resource "azurerm_network_security_rule" "solbroker-msging-pt" {
  name                        = "SolMessaging-PT"
  priority                    = 103
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "55555"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solbroker_secgrp.name
}

resource "azurerm_network_security_rule" "solbroker-mqtt-pt" {
  name                        = "SolMQTT_PT"
  priority                    = 104
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "1883"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solbroker_secgrp.name
}
