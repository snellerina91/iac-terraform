# =============================================================================
#  modul8/main.tf  –  STACKEN SOM BRUKER NETTVERKSMODULEN
# -----------------------------------------------------------------------------
#  Startpakken fra hurtigspor 3. Samme stack som i modul 7 og 8: en
#  ressursgruppe og nettverksmodulen, med navn bygget av kortnavn og project.
#
#  Modulen hentes fra GitHub på en TAG, ikke fra disken. Endringer i
#  ../modules/network/ får ingen virkning her før du lager en ny tag og
#  flytter ?ref.
# =============================================================================

terraform {
  required_version = ">= 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.4"
    }
  }

  # Tom med vilje. Verdiene kommer fra backend.hcl, og key settes per miljø:
  #   terraform init -backend-config=backend.hcl -backend-config="key=modul8/dev/network.tfstate"
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

locals {
  name_prefix = "${var.kortnavn}-${var.project}"

  common_tags = {
    owner      = var.kortnavn
    course     = "iac"
    module     = "modul8"
    managed_by = "pipeline"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  #   git::https://github.com/<org>/<repo>.git   repoet som klones
  #   //modules/network                          mappa i repoet
  #   ?ref=network-v1.2.0                        taggen
  source = "git::https://github.com/snellerina91/iac-terraform.git//modules/network?ref=network-v1.2.0"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}
