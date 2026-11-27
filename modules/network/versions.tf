# =============================================================================
#  modules/network/versions.tf  –  HVA MODULEN ER SKREVET FOR
# -----------------------------------------------------------------------------
#  Ny fil (B6). Modulen hadde aldri sagt hvilken Terraform- eller
#  providerversjon den tåler. Så lenge den bodde inne i en rotmodul, var det
#  rotmodulens sak. Nå er den et produkt med egne tagger, og da må den si det
#  selv – ellers oppdager konsumenten en inkompatibilitet først i sin egen
#  plan.
#
#  validate godtok modulen uten denne fila. TFLint gjorde det ikke.
#
#  Ingen backend-blokk og ingen provider-blokk: en child-modul får provideren
#  fra den som kaller den.
# =============================================================================

terraform {
  # 1.7 er den laveste versjonen som kjenner mock_provider i testene. Et
  # høyere krav enn nødvendig stenger bare ute konsumenter uten grunn.
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"

      # Samme hovedversjon som modul8/. Et SPENN, ikke én versjon: det er
      # rotmodulens låsefil som velger den konkrete versjonen.
      version = "~> 5.4"
    }
  }
}
