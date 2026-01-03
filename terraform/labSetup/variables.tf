#variables.tf
variable "rg_dev_env_basename_set" {
  description = "Base name prefix for resource groups used for development environments (e.g., rg-lab2)"
  type        = set(string)
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "rg_resourceGroups_map" {
  description = "Ressource group set used in the subscription"
  type        = map(object({}))
}

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "default_azsubscription" {
  description = "Default Azure subscription ID"
  type        = string
}

variable "deployment_environement_set" {
  description = "Environment suffixes to create resource groups for"
  type        = set(string)
  default     = ["prod", "staging", "dev"]
}

variable "alert_email_set" {
  description = "Email address for alert notifications"
  type        = set(string)
}

# Map of Azure AD groups to create
variable "az_ad_group_map" {
  description = "Map of Azure AD group display names to their properties. Example: { group1 = { security_enabled = true, mail_enabled = false } }"
  type = map(object({
    name             = string
    description      = string
    security_enabled = bool
    mail_enabled     = bool
    member_of        = optional(list(string))
  }))
}

# Map of Azure AD users to create
variable "az_ad_user_map" {
  description = "Map of Azure AD user principal names to their properties. Example: { user1 = { display_name = \"User One\", mail_nickname = \"userone\", password = \"P@ssw0rd!\" } }"
  type = map(object({
    display_name  = string
    mail_nickname = string
    rb_group      = string
  }))
}
