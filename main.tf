// Tags
locals {
  tags = {
    class      = var.tag_class
    instructor = var.tag_instructor
    semester   = var.tag_semester
  }
}

// Existing Resources

/// Subscription ID

# data "azurerm_subscription" "current" {
# }

// Random Suffix Generator

resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location = var.location

  tags = local.tags
}


// Storage Account

resource "azurerm_storage_account" "storage" {
  name                     = "sto${var.class_name}${var.student_name}${var.environment}${random_integer.deployment_id_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

# ---------------------------------------------------
# VIRTUAL NETWORK + SUBNET
# ---------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dsba6190-cford38-dev-eastus-001"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-dsba6190-cford38-dev-eastus-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ---------------------------------------------------
# SQL SERVER
# ---------------------------------------------------
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-dsba6190-cford38-dev-001"
  resource_group_name          = "rg-dsba6190-beta-eastus-001"
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "StrongP@ssw0rd123"
}

# ---------------------------------------------------
# SQL DATABASE
# ---------------------------------------------------
resource "azurerm_mssql_database" "db" {
  name        = "db-dsba6190-cford38-dev-001"
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = "S0"
  max_size_gb = 5
}