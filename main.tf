# Terraform docs https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

# Add line 6 to 20 to configure terraform provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
# line24 name is alias of resource that you can reference for other resources as dependencies
# we reference in line 32
resource "azurerm_resource_group" "test-rg" {
  name     = "test-rg"
  location = "eastus2"
}


# Create Vnet with a subnet
resource "azurerm_virtual_network" "test-vnet" {
  name                = "test-vnet"
  location            = azurerm_resource_group.test-rg.location # reference another resource- dependency
  resource_group_name = azurerm_resource_group.test-rg.name
  address_space       = ["10.0.0.0/23"]
}


resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.test-rg.name
  virtual_network_name = azurerm_virtual_network.test-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.test-rg.name
  virtual_network_name = azurerm_virtual_network.test-vnet.name
  address_prefixes     = ["10.0.1.192/27"]
}

# #  Create App service ASE
# resource "azurerm_service_plan" "hejuase12" {
#   name                = "hejuase12"
#   resource_group_name = azurerm_resource_group.test-rg.name
#   location            = azurerm_resource_group.test-rg.location
#   sku_name            = "F1"
#   os_type             = "Windows"
# }

# resource "azurerm_windows_web_app" "hejuwebapp" {
#   name                = "hejuwebapp"
#   resource_group_name = azurerm_resource_group.test-rg.name
#   location            = azurerm_service_plan.hejuase12.location
#   service_plan_id     = azurerm_service_plan.hejuase12.id
#   site_config {
#   }
# }

# Create NSG Rule
resource "azurerm_network_security_group" "test_nsg" {
  name                = "acceptanceTestNSGRule1"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  security_rule {
    name                       = "test-rule1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "test-rule2"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "Development"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgapply" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.test_nsg.id
}


resource "azurerm_public_ip" "ip1" {
  name                = "ip1"
  resource_group_name = azurerm_resource_group.test-rg.name
  location            = azurerm_resource_group.test-rg.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip1.id
  }
}

resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.test-rg.location
  resource_group_name   = azurerm_resource_group.test-rg.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  size                  = "Standard_B1ls"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Justtest1234#"
  disable_password_authentication = false
}