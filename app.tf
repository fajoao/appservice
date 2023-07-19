terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.58.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "apisfabio-rg"
  location = "East US 2"
}

variable "app_names" {
  description = "Nomes dos App Services"
  type        = list(string)
  default     = ["apimla", "apimlb", "apimlc", "apimlm"]
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  for_each            = toset(var.app_names)
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://apifabio.azurecr.io"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = "apifabio"
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = "ku054FMkMwzmlaLzx6Mro+/rZtLy2fmTI57RQLlGMQ+ACRBgLZtB"
    "WEBSITES_PORT"                       = "3000"
  }

  site_config {
    always_on        = true
    linux_fx_version = "DOCKER|apifabio.azurecr.io/apiimage:1.0.0"
    
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html"
    ]
  }
}