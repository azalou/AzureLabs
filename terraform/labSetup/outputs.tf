# outputs.tf

output "resource_groups" {
  description = "Resource groups created, keyed by environment suffix"
  value = { for env, rg in azurerm_resource_group.rg : env => {
    id       = rg.id
    name     = rg.name
    location = rg.location
  } }
}

output "action_group_id" {
  description = "The ID of the shared VM monitoring action group"
  value       = azurerm_monitor_action_group.vm_alerts.id
}

output "action_group_name" {
  description = "The name of the shared VM monitoring action group"
  value       = azurerm_monitor_action_group.vm_alerts.name
}
