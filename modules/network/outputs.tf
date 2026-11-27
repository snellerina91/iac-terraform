# =============================================================================
#  modules/network/outputs.tf  –  KONTRAKTEN UT
# -----------------------------------------------------------------------------
#  Uendret fra øving 8. NSG-en er ny i v1.2.0, men ingen konsument har bedt om
#  ID-en til den, så den har ingen output. Å legge til en senere brekker
#  ingen.
# =============================================================================

output "subnet_id" {
  description = "ID til subnettet."
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "Navnet på subnettet."
  value       = azurerm_subnet.this.name
}

output "vnet_id" {
  description = "ID til det virtuelle nettverket."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Navnet på det virtuelle nettverket."
  value       = azurerm_virtual_network.this.name
}

output "data_subnet_id" {
  description = "ID til data-subnettet."
  value       = azurerm_subnet.data.id
}
