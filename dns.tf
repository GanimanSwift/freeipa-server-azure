resource "azurerm_private_dns_a_record" "freeipa_private" {
  name                = var.freeipa_hostname
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_rg_name
  ttl                 = 300
  records             = [phpipam_first_free_address.freeipa_ip.ip_address]
}
