data "azurerm_firewall_policy" "policy" {
  name = var.transit_fw_policy_name
  resource_group_name = var.transit_rg_name 
}

resource "azurerm_firewall_policy_rule_collection_group" "freeipa_policy" {
  name                = "pol-freeipa-${var.environment}-${var.location}-01"
  firewall_policy_id  = data.azurerm_firewall_policy.policy.id
  priority            = 100

  network_rule_collection {
    name     = "nrc-freeipa-${var.environment}-${var.location}-01"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "to-freeipa-${var.environment}-${var.location}-01"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.0.0/8", "172.16.0.0/12"]
      destination_addresses = ["${phpipam_first_free_subnet.freeipa_subnet.subnet_address}/${phpipam_first_free_subnet.freeipa_subnet.subnet_mask}"]
      destination_ports     = ["80","88","123","389","443","464","636"]
    }
  }
}
