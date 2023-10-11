# --- provider ---

terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "=0.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}



# --- Resource group ---

resource "azurerm_resource_group" "resource_group"{
  name = "sudip-10oct-rg"
  location = "uksouth"#"eastus"

}


# --- Virtual network & subnets ---

resource "azurerm_virtual_network" "custom_vnet" {
  name = "sudip-10oct-vnet"
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space = ["12.12.0.0/24"]
}

resource "azurerm_subnet" "subnet_public_1" {
  name = "sudip-10oct-subnet-public-1"
  resource_group_name = azurerm_resource_group.resource_group.name
  address_prefixes = ["12.12.0.0/26"]
  virtual_network_name = azurerm_virtual_network.custom_vnet.name
}

resource "azurerm_subnet" "subnet_public_2" {
  name = "sudip-10oct-subnet-public-2"
  resource_group_name = azurerm_resource_group.resource_group.name
  address_prefixes = ["12.12.0.64/26"]
  virtual_network_name = azurerm_virtual_network.custom_vnet.name
}


# --- Network security group ---

resource "azurerm_network_security_group" "custom_nsg" {
  name                = "sudip-10oct-nsg"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_rule" "rule8080" {
  name                        = "myRule1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.custom_nsg.name
}

resource "azurerm_network_security_rule" "ruleSSH" {
  name                        = "myRule2"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "65.2.88.212/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.custom_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id = azurerm_subnet.subnet_public_1.id
  network_security_group_id = azurerm_network_security_group.custom_nsg.id
  depends_on = [
    azurerm_network_security_group.custom_nsg
  ]
}

