<?php
/**
 * System info partial — hostname, kernel, platform, CPU load/temp, service
 * status grid (MMDVMHost / DStarRepeater / ircDDBGateway / TimeServer /
 * PiStar-Watchdog / PiStar-Remote).
 *
 * Loaded inline by /index.php on the admin path and AJAX-refreshed every
 * 15 seconds via $("#sysInfo").load(...). Used in BOTH MMDVMHost and
 * DStarRepeater modes (same partial, gated by /index.php).
 *
 * Served two ways from /index.php: an inline `include` for the initial
 * page render, then AJAX `$("#sysInfo").load(...)` for refreshes. On
 * the inline path the parent has already emitted full security headers
 * (and the headers_sent() guard inside makes our call idempotent); on
 * the AJAX path the response is XHR — X-Frame-Options / frame-ancestors
 * apply to iframe ancestry, not XHR, so the embeddable variant is the
 * correct choice in both directions.
 *
 * Reads /etc/ircddbgateway (flat key=value via the hand-rolled parser)
 * to surface the gateway callsign in the hardware-info table.
 */

require_once($_SERVER['DOCUMENT_ROOT'] . '/config/security_headers.php');
setEmbeddableSecurityHeaders();

include_once $_SERVER['DOCUMENT_ROOT'].'/config/ircddblocal.php';
include_once $_SERVER['DOCUMENT_ROOT'].'/config/language.php';          // Translation Code
include_once $_SERVER['DOCUMENT_ROOT'].'/mmdvmhost/tools.php';
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
$rev="20141101";
$MYCALL=strtoupper($callsign);
?>
<?php
$cpuLoad = sys_getloadavg();
$cpuTempCRaw = exec('cat /sys/class/thermal/thermal_zone0/temp');
if ($cpuTempCRaw > 1000) { $cpuTempC = round($cpuTempCRaw / 1000, 1); } else { $cpuTempC = round($cpuTempCRaw, 1); }
$cpuTempF = round(+$cpuTempC * 9 / 5 + 32, 1);
if ($cpuTempC < 50) { $cpuTempHTML = "<td style=\"background: #3BB273\">".$cpuTempC."&deg;C / ".$cpuTempF."&deg;F</td>\n"; }
if ($cpuTempC >= 50) { $cpuTempHTML = "<td style=\"background: #F6A641\">".$cpuTempC."&deg;C / ".$cpuTempF."&deg;F</td>\n"; }
if ($cpuTempC >= 69) { $cpuTempHTML = "<td style=\"background: #f00\">".$cpuTempC."&deg;C / ".$cpuTempF."&deg;F</td>\n"; }
?>
<b><?php echo $lang['hardware_info'];?></b>
<table style="table-layout: fixed;">
  <tr>
    <th><?php echo $lang['hostname'];?></th>
    <th><?php echo $lang['kernel'];?></th>
    <th colspan="2"><?php echo $lang['platform'];?></th>
    <th><?php echo $lang['cpu_load'];?></th>
    <th><?php echo $lang['cpu_temp'];?></th>
  </tr>
  <tr>
    <td><?php $h = php_uname('n'); if (strlen($h) >= 16) { $h = substr($h, 0, 14) . '..'; } echo htmlspecialchars((string)$h, ENT_QUOTES, 'UTF-8'); ?></td>
    <td><?php echo htmlspecialchars((string)php_uname('r'), ENT_QUOTES, 'UTF-8');?></td>
    <td colspan="2"><?php echo htmlspecialchars((string)exec('/usr/local/bin/platformDetect.sh'), ENT_QUOTES, 'UTF-8');?></td>
    <td><?php echo number_format($cpuLoad[0],2);?> / <?php echo number_format($cpuLoad[1],2);?> / <?php echo number_format($cpuLoad[2],2);?></td>
    <?php echo $cpuTempHTML; ?>
  </tr>
  <tr>
    <th colspan="6"><?php echo $lang['service_status'];?></th>
  </tr>
  <tr>
    <td style="background: #<?php if (isProcessRunning('MMDVMHost')) { echo "3BB273"; } else { echo "F6414B"; } ?>">MMDVMHost</td>
    <td style="background: #<?php if (isProcessRunning('dstarrepeaterd')) { echo "3BB273"; } else { echo "F6414B"; } ?>">DStarRepeater</td>
    <td style="background: #<?php if (isProcessRunning('ircddbgatewayd')) { echo "3BB273"; } else { echo "F6414B"; } ?>">ircDDBGateway</td>
    <td style="background: #<?php if (isProcessRunning('timeserverd')) { echo "3BB273"; } else { echo "F6414B"; } ?>">TimeServer</td>
    <td style="background: #<?php if (isProcessRunning('/usr/local/sbin/pistar-watchdog',true)) { echo "3BB273"; } else { echo "F6414B"; } ?>">PiStar-Watchdog</td>
    <td style="background: #<?php if (isProcessRunning('/usr/local/sbin/pistar-remote',true)) { echo "3BB273"; } else { echo "F6414B"; } ?>">PiStar-Remote</td>
  </tr>
</table>
<br />
