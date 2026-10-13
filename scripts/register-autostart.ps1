param([switch]$Remove)

# Starts n8n hidden at Windows logon. Ollama starts itself; Tailscale Funnel (--bg) persists in its service.
$ErrorActionPreference = 'Stop'
$taskName = 'DoctorApp n8n'
if ($Remove) {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
  exit 0
}
$script = Join-Path $PSScriptRoot 'start-n8n.ps1'
$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
  -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`"" `
  -WorkingDirectory (Split-Path $PSScriptRoot -Parent)
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Write-Host "Registered '$taskName'. Start now: Start-ScheduledTask -TaskName '$taskName'"
