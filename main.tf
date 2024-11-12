terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  default = "my-resource-group"
}
variable "location" {
  default = "eastus"
}
variable "acr_name" {
  default = "myacrregistry"
}
variable "storage_account_name" {
  default = "contractpharmacystorage"
}
variable "function_app_name" {
  default = "my-python-function-app"
}
variable "container_name" {
  default = "contract-pharmacy-reports"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Blob Container
resource "azurerm_storage_container" "blob_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Azure Function App Plan
resource "azurerm_app_service_plan" "function_plan" {
  name                = "${var.function_app_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

# Azure Function App
resource "azurerm_function_app" "function_app" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  identity {
    type = "SystemAssigned"
  }
  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/my-python-app:latest"
  }
}

# Grant ACR Pull Role to Function App
resource "azurerm_role_assignment" "acr_pull" {
  principal_id   = azurerm_function_app.function_app.identity.principal_id
  role_definition_name = "AcrPull"
  scope          = azurerm_container_registry.acr.id
}

# Grant Storage Blob Data Contributor Role to Function App
resource "azurerm_role_assignment" "blob_contributor" {
  principal_id   = azurerm_function_app.function_app.identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope          = azurerm_storage_account.storage.id
}

# Application Settings for Function App
resource "azurerm_function_app_configuration" "app_settings" {
  function_app_id = azurerm_function_app.function_app.id
  settings = {
    "AZURE_STORAGE_ACCOUNT_NAME" = var.storage_account_name
    "AZURE_STORAGE_CONTAINER_NAME" = var.container_name
  }
}
