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

# resource "azapi_resource_action" "ssh_public_key_gen" {
#   type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   resource_id = azapi_resource.ssh_public_key.id
#   action      = "generateKeyPair"
#   method      = "POST"

#   response_export_values = ["publicKey", "privateKey"]
# }

# resource "azapi_resource" "ssh_public_key" {
#   type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   name      = "sudip-10oct-sshkey"
#   location  = azurerm_resource_group.resource_group.location
#   parent_id = azurerm_resource_group.resource_group.id
# }

output "key_data" {
  value = azurerm_ssh_public_key.ssh_key.public_key
}


# --- SSH key ---

resource "azurerm_ssh_public_key" "ssh_key" {
  name                = "sudip-10oct-sshkey2"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  public_key          = file("~/.ssh/id_rsa.pub")
}


# # --- Virtual machine & others

# resource   "azurerm_public_ip" "custom_publicip"   {
#   name   =   "sudip-10oct-publicip"
#   location   =   azurerm_resource_group.resource_group.location
#   resource_group_name   =   azurerm_resource_group.resource_group.name
#   allocation_method   =   "Dynamic"
#   sku   =   "Basic"
# }

# resource "azurerm_network_interface" "nic" {
#   name                = "sudip-10oct-nic"
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name

#   ip_configuration {
#     name                          = "sudip-10oct-ipconfig"
#     subnet_id                     = azurerm_subnet.subnet_public_1.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id   =   azurerm_public_ip.custom_publicip.id
#   }
# }

# resource "azurerm_linux_virtual_machine" "custom_vm" {
#   name                = "sudip-10oct-vm"
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.nic.id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = azurerm_ssh_public_key.ssh_key.public_key #file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }
# }


# --- Azure MySQL flexible server

# resource "azurerm_mysql_flexible_server" "mysql_server" {
#   name                   = "sudip-10oct-mysql-server22"
#   resource_group_name    = azurerm_resource_group.resource_group.name
#   location               = azurerm_resource_group.resource_group.location
#   administrator_login    = "sudipadmin"
#   administrator_password = "pass@123"
#   backup_retention_days  = 7
#   # delegated_subnet_id    = azurerm_subnet.example.id
#   # private_dns_zone_id    = azurerm_private_dns_zone.example.id
#   sku_name               = "GP_Standard_D2ds_v4"
#   public_network_access_enabled     = true

#   # depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
# }



# # resource "azurerm_mysql_server" "mysql_server" {
# #   name                = "sudip-10oct-mysql-server"
# #   resource_group_name = azurerm_resource_group.resource_group.name
# #   location            = azurerm_resource_group.resource_group.location

# #   administrator_login          = "sudipadmin"
# #   administrator_login_password = "pass@123"

# #   #sku_name   = "B_Gen5_2" # Basic Tier - Azure Virtual Network Rules not supported
# #   sku_name   = "B_Gen5_2" # General Purpose Tier - Supports Azure Virtual Network Rules
# #   storage_mb = 5120
# #   version    = "8.0"

# #   # auto_grow_enabled                 = true
# #   backup_retention_days             = 7
# #   geo_redundant_backup_enabled      = false
# #   # infrastructure_encryption_enabled = false
# #   public_network_access_enabled     = true
# #   ssl_enforcement_enabled           = false
# #   ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled" 

# # }



# # Resource-2: Azure MySQL Database / Schema
# resource "azurerm_mysql_flexible_database" "webappdb" {
#   name                = "sudip-10oct-dbserver"
#   resource_group_name = azurerm_resource_group.resource_group.name
#   server_name         = azurerm_mysql_flexible_server.mysql_server.name
#   charset             = "utf8"
#   collation           = "utf8_unicode_ci"
# }

# # Resource-3: Azure MySQL Firewall Rule - Allow access from Bastion Host Public IP
# resource "azurerm_mysql_firewall_rule" "mysql_fw_rule" {
#   name                = "sudip-10oct-mysql-firewall"
#   resource_group_name = azurerm_resource_group.resource_group.name
#   server_name         = azurerm_mysql_flexible_server.mysql_server.name
#   start_ip_address    = azurerm_linux_virtual_machine.custom_vm.public_ip_address
#   end_ip_address      = azurerm_linux_virtual_machine.custom_vm.public_ip_address
# }


# # --- Blob storage ---

# resource "azurerm_storage_account" "custom_storage_account" {
#   name                     = "sudipstorageaccount"
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = {
#     environment = "staging"
#   }
# }

# resource azurerm_storage_container "custom_blob" {
#   name                  = "sudip-10oct-blob"
#   storage_account_name  = azurerm_storage_account.custom_storage_account.name
#   container_access_type = "private"
# }
