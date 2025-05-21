# List of public IPs of all VMs
output "public_ips" {
  description = "Public IPs of all Azure VMs"
  value       = [for ip in azurerm_public_ip.tomcat_public_ip : ip.ip_address]
}

# Map of VM name to public IP
output "vm_public_ip_map" {
  description = "Map of VM name to its public IP"
  value = {
    for idx, name in var.tomcat_instances :
    name => azurerm_public_ip.tomcat_public_ip[idx].ip_address
  }
}

# List of private IPs of all VMs (optional)
output "private_ips" {
  description = "Private IPs of all Azure VMs"
  value       = [for nic in azurerm_network_interface.tomcat_nic : nic.ip_configuration[0].private_ip_address]
}
