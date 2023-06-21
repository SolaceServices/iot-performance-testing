####################################################################################################
# NOTE: The following network resources will only get created if:
# 
####################################################################################################

resource "azurerm_lb" "solace_lb" {
  name                = "${var.tag_name_prefix}-lb"
  sku                 = "Standard"
  location            = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name

  frontend_ip_configuration {
    name                 = "${var.tag_name_prefix}-lb-front-ip"
    public_ip_address_id = azurerm_public_ip.solace_lb_pubip.id
  }

  tags = {
    Name    = "${var.tag_name_prefix}-lb"
    Owner   = var.tag_owner
    Purpose = "${var.tag_purpose}-loadbalancer"
    Days    = var.tag_days
  }
}

resource "azurerm_public_ip" "solace_lb_pubip" {
  name                = "${var.tag_name_prefix}-lb-pubip"
  sku                 = "Standard"
  location            = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.solace_az_resgrp[0].name : var.az_resgrp_name
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "solace_lb_backaddresspool" {
  name            = "${var.tag_name_prefix}-lb-backaddresspool"
  loadbalancer_id = azurerm_lb.solace_lb.id
}

resource "azurerm_lb_backend_address_pool_address" "solace_lb_backaddresspool-address" {
  count = var.solace_broker_count

  name                    = "${var.tag_name_prefix}-lb-backaddresspool-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.solace_lb_backaddresspool.id
  virtual_network_id      = azurerm_virtual_network.solace_network[0].id
  ip_address              = azurerm_linux_virtual_machine.solace-broker-nodes[count.index].private_ip_address
}

resource "azurerm_lb_probe" "solace_lb_probe" {
  loadbalancer_id   = azurerm_lb.solace_lb.id
  name              = "${var.tag_name_prefix}-lb-probe"
  port              = 5550
  protocol          = "Http"
  request_path      = "/health-check/guaranteed-active"
}

resource "azurerm_lb_rule" "solace_lb_rule_msging_pt" {
  loadbalancer_id                = azurerm_lb.solace_lb.id
  name                           = "LBRule_Msging_pt"
  load_distribution              = "Default"
  protocol                       = "Tcp"
  frontend_port                  = 55555
  backend_port                   = 55555
  frontend_ip_configuration_name = azurerm_lb.solace_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.solace_lb_backaddresspool.id]
  probe_id                       = azurerm_lb_probe.solace_lb_probe.id
}

resource "azurerm_lb_rule" "solace_lb_rule_mqtt_default_pt" {
  loadbalancer_id                = azurerm_lb.solace_lb.id
  name                           = "LBRule_mqtt_default_pt"
  load_distribution              = "Default"
  protocol                       = "Tcp"
  frontend_port                  = 1883
  backend_port                   = 1883
  frontend_ip_configuration_name = azurerm_lb.solace_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.solace_lb_backaddresspool.id]
  probe_id                       = azurerm_lb_probe.solace_lb_probe.id
}