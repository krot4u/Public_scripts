#!/usr/bin/env pwsh

#apt update  && apt install -y curl gnupg apt-transport-https
# curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
#apt update && apt install -y powershell
# Start PowerShell
#pwsh

$dmridCSVFile = "./DMRid/dmrid.csv"
$blacklistCSVFile = "./DMRid/blacklist.csv"
$dmridDatFile = "./dmrid.dat"
$blacklistFile ="./xlxd.blacklist"
$DMRIdsFile = "./DMRIds.dat"

Write-Output "--> Download from Original DMRIds..."
invoke-webrequest `
  -Uri "http://www.pistar.uk/downloads/DMRIds.dat" `
  -OutFile $DMRIdsFile
Write-Output "------------"

Write-Output "--> Download dmrid from GD..."
invoke-webrequest `
  -Uri "https://docs.google.com/spreadsheets/d/1dJBa8J5iXUmXk6cKkXX5w6N43xu8uEkvXUOZkozs9Es/export?format=csv" `
  -OutFile $dmridCSVFile
Write-Output "------------"

Write-Output "--> Download blacklist from GD..."
invoke-webrequest `
  -Uri "https://docs.google.com/spreadsheets/d/1dJBa8J5iXUmXk6cKkXX5w6N43xu8uEkvXUOZkozs9Es/gviz/tq?tqx=out:csv&sheet=blacklist" `
  -OutFile $blacklistCSVFile
Write-Output "------------"

Write-Output "--> Replace dmrid.dat..."
$dmridCSVcontent = $(Get-Content $dmridCSVFile | Select-Object -Skip 1).ToUpper() | Sort-Object -Unique
$dmridCSVcontent.Replace(",",";")-replace '$',';' | Set-Content $dmridDatFile -Force
Write-Output "------------"

Write-Output "--> Replace xlxd.blacklist"
((Get-Content $blacklistCSVFile | Select-Object -Skip 1).ToUpper() | Sort-Object -Unique).Replace('"','') | Set-Content $blacklistFile -Force
Write-Output "------------"

Write-Output "--> Replace DMRIds.dat..."
$DMRIds = $dmridCSVcontent -replace ",","`t"
$DMRIds -replace "$","`tRussia" | Add-Content $DMRIdsFile
Write-Output "------------"

Write-Output "Done..!"
