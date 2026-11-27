# =============================================================================
#  modules/network/variables.tf  –  KONTRAKTEN INN
# -----------------------------------------------------------------------------
#  To endringer fra øving 8:
#
#    name_prefix        har fått en validation-blokk  (D10)
#    ssh_source_prefix  er ny, med en trygg default   (F18)
#
#  Den guidede øvelsen legger valideringen på "project". Denne modulen har
#  aldri hatt project – den har tatt name_prefix siden øving 4. Regelen er den
#  samme; bare navnet er et annet.
# =============================================================================

variable "name_prefix" {
  description = "Prefiks alle ressursnavn i modulen bygges fra, f.eks. \"tim84-iac-dev\"."
  type        = string

  # NY I øving 9. Uten validering har testen ugyldig_name_prefix_avvises
  # ingenting å teste: modulen tok imot hva som helst og lot Azure si nei –
  # midt i en apply, etter at halve nettverket var opprettet.
  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.name_prefix))
    error_message = "name_prefix kan bare inneholde små bokstaver, tall og bindestrek (3–20 tegn)."
  }
}

variable "location" {
  description = "Azure-region ressursene opprettes i. Settes av den som kaller modulen."
  type        = string
}

variable "resource_group_name" {
  description = "Navnet på en EKSISTERENDE ressursgruppe. Modulen oppretter den ikke selv."
  type        = string
}

variable "address_space" {
  description = "Adresserommet til det virtuelle nettverket (CIDR)."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Adresseområdet til subnettet. Må ligge innenfor address_space."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "data_subnet_address_prefix" {
  description = "Adresseområdet til data-subnettet. Må ligge innenfor address_space og ikke overlappe subnettet over."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# NY I network-v1.2.0.
#
# Defaulten er den trygge verdien. En konsument som ikke sier noe, får SSH
# bare fra eget VNet – og ingen konsument MÅ sende den inn. Det er samme grep
# som data_subnet_address_prefix i v1.1.0.
variable "ssh_source_prefix" {
  description = "Hvor SSH (port 22) er tillatt fra. Aldri \"*\"."
  type        = string
  default     = "VirtualNetwork" # Azure service tag: bare trafikk fra eget VNet
}

variable "tags" {
  description = "Tagger som settes på ressursene modulen oppretter."
  type        = map(string)
  default     = {}
}
