provider "azurerm" {
  features {}
}

# Specify the desired resource group name
variable "resource_group_name" {
  default = "my-resource-group"
}

# Create a resource group
resource "azurerm_resource_group" "my_group" {
  name     = var.resource_group_name
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "my_vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_group.location
  resource_group_name = azurerm_resource_group.my_group.name
}

# Create two subnets within the virtual network
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name = azurerm_resource_group.my_group.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes    = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name = azurerm_resource_group.my_group.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes    = ["10.0.2.0/24"]
}

# Create a virtual machine in subnet1
resource "azurerm_virtual_machine" "my_vm" {
  name                  = "my-vm"
  location              = azurerm_resource_group.my_group.location
  resource_group_name   = azurerm_resource_group.my_group.name
  network_interface_ids = [azurerm_network_interface.my_network_interface.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option    = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
  }
}

# Create a network interface for the virtual machine
resource "azurerm_network_interface" "my_network_interface" {
  name                = "my-nic"
  location            = azurerm_resource_group.my_group.location
  resource_group_name = azurerm_resource_group.my_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}
