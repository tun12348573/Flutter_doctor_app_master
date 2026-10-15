param(
  [Parameter(Mandatory)][string]$Uid,
  [switch]$Remove
)

# Verifies (or with -Remove un-verifies) a doctor so patients can find and book them.
# Check the doctor's credentials first; copy the User UID from Firebase Console > Authentication.
$ErrorActionPreference = 'Stop'
if ($Uid -notmatch '^[A-Za-z0-9]{20,128}$') { throw 'Uid looks wrong; copy "User UID" from Firebase Console.' }
$target = @('--project', 'doctor-app-df8ca', '--instance', 'doctor-app-df8ca-default-rtdb', '--force')
if ($Remove) {
  firebase database:remove "/Doctors/$Uid/verified" @target
} else {
  firebase database:set "/Doctors/$Uid/verified" --data true @target
}
exit $LASTEXITCODE
