terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.26.0"
    }
  }
  required_version = "1.13.4"

  backend "azurerm" {}
}