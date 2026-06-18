terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "tfstate20946725"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

variable "env_name" {
  type = string
}

variable "storage_accounts" {
  type = map(object({
    location = string
    tier     = string
  }))
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.env_name}"
  location = "eastus"
}

resource "azurerm_storage_account" "loop_storage" {
  for_each                 = var.storage_accounts
  name                     = "${each.key}${var.env_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = each.value.location
  account_tier             = each.value.tier
  account_replication_type = "LRS"
}
