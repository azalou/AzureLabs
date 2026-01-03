# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    use_azuread_auth = true
  }
}

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

  L_groups_membership_assignments = merge([
    for group_key, group in var.az_ad_group_map : [
      for parent_group in lookup(group, "member_of", []) : {
        key = "${group_key}-${parent_group}"
        value = {
          member_group = group_key
          parent_group = parent_group
        }
      }
    ]
  ]...)

}
## Create resource groups for development environments
resource "azurerm_resource_group" "rg" {
  for_each = local.rg_devel_name_map

  name     = each.key
  location = var.location
  tags     = each.value.tags
}

## Create additional resource groups specified in tfvars
resource "azurerm_resource_group" "additional_rgs" {
  for_each = var.rg_resourceGroups_map

  name     = each.value
  location = var.location
  tags     = each.value.tags
}

resource "azurerm_ad_group" "this" {
  for_each = var.az_ad_group_map

  name             = each.value.name
  security_enabled = each.value.security_enabled
  description      = each.value.description
  mail_nickname    = "${each.value.name}-mailnick"
}

## Assign L-groups as members of RB groups
resource "azuread_group_member" "L_group_assignments" {
  for_each = { for k, v in local.L_groups_membership_assignments : k => v.value }

  group_object_id  = azurerm_ad_group.this[each.value.parent_group].id
  member_object_id = azurerm_ad_group.this[each.value.member_group].id
}

## Create Key Vault to store user passwords
resource "azurerm_key_vault" "user_password_kv" {
  name                       = "kv-Secrets"
  location                   = var.location
  resource_group_name        = "rg-SharedResources"
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

## Generate random passwords for Azure AD users
resource "random_password" "user_passwords" {
  for_each = var.az_ad_user_map
  length   = 16
  special  = true
}
## Store generated passwords in Key Vault
resource "azurerm_key_vault_secret" "user_password_secrets" {
  for_each     = random_password.user_passwords
  name         = "userpwd-${each.key}"
  value        = each.value.result
  key_vault_id = azurerm_key_vault.user_password_kv.id
  content_type = "AzureADUserPassword"
  depends_on   = [azurerm_key_vault.user_password_kv]
}

## Create Azure AD users
resource "azuread_user" "this" {
  for_each              = var.az_ad_user_map
  user_principal_name   = "${each.key}@azou8506gmail.onmicrosoft.com"
  display_name          = each.value.display_name
  mail_nickname         = each.key
  force_password_change = false
  password              = random_password.user_passwords[each.key].result
  lifecycle {
    ignore_changes = [password]
  }
}

## Assign users to their respective RB groups
resource "azurerm_group_member" "user_rb_assignments" {
  for_each = var.az_ad_user_map

  group_object_id  = azurerm_ad_group.this[each.value.rb_group].id
  member_object_id = azuread_user.this[each.key].id

}
