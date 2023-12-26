<?php
include_once 'include/config.php';
include_once 'include/tools.php';
include_once 'include/browserdetect.php';
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
<?php include_once "include/browserdetect.php"; ?>
<?php if ($browser == 'android'): ?> 
  <link rel="stylesheet" type="text/css" media="screen and (min-device-width: 380px)" href="./css/css.php" />
  <link rel="stylesheet" type="text/css" media="screen and (max-device-width: 379px)" href="./css/css-mini.php" />
<?php else: ?> 
  <link rel="stylesheet" type="text/css" href="./css/css.php">
<?php endif; ?>
    <script type="text/javascript" src="scripts/jquery.min.js"></script>
    <script type="text/javascript" src="scripts/functions.js"></script>
    <script type="text/javascript" src="scripts/pcm-player.min.js"></script>
    <script type="text/javascript">
      $.ajaxSetup({ cache: false });
    </script>
    <link href="./css/featherlight.css" type="text/css" rel="stylesheet" />
    <script src="./scripts/featherlight.js" type="text/javascript" charset="utf-8"></script>
    <script src="./scripts/vumeter.js" type="text/javascript"></script>
    <script>
      $(document).ready(() => vumeter(demo, {
        "boxCount": 20,
        "boxGapFraction": 0.4,
        "max": 100,
        "boxCountRed": 4,
        "boxCountYellow": 5,
        "jitter": 0.13,
      }));
  </script>
</head>
</head>
<body style="background-color: #000926;font: 11pt arial, sans-serif;">
<center>
<fieldset style="box-shadow:0 0 5px #999; background-color:#182A69; width:0px;margin-top:15px;margin-left:0px;margin-right:5px;font-size:13px;border-top-left-radius: 10px; border-top-right-radius: 10px;border-bottom-left-radius: 10px; border-bottom-right-radius: 10px;">
<div class="container"> 
<div class="header">
<center>
<div align="center"><img src="/images/header.png" alt="QRA-Team" />
</center>
</div>
<div class="content"><center>
<canvas id="demo" width="28px" height="250" data-val="0" style="
    transform: rotate(90deg);
    margin-bottom: -100px;
    margin-top: -100px;
    position: relative;
    filter: drop-shadow(2px 2px 5px);
">No canvas</canvas>
<div style="margin-top:8px;">
<?php
if ( RXMONITOR == "YES" ) {
echo '<button class="button link", onclick="playAudioToggle(8081, this)"><b>&nbsp;&nbsp;&nbsp;<img src=images/speaker.png alt="" style="vertical-align:middle">&nbsp;&nbsp;Трансляция&nbsp;&nbsp;&nbsp;</b></button>';}
?>
</div></center>
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
    echo '<table style="border:none; border-collapse:collapse; cellspacing:0; cellpadding:0; background-color:#182A69;"><tr style="border:none;background-color:#182A69;">';
    echo '<td width="200px" valign="top" class="hide" style="border:none;background-color:#182A69;">';
    echo '<div class="nav">'."\n";
    echo '<script type="text/javascript">'."\n";
    echo 'function reloadModeInfo(){'."\n";
    echo '  $("#modeInfo").load("include/status.php",function(){ setTimeout(reloadModeInfo,1000) });'."\n";
    echo '}'."\n";
    echo 'setTimeout(reloadModeInfo,1000);'."\n";
    echo '$(window).trigger(\'resize\');'."\n";
    echo '</script>'."\n";
    echo '<div id="modeInfo">'."\n";
    include 'include/status.php';			// Mode and Networks Info
    echo '</div>'."\n";
    echo '</div>'."\n";
    echo '</td>'."\n";

    echo '<td valign="top" style="border:none; height: 480px; background-color:#182A69;">';
    echo '<div class="content">'."\n";
    echo '<script type="text/javascript">'."\n";define("RXMON","YES");define("RXMON","YES");


    echo 'function reloadLocalTx(){'."\n";
    echo '  $("#localTxs").load("include/localtx.php",function(){ setTimeout(reloadLocalTx,1500) });'."\n";
    echo '}'."\n";
    echo 'setTimeout(reloadLocalTx,1500);'."\n";
    echo 'function reloadLastHerd(){'."\n";
    echo '  $("#lastHerd").load("include/lh.php",function(){ setTimeout(reloadLastHerd,1500) });'."\n";
    echo '}'."\n";
    echo 'setTimeout(reloadLastHerd,1500);'."\n";
    echo '$(window).trigger(\'resize\');'."\n";
    echo '</script>'."\n";
    echo '<center><div id="lastHerd">'."\n";
    include 'include/lh.php';
    echo '</div></center>'."\n";
    echo "<br />\n";
    echo '</td>';
?>
</tr></table>
<?php
    echo '<div class="content2">'."\n";
    echo '<script type="text/javascript">'."\n";
    echo 'function reloadSysInfo(){'."\n";
    echo '  $("#sysInfo").load("include/system.php",function(){ setTimeout(reloadSysInfo,15000) });'."\n";
    echo '}'."\n";
    echo 'setTimeout(reloadSysInfo,15000);'."\n";
    echo '$(window).trigger(\'resize\');'."\n";
    echo '</script>'."\n";
    echo '<div id="sysInfo">'."\n";
    include 'include/system.php';		// Basic System Info
    echo '</div>'."\n";
    echo '</div>'."\n";
?>
</fieldset>
</body>
</html>

