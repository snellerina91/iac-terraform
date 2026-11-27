# =============================================================================
#  modules/network/main.tf  –  PRODUKTET, NÅ MED NSG
# -----------------------------------------------------------------------------
#  network-v1.1.0 fra øving 8, med to nye ressurser nederst:
#
#    azurerm_network_security_group.this                     (F15)
#    azurerm_subnet_network_security_group_association.this  (F15)
#
#  De tre første blokkene er urørt. Har fmt i A2 flyttet på noen mellomrom,
#  er det den eneste endringen i dem.
#
#  Fila slik den står her, er network-v1.2.0: den første versjonen av modulen
#  som er testet FØR den ble tagget.
# =============================================================================

resource "azurerm_virtual_network" "this" {
  name          = "${var.name_prefix}-vnet"
  address_space = var.address_space

  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Etiketten "this" er den testene i tests/ leser. Bytter du den, må testene
# følge med – det er nøyaktig det modul 10 handler om.
resource "azurerm_subnet" "this" {
  name                 = "${var.name_prefix}-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.subnet_address_prefix
}

# Fra network-v1.1.0. Testen subnettene_har_riktig_cidr sjekker også denne.
resource "azurerm_subnet" "data" {
  name                 = "${var.name_prefix}-data-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.data_subnet_address_prefix
}

# -----------------------------------------------------------------------------
#  NYTT I network-v1.2.0: en NSG på subnettet
# -----------------------------------------------------------------------------
#  Den samme NSG-en som i modul 3, med én forskjell: kilden for SSH er en
#  variabel. I F15 sto det "*" her – hele internett.
#
#  fmt, validate og TFLint slapp det gjennom. Det er gyldig, velformatert
#  Terraform, og ingen av de tre vet hva en åpen port betyr. Checkov stoppet
#  det med CKV_AZURE_10, og testen ssh_er_ikke_aapent_for_internett ble rød.
#  To uavhengige sjekker, samme feil.
resource "azurerm_network_security_group" "this" {
  name                = "${var.name_prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                   = "ssh"
    priority               = 100
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "22"

    # Rettelsen fra F18. Standardverdien er "VirtualNetwork" – en service
    # tag som betyr «bare trafikk fra eget VNet». Det er denne linja H23
    # setter tilbake til "*". Da er det TFLint som stopper først: ingenting
    # bruker var.ssh_source_prefix lenger.
    source_address_prefix      = var.ssh_source_prefix
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Bare app-subnettet ("this") får NSG-en, slik den guidede øvelsen viser.
# Data-subnettet står uten – se «frie valg» i gjennomgangen.
#
# Koblingen er en egen ressurs, ikke et argument på subnettet. Det får
# betydning i modul 10: den peker på subnettets ID, så blir subnettet slettet
# og opprettet på nytt, må koblingen også erstattes.
resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
