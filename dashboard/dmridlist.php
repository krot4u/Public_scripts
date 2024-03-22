<?php
require_once('config/version.php');
require_once('config/ircddblocal.php');
require_once('config/language.php');
$configs = array();
if ($configfile = fopen($gatewayConfigPath,'r')) {
        while ($line = fgets($configfile)) {
                list($key,$value) = preg_split('/=/',$line);
                $value = trim(str_replace('"','',$value));
                if ($key != 'ircddbPassword' && strlen($value) > 0)
                $configs[$key] = $value;
        }

}
$progname = basename($_SERVER['SCRIPT_FILENAME'],".php");
$rev=$version;
$MYCALL=strtoupper($callsign);

// Check if the config file exists
if (file_exists('/etc/pistar-css.ini')) {
	$piStarCssFile = '/etc/pistar-css.ini';
	if (fopen($piStarCssFile,'r')) { $piStarCss = parse_ini_file($piStarCssFile, true); }
	if ($piStarCss['BannerH1']['Enabled']) {
		$piStarCssBannerH1 = $piStarCss['BannerH1']['Text'];
	}
	if ($piStarCss['BannerExtText']['Enabled']) {
		$piStarCssBannerExtTxt = $piStarCss['BannerExtText']['Text'];
	}
}

//Load the Pi-Star Release file
$pistarReleaseConfig = '/etc/pistar-release';
$configPistarRelease = array();
$configPistarRelease = parse_ini_file($pistarReleaseConfig, true);
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" lang="en">
<head>
    <meta name="robots" content="index" />
    <meta name="robots" content="follow" />
    <meta name="language" content="English" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <?php echo "<meta name=\"generator\" content=\"$progname $rev\" />\n"; ?>
    <meta name="Author" content="Hans-J. Barthen (DL5DI), Kim Huebel (DG9VH) and Andy Taylor (MW0MWZ)" />
    <meta name="Description" content="Pi-Star Dashboard" />
    <meta name="KeyWords" content="MW0MWZ,MMDVMHost,ircDDBGateway,D-Star,ircDDB,Pi-Star,Blackwood,Wales,DL5DI,DG9VH" />
    <meta http-equiv="cache-control" content="max-age=0" />
    <meta http-equiv="cache-control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="expires" content="0" />
    <meta http-equiv="pragma" content="no-cache" />
    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
    <link rel="stylesheet" type="text/css" href="css/nice-select.min.css?ver=<?php echo $configPistarRelease['Pi-Star']['Version']; ?>" />
    <title><?php echo "$MYCALL"." - ".$lang['digital_voice']." ".$lang['dashboard'];?></title>
<?php include_once "config/browserdetect.php"; ?>
    <script type="text/javascript" src="/jquery.min.js"></script>
    <script type="text/javascript" src="/functions.js"></script>
    <script type="text/javascript">
      $.ajaxSetup({ cache: false });
    </script>
</head>
<body>
<?php
if ( ($_SERVER["PHP_SELF"] == "/admin/index.php") && ($configPistarRelease['Pi-Star']['Version'] < 4.1) && ($configPistarRelease['Pi-Star']['Hardware'] == "RPi") ) {
?>
<div>
  <table align="center" width="760px" style="margin: 0px 0px 10px 0px; width: 100%;">
    <tr>
    <td align="center" valign="top" style="background-color: #ffff90; color: #906000;">Alert: You are running an outdated version of Pi-Star, please upgrade.<br />
    New versions are available from the here: <a href="http://www.pistar.uk/downloads/" alt="Pi-Star Downloads">http://www.pistar.uk/downloads/</a>.</td>
    </tr>
  </table>
</div>
<?php }
if ( ($_SERVER["PHP_SELF"] == "/admin/index.php") && ($configPistarRelease['Pi-Star']['Version'] >= "4.1") && ($configPistarRelease['Pi-Star']['Version'] < "4.1.6") ) {
?>
<div>
  <table align="center" width="760px" style="margin: 0px 0px 10px 0px; width: 100%;">
    <tr>
    <td align="center" valign="top" style="background-color: #ffff90; color: #906000;">Alert: An upgrade to Pi-Star has been released, click here to upgrade now: <a href="/admin/expert/upgrade.php" alt="Upgrade Pi-Star">Upgrade Pi-Star</a>.</td>
    </tr>
  </table>
</div>
<?php } ?>
<div class="container">
<div class="header">
<div style="font-size: 8px; text-align: left; padding-left: 8px; float: left;">Hostname: <?php echo exec('cat /etc/hostname'); ?></div><div style="font-size: 8px; text-align: right; padding-right: 8px;">Pi-Star:<?php echo $configPistarRelease['Pi-Star']['Version']?> / <?php echo $lang['dashboard'].": ".$version; ?></div>
<h1>Pi-Star <?php echo $lang['digital_voice']." ".$lang['dashboard_for']." ".$MYCALL; ?></h1>
<a href="http://pi-star/?"><div align="center"><img src="/images/header.png" alt="QRA-Team Pi-Star" /></a>
 <?php if (isset($piStarCssBannerExtTxt)) { echo "<p style=\"text-align: center; color: #ffffff;\">".$piStarCssBannerExtTxt."</p>\n"; }?>
  <p style="padding-right: 5px; text-align: right; color: #ffffff;">
  <a href="https://qra-team.online/" style="color: #ffffff;" target="_blank">XLX Server</a> |
  <a href="/dmridlist.php" style="color: #ffffff;">DMRID-List</a> |
  <a href="/" style="color: #ffffff;"><?php echo $lang['dashboard'];?></a> |
  <a href="/admin/" style="color: #ffffff;"><?php echo $lang['admin'];?></a> |
  <?php if ($_SERVER["PHP_SELF"] == "/admin/index.php") {
    echo ' <a href="/admin/live_modem_log.php" style="color: #ffffff;">'.$lang['live_logs'].'</a> |'."\n";
    echo ' <a href="/admin/live_dmrgw_log.php" style="color: #ffffff;">DMRGW Logs</a> |'."\n";
    echo ' <a href="/admin/power.php" style="color: #ffffff;">'.$lang['power'].'</a> |'."\n";
    echo ' <a href="/admin/update.php" style="color: #ffffff;">'.$lang['update'].'</a> |'."\n";
    } ?>
  <a href="/admin/configure.php" style="color: #ffffff;"><?php echo $lang['configuration'];?></a>
</p>
</div>

<div class="lastHerd">

<table frame='border'  cellpadding='5' cellspacing='5' border="1">
<tbody>
<col align='left'</col>
<col align='left'</col>
<tr>
<th>DMR ID</th>
<th>Callsign</th>
</tr>

  <?php
    // $row = 1;
    if (($handle = fopen("/usr/local/etc/dmrid.dat", "r")) !== FALSE) {
        while (($data = fgetcsv($handle, 1000, ";")) !== FALSE) {
            // $num = count($data);
            $num = 2;
            echo '<tr>';
            for ($c=0; $c < $num; $c++) {
                  $value = $data[$c];
                echo '<td>'.$value.'</td>';
            }
            echo '</tr>';
            $row++;
        }
        echo '</tbody></table>';
        fclose($handle);
    }
  ?>
</div>

<div class="footer">
<a style="color: #fcf811;" href="https://help.qra-team.online/" target="_new">&copy; QRA-Team Help</a><br />
XLX Server <a style="color: #fcf811;" href="https://qra-team.online/" target="_new">Dashboard</a><br />
<a style="color: #fcf811;" href="https://qra-team.ru" target="_new">QRA-Team.ru</a><br />
&copy; Andy Taylor (MW0MWZ) 2014-<?php echo date("Y"); ?>.<br />
</div>

</div>
</body>
</html>
