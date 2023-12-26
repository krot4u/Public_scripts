<?php
include_once 'include/config.php';
include_once 'include/tools.php';
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" lang="en">
<head>
    <meta name="robots" content="index" />
    <meta name="robots" content="follow" />
    <meta name="language" content="Russian" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="generator" content="DVSwitch" />
    <meta name="KeyWords" content="QRA,QRA-TeamMMDVM_Bridge,Analog_Bridge,DMR" />
    <meta http-equiv="cache-control" content="max-age=0" />
    <meta http-equiv="cache-control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="expires" content="0" />
    <meta http-equiv="pragma" content="no-cache" />
<link rel="shortcut icon" href="images/favicon.ico" sizes="16x16 32x32" type="image/png">
    <title>QRA-Team-DVSwitch Dashboard</title>
    <link rel="stylesheet" type="text/css" href="./css/css-mobile.php" />
    <script type="text/javascript" src="scripts/jquery.min.js"></script>
    <script type="text/javascript" src="scripts/functions.js"></script>
    <script type="text/javascript" src="scripts/pcm-player.min.js"></script>
    <script type="text/javascript">
      $.ajaxSetup({ cache: false });
    </script>
    <link href="./css/featherlight.css" type="text/css" rel="stylesheet" />
    <script src="./scripts/featherlight.js" type="text/javascript" charset="utf-8"></script>
<script src="./scripts/highcharts.js"></script>
<script src="./scripts/highcharts-more.js"></script>
<script src="./scripts/modules/exporting.js"></script>
<script src="./scripts/modules/export-data.js"></script>
<script src="./scripts/modules/accessibility.js"></script>
<style>
    .highcharts-figure,
    .highcharts-data-table table {
        min-width: 300px;
        max-width: 300px;
        margin: 1em auto;
    }

    .highcharts-data-table table {
        font-family: Verdana, sans-serif;
        border-collapse: collapse;
        border: 1px solid #ebebeb;
        margin: 1px auto;
        text-align: center;
        width: 100%;
        max-width: 300px;
    }

    .highcharts-data-table caption {
        padding: 1em 0;
        font-size: 1.2em;
        color: #555;
    }

    .highcharts-data-table th {
        font-weight: 600;
    }

    .highcharts-data-table td,
    .highcharts-data-table th,
    .highcharts-data-table caption {
        padding: 0.5em;
    }

    .highcharts-data-table thead tr,
    .highcharts-data-table tr:nth-child(even) {
        background: #f8f8f8;
    }

    .highcharts-data-table tr:hover {
        background: #f1f7ff;
    }

</style>
<script>
    $(document).ready(() =>
        Highcharts.chart('container', {
            chart: {
                type: 'gauge',
                plotBorderWidth: 1,
                plotBackgroundColor: {
                    linearGradient: { x1: 0, y1: 0 },
                    stops: [
                        [0, '#182A69'],
                        [0.3, '#FFFFFF'],
                        [1, '#182A69']
                    ]
                },
                plotBackgroundImage: null,
                height: 150
            },

            title: {
                text: ''
            },

            pane: [{
                startAngle: -45,
                endAngle: 45,
                background: null,
                center: ['50%', '145%'],
                size: 270
            }],

            exporting: {
                enabled: false
            },

            tooltip: {
                enabled: false
            },

            yAxis: [{
                min: 0,
                max: 255,
                minorTickPosition: 'outside',
                tickPosition: 'outside',
                labels: {
                    rotation: 'auto',
                    distance: 20
                },
                plotBands: [{
                    from: 200,
                    to: 255,
                    color: '#C02316',
                    innerRadius: '100%',
                    outerRadius: '105%'
                }],
                pane: 0,
                title: {
                    text: '<br/><span style="font-size:12p;color:#000000">Уровень громкости</span>',
                    y: -20
                }
            }],

            plotOptions: {
                gauge: {
                    dataLabels: {
                        enabled: false
                    },
                    dial: {
                        radius: '100%'
                    }
                }
            },

            series: [{
                name: 'Channel A',
                data: [-20],
                yAxis: 0
            }]

        },

            // Let the music play
            function (chart) {
                setInterval(function () {
                    if (chart.series) {
                        const left = chart.series[0].points[0];
                        left.update(window.volume, false);
                        chart.redraw();
                    }
                }, 500);

            }));
</script>
</head>
<body style="background-color: #182A69;font: 11pt arial, sans-serif;">
<center>
<div class="container"> 
<div class="header">
<center>
<img style="width: 100%; height: 100%; margin-top:20px;" src="/images/header.png" alt="QRA-Team" />
</center>
</div>
<center>
<div style="margin-top:15px;">
<?php
if ( RXMONITOR == "YES" ) {
echo '<button class="button link" , onclick="playAudioToggle(8081, this)"><b>&nbsp;&nbsp;&nbsp;<img src=images/speaker.png alt="" style="vertical-align:middle">&nbsp;&nbsp;Трансляция&nbsp;&nbsp;&nbsp;</b></button>
<figure class="highcharts-figure">
    <div id="container"></div>
</figure>';}
?>
</center>
</div>
<?php
function getMMDVMConfigFileContent() {
		// loads ini fule into array for further use
		$conf = array();
		if ($configs = @fopen('/opt/MMDVM_Bridge/MMDVM_Bridge.ini', 'r')) {
			while ($config = fgets($configs)) {
				array_push($conf, trim ( $config, " \t\n\r\0\x0B"));
			}
			fclose($configs);
		}
		return $conf;
	}

$mmdvmconfigfile = getMMDVMConfigFileContent();
    echo '<td valign="top" style="border:none; height: 100%; background-color:#182A69;">';
    echo '<div class="content">'."\n";
    echo '<script type="text/javascript">'."\n";define("RXMON","YES");define("RXMON","YES");
    echo 'function reloadLocalTx(){'."\n";
    echo '  $("#localTxs").load("include/localtx.php",function(){ setTimeout(reloadLocalTx,1500) });'."\n";
    echo '}'."\n";
    echo 'setTimeout(reloadLocalTx,1500);'."\n";
    echo 'function reloadLastHerd(){'."\n";
    echo '  $("#lastHerd").load("include/lh-mobile.php",function(){ setTimeout(reloadLastHerd,1500) });'."\n";
    echo '}'."\n";
    echo 'setTimeout(reloadLastHerd,1500);'."\n";
    echo '$(window).trigger(\'resize\');'."\n";
    echo '</script>'."\n";
    echo '<center><div id="lastHerd">'."\n";
    include 'include/lh-mobile.php';
    echo '</div></center>'."\n";
    echo "<br />\n";
    echo '<center><div id="localTxs">'."\n";
    include 'include/localtx.php';
    echo '</div></center>'."\n";
    echo '</td>';
?>
</center>
</body>
</html>
