param(
  [Parameter(Mandatory)][string]$Uid,
  [Parameter(Mandatory)][string]$Email,
  [switch]$Remove
)

# Grants (or with -Remove revokes) the pharmacist role. Create the user first in
# Firebase Console > Authentication, then copy its User UID here.
$ErrorActionPreference = 'Stop'
if ($Uid -notmatch '^[A-Za-z0-9]{20,128}$') { throw 'Uid looks wrong; copy "User UID" from Firebase Console.' }
$target = @('--project', 'doctor-app-df8ca', '--instance', 'doctor-app-df8ca-default-rtdb', '--force')
if ($Remove) {
  firebase database:remove "/Pharmacists/$Uid" @target
} else {
  $data = @{ email = $Email } | ConvertTo-Json -Compress
  firebase database:set "/Pharmacists/$Uid" --data $data @target
}
exit $LASTEXITCODE
