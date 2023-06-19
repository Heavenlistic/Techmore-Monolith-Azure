provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "techmore" {
  name     = "techmore-rg"
  location = "canadacentral"
}
resource "azurerm_virtual_network" "techmore" {
  name                = "techmore-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.techmore.location
  resource_group_name = azurerm_resource_group.techmore.name
}
resource "azurerm_subnet" "techmore" {
  name           = "techmore-subnet"
  resource_group_name  = azurerm_resource_group.techmore.name
  virtual_network_name = azurerm_virtual_network.techmore.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "techmore" {
  name                = "techmore-nsg"
  location            = azurerm_resource_group.techmore.location
  resource_group_name = azurerm_resource_group.techmore.name
}
resource "azurerm_network_interface" "techmore" {
  name                = "techmore-nic"
  location            = azurerm_resource_group.techmore.location
  resource_group_name = azurerm_resource_group.techmore.name
  ip_configuration {
    name                          = "techmore-ipconfig"
    subnet_id                     = azurerm_subnet.techmore.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}
resource "azurerm_virtual_machine" "techmore" {
  name                  = "mytechmore-vm"
  location              = azurerm_resource_group.techmore.location
  resource_group_name   = azurerm_resource_group.techmore.name
  network_interface_ids = [azurerm_network_interface.techmore.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "mytechmore-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "mytechmore"
    admin_username = "adminuser"
    admin_password = "password123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}