#
# Variable definitions and some default values
#

# Azure Resource Group Settings

variable "location" {
  default = "eastus"
}
variable "environment" {
  default = "prod"
}

# Azure VM Settings

variable "vm_size" {
  default = "Standard_F4s"
}
variable "vm_publisher" {
  default = "procomputers"
}
variable "vm_offer" {
  default = "rocky-lnx-9-minimal"
}
variable "vm_sku" {
  default = "rocky-linux-9-minimal"
}
variable "vm_version" {
  default = "latest"
}
variable "ssh_public_key" {
  type        = string
}

# Azure VM Plan Settings
variable "plan_name" { 
  default = "rocky-linux-9-minimal"
}
variable "plan_product" {
  default = "rocky-lnx-9-minimal"
}
variable "plan_publisher" { 
  default = "procomputers"
}

# PHPIPAM settings

variable "ipam_username" {
  description = "PHP IPAM username"
  type        = string
  sensitive   = true
}
variable "ipam_password" {
  description = "PHP IPAM password"
  type        = string
  sensitive   = true
}
variable "ipam_app_id" {
  description = "PHP IPAM app id"
  type        = string
}
variable "ipam_endpoint" {
  description = "PHP endpoint URL"
  type        = string
}
variable "ipam_section" {
  description = "PHP IPAM section"
  type        = string
}
variable "ipam_parent" {
  description = "PHP IPAM parent subnet"
  type        = string
}

# FreeIPA Settings
variable "freeipa_username" {
  description = "FreeIPA administrator username"
  type        = string
  sensitive   = true
}
variable "freeipa_password" {
  description = "FreeIPA administrator password"
  type        = string
  sensitive   = true
}
variable "freeipa_hostname" {
  description = "FreeIPA hostname"
  type        = string
}

# Azure Peering Settings
variable "transit_rg_name" {
  type        = string
}
variable "transit_vnet_name" {
  type        = string
}
variable "transit_sub_id" {
  type        = string
}

# Azure DNS Settings
variable "dns_zone_name" {
  type        = string
}
variable "dns_rg_name" {
  type        = string
}