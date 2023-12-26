<?php 
include_once dirname(dirname(__FILE__)).'/include/tools.php';
include_once dirname(dirname(__FILE__)).'/include/config.php';
include_once dirname(dirname(__FILE__)).'/include/functions.php';

$rawuptime = shell_exec('cat /proc/uptime');
$uptime = format_uptime(substr($rawuptime,0,strpos($rawuptime," ")));

$free_mem=shell_exec("free -m | awk 'NR==2{printf \"%.0f%%\", $3*100/$2 }'");
$disk_used=shell_exec("df -h | awk '\$NF==\"/\"{printf \"%s\",$5}'");

$cpuLoad = sys_getloadavg();
if (file_exists('/sys/class/thermal/thermal_zone0/temp')) {
$cpuTempCRaw = exec('cat /sys/class/thermal/thermal_zone0/temp');
if ($cpuTempCRaw !="") {
 if ($cpuTempCRaw > 1000) { $cpuTempC = round($cpuTempCRaw / 1000); } else { $cpuTempC = round($cpuTempCRaw); }
 $cpuTempF = round(+$cpuTempC * 9 / 5 + 32);
 if ($cpuTempC < 55) { $cpuTempHTML = "<td style=\"background: #1d1\">".$cpuTempC."&deg;C / ".$cpuTempF."&deg;F</td>\n"; }
 if ($cpuTempC >= 55) { $cpuTempHTML = "<td style=\"background: #fa0\">".$cpuTempC."&deg;C / ".$cpuTempF."&deg;F</td>\n"; }
 if ($cpuTempC >= 70) { $cpuTempHTML = "<td style=\"background: #f00\">".$cpuTempC."&deg;C / ".$cpuTempF."&deg;F</td>\n"; }
 } else { $cpuTempHTML = "<td style=\"background: #white\">---</td>\n"; }
} else { $cpuTempHTML = "<td style=\"background: #white\">---</td>\n"; }
?>
<fieldset style="box-shadow:0 0 5px #999;background-color:#e8e8e8e8;width:855px;margin-top:8px;;margin-bottom:8px;margin-left:6px;margin-right:0px;font-size:12px;border-top-left-radius: 5px; border-top-right-radius: 5px;border-bottom-left-radius: 5px; border-bottom-right-radius: 5px;">
<table style="margin-top:2px;">
    <tr><th style="padding-top:4px;padding-bottom:4px;">&nbsp;Modes&nbsp;</th>
    <?php showMode("DMR", $mmdvmconfigs);?><?php showMode("System Fusion", $mmdvmconfigs);?>
    <?php showMode("NXDN", $mmdvmconfigs);?><?php showMode("P25", $mmdvmconfigs);?>
    <?php showMode("D-Star", $mmdvmconfigs);?>
    <th style="padding-top:4px;padding-bottom:4px;">&nbsp;Networks&nbsp;</th>
  <?php showMode("DMR Network", $mmdvmconfigs);?><?php showMode("System Fusion Network", $mmdvmconfigs);?>
  <?php showMode("NXDN Network", $mmdvmconfigs);?><?php showMode("P25 Network", $mmdvmconfigs);?>
  <?php showMode("D-Star Network", $mmdvmconfigs);?></tr>
</table>
<!-- 
</fieldset>
<span style="font-weight: bold;font-size:13px;">Hardware Info</span>
<fieldset style="box-shadow:0 0 5px #999;background-color:#e8e8e8e8; width:855px;margin-top:8px;margin-left:6px;margin-right:0px;font-size:12px;border-top-left-radius: 5px; border-top-right-radius: 5px;border-bottom-left-radius: 5px; border-bottom-right-radius: 5px;">
<table style="margin-top:2px;">
  <tr>
    <th>Hostname<br/><span style="font-weight: bold;color:#effd5f;font-size:5px;">IP: <?php echo str_replace(' ', '<br />', exec("hostname -I | awk '{print $1}'"));?></span></th>
    <th><b>Kernel<br/>release</b></th>
    <th colspan="2">Platform <br><span style="font-weight: bold;color:#effd5f;font-size:12px;">Uptime: <?php echo $uptime; ?></span></th>
    <th><span>&nbsp;<b>Disk&nbsp;<br> used</b></span></th>
    <th><span>&nbsp;<b>Memory&nbsp;<br> used</b></span></th>
    <th><span><b>CPU Load</b></span></th>
<?php if (file_exists('/sys/class/thermal/thermal_zone0/temp')) {
    echo "<th><span><b>CPU Temp</b></span></th>"; }
?>
  </tr>
  <tr height="24px">
    <td><?php echo php_uname('n');?></td>
    <td><?php echo php_uname('r');?></td>
    <td colspan="2"><?php echo exec('/usr/local/sbin/platformDetect.sh');?></td>
    <td><?php echo $disk_used;?></td>
    <td><?php echo $free_mem;?></td>
    <td><?php echo round($cpuLoad[0],1);?> / <?php echo round($cpuLoad[1],1);?> / <?php echo round($cpuLoad[2],1);?></td>
   <?php if (file_exists('/sys/class/thermal/thermal_zone0/temp')) { echo $cpuTempHTML; } ?>
  </tr>
</table>
</fieldset>
<br> -->
