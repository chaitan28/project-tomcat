output "public_ips" {
  description = "Public IPs of all Azure VMs"
  value       = [for ip in azurerm_public_ip.tomcat_public_ip : ip.ip_address]
}
