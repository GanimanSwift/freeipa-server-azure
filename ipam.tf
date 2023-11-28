#
# https://registry.terraform.io/providers/lord-kyron/phpipam/latest/docs
#

provider "phpipam" {
  app_id   = var.ipam_app_id
  endpoint = var.ipam_endpoint
  password = var.ipam_password
  username = var.ipam_username
  insecure = false
}

data "phpipam_section" "section" {
  name = var.ipam_section
}

# Look up the parent subnet
data "phpipam_subnet" "subnet" {
  description = var.ipam_parent
  section_id = data.phpipam_section.section.id
}

# Create child subnet
resource "phpipam_first_free_subnet" "freeipa_subnet" {
  parent_subnet_id = data.phpipam_subnet.subnet.subnet_id
  subnet_mask      = 27
  description      = "subnet-freeipa-${var.environment}-${var.location}"
}

# Reserve first 3 address for Azure gateway and dns
resource "phpipam_first_free_address" "azure_reserved" {
  count       = 3
  subnet_id   = phpipam_first_free_subnet.freeipa_subnet.subnet_id
  description = "Reserved by Azure VNET - Managed by Terraform"
}

# Reserve an address.
resource "phpipam_first_free_address" "freeipa_ip"{
  subnet_id   = phpipam_first_free_subnet.freeipa_subnet.subnet_id
  hostname    = var.freeipa_hostname
  description = "Managed by Terraform"
}
