# =============================================================================
#  modules/network/tests/network.tftest.hcl  –  KONTRAKTEN, TESTET
# -----------------------------------------------------------------------------
#  Fire run-blokker, fire løfter modulen gir:
#
#    subnettene_har_riktig_cidr        adressene er de som står i defaultene
#    navnene_bruker_prefikset          navnene bygges av name_prefix
#    ugyldig_name_prefix_avvises       dårlig input stoppes før Azure ser den
#    ssh_er_ikke_aapent_for_internett  sikkerhetskravet fra Del F
#
#  Kjøres fra modules/network/ med terraform test, etter
#  terraform init -backend=false. Alle er command = plan mot en mock: ingen
#  pålogging, ingen ressurser, ingen kostnad.
#
#  Den guidede øvelsen bruker project. Denne modulen tar name_prefix, så både
#  variabelen og den tredje testen heter det i stedet.
# =============================================================================

# Den simulerte provideren. Uten denne linja bruker terraform test den ekte
# azurerm-provideren – og den vil logge inn i Azure, også for en plan.
mock_provider "azurerm" {}

# Felles input for alle run-blokkene. Bare de påkrevde variablene: resten har
# default, og det er nettopp defaultene testene skal bekrefte.
variables {
  name_prefix         = "tim84-iac-dev"
  location            = "norwayeast"
  resource_group_name = "tim84-iac-dev-rg"
}

run "subnettene_har_riktig_cidr" {
  command = plan

  assert {
    condition     = azurerm_subnet.this.address_prefixes[0] == "10.0.1.0/24"
    error_message = "Subnettet skal ha CIDR 10.0.1.0/24."
  }

  # Det er denne som ble rød da data-subnettet fikk 10.0.3.0/24 i D12. En test
  # som aldri har vært rød, er ikke bevist.
  assert {
    condition     = azurerm_subnet.data.address_prefixes[0] == "10.0.2.0/24"
    error_message = "Data-subnettet skal ha CIDR 10.0.2.0/24."
  }
}

run "navnene_bruker_prefikset" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.this.name == "tim84-iac-dev-vnet"
    error_message = "VNet-navnet skal være <name_prefix>-vnet."
  }

  assert {
    condition     = azurerm_network_security_group.this.name == "tim84-iac-dev-nsg"
    error_message = "NSG-navnet skal være <name_prefix>-nsg."
  }
}

run "ugyldig_name_prefix_avvises" {
  command = plan

  variables {
    name_prefix = "Tim84 IAC" # store bokstaver og mellomrom
  }

  # Snur testen: den består når valideringen på name_prefix slår til – og
  # FEILER hvis modulen tar imot verdien.
  expect_failures = [var.name_prefix]
}

# Fra F16. Skrevet for akkurat denne modulen, og uavhengig av Checkov. To
# sjekker som stopper den samme feilen hver for seg.
run "ssh_er_ikke_aapent_for_internett" {
  command = plan

  assert {
    condition = alltrue([
      for r in azurerm_network_security_group.this.security_rule :
      r.source_address_prefix != "*" if r.destination_port_range == "22"
    ])
    error_message = "SSH (port 22) skal ikke være åpent fra hele internett."
  }
}
