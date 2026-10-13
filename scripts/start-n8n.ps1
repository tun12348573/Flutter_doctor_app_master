param([switch]$ImportWorkflow)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$nodeDirectory = Get-ChildItem -LiteralPath (Join-Path $projectRoot '.local') -Directory -Filter 'node-v24.*-win-x64' | Select-Object -First 1
if (-not $nodeDirectory) { throw 'Install the isolated Node 24 runtime described in n8n/README.md first.' }
$nodeExecutable = Join-Path $nodeDirectory.FullName 'node.exe'
$n8nExecutable = Join-Path $projectRoot '.local/n8n/node_modules/n8n/bin/n8n'
if (-not (Test-Path -LiteralPath $n8nExecutable)) { throw 'Install n8n first; see n8n/README.md.' }
$env:PATH = "$($nodeDirectory.FullName);$env:PATH"
$env:N8N_USER_FOLDER = Join-Path $projectRoot '.local/n8n-data'
$env:N8N_LISTEN_ADDRESS = '127.0.0.1'
$env:N8N_HOST = 'localhost'
$env:N8N_PORT = '5678'
$env:N8N_PROTOCOL = 'http'
$env:WEBHOOK_URL = 'http://localhost:5678/'
$env:N8N_SECURE_COOKIE = 'false'
$env:N8N_DIAGNOSTICS_ENABLED = 'false'
$env:N8N_VERSION_NOTIFICATIONS_ENABLED = 'false'
$env:N8N_TEMPLATES_ENABLED = 'false'
$env:N8N_PAYLOAD_SIZE_MAX = '1'
$env:N8N_CONCURRENCY_PRODUCTION_LIMIT = '1'
$env:EXECUTIONS_DATA_SAVE_ON_ERROR = 'none'
$env:EXECUTIONS_DATA_SAVE_ON_SUCCESS = 'none'
$env:EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS = 'false'

# Native tools may write warnings to stderr; use their exit code for failure.
$ErrorActionPreference = 'Continue'
if ($ImportWorkflow) {
  & $nodeExecutable $n8nExecutable import:workflow "--input=$(Join-Path $projectRoot 'n8n/patient-ai.workflow.json')"
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  & $nodeExecutable $n8nExecutable publish:workflow --id=doctorappPatientAi
  exit $LASTEXITCODE
}
& $nodeExecutable $n8nExecutable start
exit $LASTEXITCODE
