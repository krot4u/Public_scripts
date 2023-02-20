#!/usr/bin/pwsh

#apt update  && apt install -y curl gnupg apt-transport-https
# curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
#apt update && apt install -y powershell
# Start PowerShell
#pwsh

$dmridDatFile = "/xlxd/dmrid.dat"
$blacklistFile ="/xlxd/xlxd.blacklist"
$fileBackup = "/xlxd/backup/dmrid_$(Get-Date -Format 'dd.MM.yyyy_HH-mm').dat"

if (!$(Test-Path -Path /xlxd/backup)) {New-Item -ItemType Directory /xlxd/backup}

Write-Output "--> Backup dmrid.dat"
Copy-Item $dmridDatFile $fileBackup
Write-Output "------------"

Write-Output "--> Prune backups"
Remove-Item "/xlxd/backup/dmrid_$((Get-Date).AddDays(-1).ToString('dd.MM.yyyy'))*" -Force
Write-Output "------------"

Write-Output "--> Download dmrid from GD..."
invoke-webrequest `
  -Uri "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrid.dat" `
  -OutFile $dmridDatFile
Write-Output "------------"

Write-Output "--> Download blacklist from GD..."
invoke-webrequest `
  -Uri "https://raw.githubusercontent.com/krot4u/Public_scripts/master/xlxd.blacklist" `
  -OutFile $blacklistFile
Write-Output "------------"