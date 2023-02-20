Write-Output "--> Download ipblacklist from GD..."
$ipblacklistFile = invoke-webrequest `
  -Uri "https://raw.githubusercontent.com/krot4u/Public_scripts/master/ipblacklist.csv" `
  -OutFile /opt/ipblacklist.csv
Write-Output "------------"

# Remove iptables rule
iptables -F INPUT

$ipblacklist = Get-Content /opt/ipblacklist.csv
foreach ($ip in $ipblacklist) {
        iptables -A INPUT -s $ip -j DROP
}
