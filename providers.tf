terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # backend "azurerm" {
  # resource_group_name = "rg-terraform-state-prod"
  # storage_account_name = "sttfstateperimeter101"
  # container_name = "tfstate"
  # key = "sandbox.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}