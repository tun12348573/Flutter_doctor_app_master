# Loads data/drugs.json into Realtime Database /Drugs with the Firebase CLI (owner credentials, bypasses rules).
# Merges by drug id: listed drugs are overwritten (including stock), other drugs are kept.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
firebase database:update /Drugs (Join-Path $projectRoot 'data/drugs.json') `
  --project doctor-app-df8ca --instance doctor-app-df8ca-default-rtdb --force
exit $LASTEXITCODE
