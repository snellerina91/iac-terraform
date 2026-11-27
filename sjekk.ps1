# =============================================================================
#  sjekk.ps1  –  DEN LOKALE FEEDBACK-LØKKEN, PÅ ROTA AV REPOET
# -----------------------------------------------------------------------------
#  Fem verktøy, seks steg, én kommando:
#
#    pwsh ./sjekk.ps1                  (sjekker modules/network)
#    pwsh ./sjekk.ps1 -Mappe modul8    (sjekker en annen mappe)
#
#  Skrevet i PowerShell 7 fordi det er det ene skallet som finnes på både
#  Windows og Mac i dette faget. Start det med pwsh – ikke i Windows
#  PowerShell 5.1, som sperrer skript som standard.
#
#  test-network.yml er den samme lista, steg for steg. Endrer du rekkefølgen
#  eller en kommando her, skal den samme endringen inn der.
# =============================================================================

param([string]$Mappe = "modules/network")

# Rekkefølgen er bevisst: billigst og raskest først. Feiler fmt, er det ingen
# grunn til å vente på Checkov. [ordered] gjør at løkka under går gjennom
# stegene i den rekkefølgen de står her.
$steg = [ordered]@{
  "fmt"      = { terraform fmt -check -diff -recursive }
  "init"     = { terraform init -backend=false -input=false > $null }
  "validate" = { terraform validate }
  "tflint"   = { tflint --init > $null; tflint }
  "checkov"  = { checkov -d . }
  "test"     = { terraform test }
}

# Push-Location/Pop-Location: terminalen står der den sto etterpå, også når
# et steg feiler. finally kjører uansett.
Push-Location $Mappe
try {
  foreach ($navn in $steg.Keys) {
    Write-Host "`n== $navn ==" -ForegroundColor Cyan
    & $steg[$navn]

    # Hele kontrakten skriptet bygger på: alle fem verktøyene avslutter med
    # 0 når alt er i orden, og med noe annet når de finner noe.
    # $LASTEXITCODE er koden fra det siste programmet som kjørte.
    if ($LASTEXITCODE -ne 0) {
      Write-Host "`n✗ Stoppet på $navn" -ForegroundColor Red
      exit 1
    }
  }
  Write-Host "`n✓ Alle sjekkene er grønne" -ForegroundColor Green
}
finally {
  Pop-Location
}
