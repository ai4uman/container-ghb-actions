resource "azurerm_resource_group" "rg" {
  name     = "container-githubactions-rg"
  location = var.resource_group_location
}

resource "azurerm_storage_account" "strg" {
  name                     = "containerfunctionghbsa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "svc_plan" {
  name                = "container-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "func_app" {
  name                = "ghb-container-function"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.strg.name
  storage_account_access_key = azurerm_storage_account.strg.primary_access_key
  service_plan_id            = azurerm_service_plan.svc_plan.id

  site_config {}
}

resource "azurerm_container_registry" "acr" {
  name                = "acrgithubactions"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}