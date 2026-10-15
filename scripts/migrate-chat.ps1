# One-off: moves old flat /Chat/<msgId> messages into /Chat/<uidA_uidB>/<msgId> (uids in ordinal order,
# same as chatId() in lib/chat_screen.dart). Safe to re-run. Saves a backup to .local/ first.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$target = @('--project', 'doctor-app-df8ca', '--instance', 'doctor-app-df8ca-default-rtdb')
New-Item -ItemType Directory -Force (Join-Path $projectRoot '.local') | Out-Null
$backup = Join-Path $projectRoot ".local/chat-backup-$(Get-Date -Format yyyyMMdd-HHmmss).json"

# Use files, not the pipeline: Windows PowerShell would mangle Vietnamese text.
firebase database:get /Chat @target --output $backup
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$chat = [IO.File]::ReadAllText($backup) | ConvertFrom-Json
$moves = [ordered]@{}
if ($chat) {
  foreach ($entry in $chat.PSObject.Properties) {
    $m = $entry.Value
    if ($null -eq $m.sender) { continue }   # already a conversation node
    $a = [string]$m.sender; $b = [string]$m.receiver
    if ([string]::CompareOrdinal($a, $b) -gt 0) { $a, $b = $b, $a }
    $moves["$($a)_$($b)/$($entry.Name)"] = $m
    $moves[$entry.Name] = $null
  }
}
if ($moves.Count -eq 0) { Write-Host 'Nothing to migrate.'; exit 0 }

$file = New-TemporaryFile
try {
  [IO.File]::WriteAllText($file.FullName, ($moves | ConvertTo-Json -Depth 5 -Compress))
  firebase database:update /Chat $file.FullName @target --force
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
  Remove-Item -LiteralPath $file
}
Write-Host "Moved $($moves.Count / 2) messages. Backup: $backup"
