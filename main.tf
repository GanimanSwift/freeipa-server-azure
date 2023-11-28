#
# Configure providers and create a resource group
#

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  phpipam = {
    source = "lord-kyron/phpipam"
    version = "1.2.8"
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "freeipa_rg" {
  name     = "freeipa-${var.environment}-${var.location}-01"
  location = var.azureregion
  tags = {
    Environment = var.environment
  }
}
