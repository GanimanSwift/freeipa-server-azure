#
# Network
#

resource "azurerm_virtual_network" "freeipa_vnet" {
  name                = "vnet-freeipa-${var.environment}-${var.location}-01"
  address_space       = ["${phpipam_first_free_subnet.freeipa_subnet.subnet_address}/${phpipam_first_free_subnet.freeipa_subnet.subnet_mask}"]
  location            = azurerm_resource_group.freeipa_rg.location
  resource_group_name = azurerm_resource_group.freeipa_rg.name 
  tags = {
    Environment = var.environment
    Location  = var.location
  }
  depends_on = [azurerm_resource_group.freeipa_rg]
}

resource "azurerm_subnet" "freeipa_subnet" {
  name                 = "subnet-freeipa-${var.environment}-${var.location}-01"
  resource_group_name  = azurerm_resource_group.freeipa_rg.name
  virtual_network_name = azurerm_virtual_network.freeipa_vnet.name
  address_prefixes     = ["${phpipam_first_free_subnet.freeipa_subnet.subnet_address}/${phpipam_first_free_subnet.freeipa_subnet.subnet_mask}"]
  enforce_private_link_endpoint_network_policies = true
  depends_on = [azurerm_virtual_network.freeipa_vnet, phpipam_first_free_subnet.freeipa_subnet]
}

resource "azurerm_network_security_group" "freeipa_nsg" {
  name                = "nsg-freeipa-${var.environment}-${var.location}"
  location            = azurerm_resource_group.freeipa_rg.location
  resource_group_name = azurerm_resource_group.freeipa_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Location  = var.location
  }
}

resource "azurerm_subnet_network_security_group_association" "freeipa_nsg_assoc" {
  subnet_id                 = azurerm_subnet.freeipa_subnet.id
  network_security_group_id = azurerm_network_security_group.freeipa_nsg.id
  depends_on = [azurerm_subnet.freeipa_subnet, azurerm_network_security_group.freeipa_nsg]
}

resource "azurerm_virtual_network_peering" "freeipa_transit_peer" {
  name                      = "peer-freeipa-transit-${var.environment}"
  resource_group_name       = azurerm_resource_group.freeipa_rg.name
  virtual_network_name      = azurerm_virtual_network.freeipa_vnet.name
  remote_virtual_network_id = "/subscriptions/${var.transit_sub_id}/resourceGroups/${var.transit_rg_name}/providers/Microsoft.Network/virtualNetworks/${var.transit_vnet_name}"
}

resource "azurerm_virtual_network_peering" "transit_freeipa_peer" {
  name                      = "peer-transit-freeipa-${var.environment}"
  resource_group_name       = var.transit_rg_name
  virtual_network_name      = var.transit_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.demo_vnet.id
}
