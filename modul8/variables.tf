variable "kortnavn" {
  description = "Ditt unike kortnavn. Brukes som prefiks i ALLE ressursnavn."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,8}$", var.kortnavn))
    error_message = "kortnavn må være 3–8 tegn, kun små bokstaver og tall."
  }
}

variable "project" {
  description = "Prosjektnavn med miljø: \"iac-dev\" i dev.tfvars, \"iac-prod\" i prod.tfvars."
  type        = string
}

variable "location" {
  description = "Azure-region. Bruk samme region som backenden."
  type        = string
  default     = "norwayeast"

  validation {
    condition     = contains(["norwayeast", "westeurope", "northeurope", "uksouth"], var.location)
    error_message = "Regionen må være én av: norwayeast, westeurope, northeurope, uksouth (Azure Policy i fagets tenant)."
  }
}
