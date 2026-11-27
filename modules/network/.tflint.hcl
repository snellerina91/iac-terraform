# =============================================================================
#  modules/network/.tflint.hcl  –  REGLENE TFLINT BRUKER
# -----------------------------------------------------------------------------
#  Ligger i mappa tflint kjøres fra, og er sjekket inn. Det er denne fila som
#  gjør at du, en medstudent og test-network-jobben bruker nøyaktig de samme
#  reglene. Ingen regler står i workflow-fila.
# =============================================================================

config {
  # Én linje per funn: fil:linje:kolonne: grad - melding (regel).
  format = "compact"
}

# Innebygd. "recommended" slår på de viktigste reglene for Terraform-språket –
# blant dem de to som fant hullene i B5 (required_version og
# required_providers), og den som fant variabelen "ubrukt" i B7.
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Lastes ned av tflint --init. PINNET: en ny versjon av regelsettet kan komme
# med nye regler, og da kan den samme koden bli rød i morgen uten at én linje
# er endret. Versjonen flyttes med vilje, i en egen commit.
plugin "azurerm" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Ikke med i presettet, slått på her: etiketter i snake_case. "this" og
# "data" består; "dataSubnet" ville ikke gjort det.
rule "terraform_naming_convention" {
  enabled = true
}
