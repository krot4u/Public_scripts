<?php
include_once 'include/config.php';
include_once 'include/tools.php';
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" lang="en">
<head>
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
</head>
<body style="background-color: #182A69;font: 11pt arial, sans-serif;">
<div class="content"><center>
<?php
if ( RXMONITOR == "YES" ) {
echo '<button class="button link", onclick="playAudioToggle(8081, this)"><b>&nbsp;&nbsp;&nbsp;<img src=images/speaker.png alt="" style="vertical-align:middle">&nbsp;&nbsp;Трансляция&nbsp;&nbsp;&nbsp;</b></button>';}
?>
</div></center>
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
    echo '</td>';
?>
</body>
</html>