#
$dmridFileLocation = "https://raw.githubusercontent.com/krot4u/Public_scripts/master/dmrid.dat"
$dmridFile = "/opt/dmrid.dat"
$jsonFile = "/opt/HBmonitor/local_subscriber_ids.json"

curl -o $dmridFile -s $dmridFileLocation
$dmridContent = Get-Content $dmridFile

$dmridCallsign = $null
foreach ($string in $dmridContent) {
        $dmrid = $string.Split(";")[0]
        $callsign = $string.Split(";")[1]
        $dmridCallsign += @(@{
                "fname" = "$dmrid"
                "name" = "$callsign"
                "country" = "Russia"
                "callsign" = "$callsign"
                "city" = "QRAcity"
                "surname" = "QRA"
                "radio_id" = "$dmrid"
                "id" = "$dmrid"
                "state" = "MO"
        })
}
$subscriberObject = @{
        "users" = @($dmridCallsign)
        }

$subscriberJson = $subscriberObject | ConvertTo-Json -Depth 2 -Compress
Set-Content -Path $jsonFile -Value $subscriberJson

systemctl restart hbmon.service