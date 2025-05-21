terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.99"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tomcat-resources"
    storage_account_name = "tomcatios231"
    container_name       = "tomcatioscontainer"
    key                  = "Azure-infra/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "1d342b09-7474-440d-a4c0-4d42e7768976"
}

# Virtual Network
resource "azurerm_virtual_network" "tomcat_vnet" {
  name                = "tomcat-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tomcat_rg.location
  resource_group_name = tomcat-resources
}

# Subnet
resource "azurerm_subnet" "tomcat_subnet" {
  name                 = "tomcat-subnet"
  resource_group_name  = tomcat-resources
  virtual_network_name = azurerm_virtual_network.tomcat_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (equivalent to AWS Security Group)
resource "azurerm_network_security_group" "tomcat_nsg" {
  name                = "tomcat-nsg"
  location            = azurerm_resource_group.tomcat_rg.location
  resource_group_name = tomcat-resources

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Tomcat"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP for each VM
resource "azurerm_public_ip" "tomcat_public_ip" {
  count               = length(var.tomcat_instances)
  name                = "tomcat-public-ip-${count.index}"
  location            = azurerm_resource_group.tomcat_rg.location
  resource_group_name = tomcat-resources
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "tomcat_nic" {
  count               = length(var.tomcat_instances)
  name                = "tomcat-nic-${count.index}"
  location            = azurerm_resource_group.tomcat_rg.location
  resource_group_name = tomcat-resources

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tomcat_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tomcat_public_ip[count.index].id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = length(var.tomcat_instances)
  network_interface_id      = azurerm_network_interface.tomcat_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.tomcat_nsg.id
}

# Virtual Machines (equivalent to AWS EC2 instances)
resource "azurerm_linux_virtual_machine" "tomcat_vm" {
  count               = length(var.tomcat_instances)
  name                = "${var.tomcat_instances[count.index]}-server"
  resource_group_name = tomcat-resources
  location            = azurerm_resource_group.tomcat_rg.location
  size                = var.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tomcat_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/MySSHKey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = filebase64("tomcat_setup.sh")

  tags = {
    Environment = var.tomcat_instances[count.index]
  }
}