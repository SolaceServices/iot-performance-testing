output "solace-broker-node-private-ips" {
  value = ["${azurerm_linux_virtual_machine.solace-broker-nodes.*.private_ip_address}"]
}
output "solace-broker-node-public-ips" {
  value = ["${azurerm_linux_virtual_machine.solace-broker-nodes.*.public_ip_address}"]
}
output "solace-broker-loadbalancer-public-ip" {
  value = ["${azurerm_public_ip.solace_lb_pubip.ip_address}"]
}
output "solace-broker-node-public-dns" {
  value = ["${azurerm_public_ip.solbroker-nodes-pubip.*.fqdn}"]
}
output "solace-broker-loadbalancer-public-dns" {
  value = ["${azurerm_public_ip.solace_lb_pubip.fqdn}"]
}