# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = " > 3.0"
    }
  }

  #  backend "azurerm" {
  #    use_azuread_auth = true
  #  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.default_azsubscription
}

locals {
  rg_devel_name_map = {
    for rgcrossenv in setproduct(var.rg_dev_env_basename_set, var.deployment_environement_set) :
    "${rgcrossenv[0]}-${rgcrossenv[1]}" => {
      tags = {
        "BU"                 = "SoftwareCICD"
        "TypeOfEnvironement" = rgcrossenv[1] == "prod" ? "Production" : rgcrossenv[1] == "staging" ? "Staging" : "Development"
      }
    }
  }

  L_groups_membership_flat_list = flatten([
    for group_key, group in var.az_ad_l_group_map : [
      for parent_group in lookup(group, "member_of") : {
        key          = "${group_key}-${parent_group}"
        member_group = group_key
        parent_group = parent_group
      }
    ]
  ])
  L_groups_membership_assignments = {
    for item in local.L_groups_membership_flat_list : item.key => item
  }
}

## Create resource groups for development environments
resource "azurerm_resource_group" "dev_rgs" {
  for_each = local.rg_devel_name_map

  name     = each.key
  location = var.location
  tags     = each.value.tags
}

## Create additional resource groups specified in tfvars
resource "azurerm_resource_group" "mgm_rgs" {
  for_each = var.rg_resourceGroups_map

  name     = each.key
  location = each.value.location
  tags     = each.value.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-resourceMonitoring"
  location            = var.location
  resource_group_name = "rg-SharedResources"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azuread_group" "this" {
  for_each = merge(var.az_ad_rb_group_map, var.az_ad_l_group_map)

  display_name     = each.value.name
  security_enabled = each.value.security_enabled
  description      = each.value.description
  mail_nickname    = "${each.value.name}-mailnick"
}

## Assign L-groups as members of RB groups
resource "azuread_group_member" "L_group_assignments" {
  for_each = local.L_groups_membership_assignments

  group_object_id  = azuread_group.this[each.value.parent_group].object_id
  member_object_id = azuread_group.this[each.value.member_group].object_id
  depends_on       = [azuread_group.this]
}

## Create Key Vault to store user passwords
resource "azurerm_key_vault" "user_password_kv" {
  name                       = "kv-azou8506-Secrets"
  location                   = var.location
  resource_group_name        = "rg-SharedResources"
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
  depends_on                 = [azuread_group.this]
}
data "azurerm_monitor_diagnostic_categories" "kv_diagnostics_categories" {
  resource_id = azurerm_key_vault.user_password_kv.id
}
## Enable Key Vault Logging to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "kv_diagnostics" {
  name                           = "diag-kv-logs"
  target_resource_id             = azurerm_key_vault.user_password_kv.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.kv_diagnostics_categories.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

## Fetch existing passwords from Key Vault
data "azurerm_key_vault_secret" "user_passwords" {
  for_each     = var.az_ad_user_map
  name         = "userpwd-${each.key}"
  key_vault_id = azurerm_key_vault.user_password_kv.id
}

## Create Azure AD users
resource "azuread_user" "this" {
  for_each              = var.az_ad_user_map
  user_principal_name   = "${each.key}@azou8506gmail.onmicrosoft.com"
  display_name          = each.value.display_name
  mail_nickname         = each.key
  force_password_change = false
  password              = data.azurerm_key_vault_secret.user_passwords[each.key].value
  depends_on            = [azuread_group.this]
  lifecycle {
    ignore_changes = [password]
  }
}

## Assign users to their respective RB groups
resource "azuread_group_member" "user_rb_assignments" {
  for_each = var.az_ad_user_map

  group_object_id  = azuread_group.this[each.value.rb_group].object_id
  member_object_id = azuread_user.this[each.key].object_id
  depends_on       = [azuread_user.this]
}
