<?php include_once $_SERVER['DOCUMENT_ROOT'].'/config/ircddblocal.php';
include_once $_SERVER['DOCUMENT_ROOT'].'/config/language.php';	      // Translation Code
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
    <td><?php echo php_uname('n');?></td>
    <td><?php echo php_uname('r');?></td>
    <td colspan="2"><?php echo exec('/usr/local/bin/platformDetect.sh');?></td>
    <td><?php echo $cpuLoad[0];?> / <?php echo $cpuLoad[1];?> / <?php echo $cpuLoad[2];?></td>
    <?php echo $cpuTempHTML; ?>
  </tr>
  <tr>
    <th colspan="6"><?php echo $lang['service_status'];?></th>
  </tr>
  <tr>
    <td style="background: #<?php if (isProcessRunning('MMDVMHost')) { echo "3BB273"; } else { echo "F6414B"; } ?>">MMDVMHost</td>
    <td style="background: #<?php if (isProcessRunning('DMRGateway')) { echo "3BB273"; } else { echo "F6414B"; } ?>">DMRGateway</td>
    <td style="background: #<?php if (isProcessRunning('YSFGateway')) { echo "3BB273"; } else { echo "F6414B"; } ?>">YSFGateway</td>
    <td style="background: #<?php if (isProcessRunning('YSFParrot')) { echo "3BB273"; } else { echo "F6414B"; } ?>">YSFParrot</td>
    <td style="background: #<?php if (isProcessRunning('P25Gateway')) { echo "3BB273"; } else { echo "F6414B"; } ?>">P25Gateway</td>
    <td style="background: #<?php if (isProcessRunning('P25Parrot')) { echo "3BB273"; } else { echo "F6414B"; } ?>">P25Parrot</td>
  </tr>
  <tr>
    <td style="background: #<?php if (isProcessRunning('dstarrepeaterd')) { echo "3BB273"; } else { echo "F6414B"; } ?>">DStarRepeater</td>
    <td style="background: #<?php if (isProcessRunning('ircddbgatewayd')) { echo "3BB273"; } else { echo "F6414B"; } ?>">ircDDBGateway</td>
    <td style="background: #<?php if (isProcessRunning('timeserverd')) { echo "3BB273"; } else { echo "F6414B"; } ?>">TimeServer</td>
    <td style="background: #<?php if (isProcessRunning('/usr/local/sbin/pistar-watchdog',true)) { echo "3BB273"; } else { echo "F6414B"; } ?>">PiStar-Watchdog</td>
    <td style="background: #<?php if (isProcessRunning('/usr/local/sbin/pistar-remote',true)) { echo "3BB273"; } else { echo "F6414B"; } ?>">PiStar-Remote</td>
    <td style="background: #<?php if (isProcessRunning('/usr/local/sbin/pistar-keeper',true)) { echo "3BB273"; } else { echo "F6414B"; } ?>">PiStar-Keeper</td>
  </tr>
</table>
<br />
