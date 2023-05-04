terraform {
  required_version = "> 0.14"
  required_providers {
    azurerm = {
      version = ">= 3.54.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}