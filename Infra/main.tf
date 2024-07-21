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
  sku_name            = "P1v3"
}

resource "azurerm_linux_function_app" "func_app" {
  name                = "ghb-container-function"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.strg.name
  storage_account_access_key = azurerm_storage_account.strg.primary_access_key
  service_plan_id            = azurerm_service_plan.svc_plan.id
  lifecycle {
    ignore_changes = [app_settings , site_config ]
  }
  site_config {}
}

resource "azurerm_container_registry" "acr" {
  name                = "acrgithubactions"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "ghb-actions-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "ghb-actions-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks_role" {
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.acr.id
}
