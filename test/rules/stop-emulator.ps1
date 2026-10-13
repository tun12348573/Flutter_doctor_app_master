# firebase emulators:exec leaves the database emulator's java process running on Windows.
Get-CimInstance Win32_Process -Filter "Name='java.exe'" |
  Where-Object CommandLine -match 'firebase-database-emulator' |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Confirm:$false }
