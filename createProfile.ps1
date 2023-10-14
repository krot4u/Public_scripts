# ./createProfile.ps1 -Callsign "TASKENT" -DmrID 5973272 -delete no
param (
  [string]$delete = "no",
  [ValidateScript({
    if ($_.ToUpper() -match "^[a-zA-Z]+[0-9]+|[0-9]+|[a-zA-Z]+$" -and $_.Length -le 7) {
      $true
    }
    else {
      throw "$_ is invalid."
    }})]
  [Parameter(Mandatory=$true)][string]$Callsign,
  [ValidateScript({
    if ($_ -match "^[0-9]{7}$") {
      $true
    }
    else {
      throw "$_ is invalid"
    }})]
  [Parameter(Mandatory=$true)][string]$DmrID
)

[string]$md380port = [int]$(ss -tulnp | grep -E '0:24.*qemu-arm-static.*' | sort -k 5 | awk '{print $5}' | tail -n1 | awk -F ":" '{print $2}') + 1
[string]$dmrNetworkLocalPort = [int]$(ss -tulnp | grep -E '0:620.*MMDVM_Bridge' | sort -k 5 | awk '{print $5}' | tail -n1 | awk -F ":" '{print $2}') + 1
[string]$AmbeTXport = [int]$(ss -tulnp | grep -E '0:31.*MMDVM_Bridge' | sort -k 5 | awk '{print $5}' | tail -n1 | awk -F ":" '{print $2}') + 1
[string]$AmbeRXport = [int]$(ss -tulnp | grep -E '0:31.*Analog_Bridge' | sort -k 5 | awk '{print $5}' | tail -n1 | awk -F ":" '{print $2}') + 1
[string]$UsrpPort = "50$($DmrID.Substring($DmrID.Length - 3))"
[string]$Callsign = $($Callsign.ToUpper())
[string]$CallsignLow = $($Callsign.ToLower())

# $md380port = $md380port + 1
# $dmrNetworkLocalPort = $dmrNetworkLocalPort + 1
# $AmbeTXport = $AmbeTXport + 1
# $AmbeRXport = $AmbeRXport + 1

function log {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Message
  )
   Write-Host "$Message" -ForegroundColor green
}

function replaceInFile {
  [CmdletBinding()]
  param (
    [Parameter()]
    [System.IO.FileInfo]$Path,
    [string]$target,
    [string]$string
  )
  (Get-Content $Path).replace($target, $string) | Set-Content $Path
}

if ($delete -eq "yes") {
  systemctl stop analog_bridge_$DmrID.service
  systemctl disable analog_bridge_$DmrID.service
  systemctl stop mmdvm_bridge_$DmrID.service
  systemctl disable mmdvm_bridge_$DmrID.service
  systemctl stop md380-emu_$DmrID.service
  systemctl disable md380-emu_$DmrID.service
  Remove-Item -Path /lib/systemd/system/*$DmrID.service -Force
  Remove-Item -Path /opt/profiles/$CallsignLow -Recurse -Force
}

else {
  log "Copy INI files..."
  # ----- Copy INI files ----- #
  New-Item -Type Directory /opt/profiles/$CallsignLow
  Copy-Item /opt/profiles/default/Analog_Bridge.ini /opt/profiles/$CallsignLow
  Copy-Item /opt/profiles/default/DVSwitch.ini /opt/profiles/$CallsignLow
  Copy-Item /opt/profiles/default/MMDVM_Bridge.ini /opt/profiles/$CallsignLow
  Copy-Item /opt/profiles/default/var.txt /opt/profiles/$CallsignLow

  log "Replace stub in INI files..."
  # ----- Replace stub in INI files ----- #
  replaceInFile -Path /opt/profiles/$CallsignLow/MMDVM_Bridge.ini -target "--CallSignReplace--" -string $Callsign
  replaceInFile -Path /opt/profiles/$CallsignLow/MMDVM_Bridge.ini -target "--DMRID--" -string $dmrID
  replaceInFile -Path /opt/profiles/$CALLSIGNLOW/MMDVM_Bridge.ini -target "--DmrNetworkLocalPort--" -string $dmrNetworkLocalPort
  replaceInFile -Path /opt/profiles/$CallsignLow/MMDVM_Bridge.ini -target "--DMRIDSHORT--" -string $DmrID
  replaceInFile -Path /opt/profiles/$CallsignLow/Analog_Bridge.ini -target "--DMRID--" -string $dmrID
  replaceInFile -Path /opt/profiles/$CallsignLow/Analog_Bridge.ini -target "--md380port--" -string $MD380PORT
  replaceInFile -Path /opt/profiles/$CallsignLow/Analog_Bridge.ini -target "--txPort--" -string $AmbeTXport
  replaceInFile -Path /opt/profiles/$CallsignLow/Analog_Bridge.ini -target "--rxPort--" -string $AmbeRXport
  replaceInFile -Path /opt/profiles/$CallsignLow/Analog_Bridge.ini -target "--usrpPortReplace--" -string $UsrpPort
  replaceInFile -Path /opt/profiles/$CallsignLow/DVSwitch.ini -target "--rxPort--" -string $AmbeRXport
  replaceInFile -Path /opt/profiles/$CallsignLow/DVSwitch.ini -target "--txPort--" -string $AmbeTXport
  replaceInFile -Path /opt/profiles/$CallsignLow/var.txt -target "--usrpPortReplace--" -string $UsrpPort
  replaceInFile -Path /opt/profiles/$CallsignLow/var.txt -target "--CallSignReplace--" -string $Callsign
  replaceInFile -Path /opt/profiles/$CallsignLow/var.txt -target "--DMRID--" -string $dmrID

  New-Item -Type Directory /var/log/dvswitch_$DmrID

  log "Prepare services files..."
  Copy-Item /opt/profiles/default/analog_bridge_default.service /lib/systemd/system/analog_bridge_$DmrID.service
  Copy-Item /opt/profiles/default/mmdvm_bridge_default.service /lib/systemd/system/mmdvm_bridge_$DmrID.service
  Copy-Item /opt/profiles/default/md380-emu_default.service /lib/systemd/system/md380-emu_$DmrID.service

  replaceInFile -Path /lib/systemd/system/analog_bridge_$DmrID.service -target "--DMRID--" -string $DmrID
  replaceInFile -Path /lib/systemd/system/analog_bridge_$DmrID.service -target "--CALLSIGN--" -string $CallsignLow
  replaceInFile -Path /lib/systemd/system/mmdvm_bridge_$DmrID.service -target "--CALLSIGN--" -string $CallsignLow
  replaceInFile -Path /lib/systemd/system/md380-emu_$DmrID.service -target "--md380port--" -string $md380port

  log "Enable systemctl..."
  systemctl enable analog_bridge_$DmrID.service
  systemctl enable mmdvm_bridge_$DmrID.service
  systemctl enable md380-emu_$DmrID.service

  log "Starting systemctl..."
  systemctl start analog_bridge_$DmrID.service
  $RESULTANALOGBRIDGE=$(systemctl status analog_bridge_$DmrID.service | grep Active:)
  log $RESULTANALOGBRIDGE
  systemctl start mmdvm_bridge_$DmrID.service
  $RESULTMMDVM=$(systemctl status mmdvm_bridge_$DmrID.service | grep Active:)
  log $RESULTMMDVM
  systemctl start md380-emu_$DmrID.service
  $RESULTMD380=$(systemctl status md380-emu_$DmrID.service | grep Active:)
  log $RESULTMD380
}