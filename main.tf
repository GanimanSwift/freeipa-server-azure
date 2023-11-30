#
# Configure providers and create a resource group
#

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    phpipam = {
      source = "lord-kyron/phpipam"
      version = "1.5.2"
    }
  }
#  backend "azurerm" {
#    resource_group_name  = ""
#    storage_account_name = ""
#    container_name       = ""
#    key                  = ""
#  }
  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}
  subscription_id = "${var.azure_sub_id}"
}

resource "azurerm_resource_group" "freeipa_rg" {
  name     = "freeipa-${var.environment}-${var.location}-01"
  location = var.location
  tags = {
    Environment = var.environment
  }
}
