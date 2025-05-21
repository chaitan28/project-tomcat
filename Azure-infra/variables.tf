variable "azure_region" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "tomcat_instances" {
  description = "List of Tomcat instance names/environments"
  type        = list(string)
  default     = ["dev", "stage", "prod"]
}

variable "vm_size" {
  description = "Size of the Azure VM"
  type        = string
  default     = "Standard_B1s"  # Equivalent to AWS t2.small
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "adminuser"
}


variable "source_image" {
  description = "Source image for the VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "demo"
  }
}