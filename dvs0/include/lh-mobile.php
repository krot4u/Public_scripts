<?php
include_once dirname(dirname(__FILE__)).'/include/config.php';
include_once dirname(dirname(__FILE__)).'/include/tools.php';
include_once dirname(dirname(__FILE__)).'/include/functions.php';
?>
<span style="font-weight: bold;font-size:14px;color: #FAFAFA;">Последняя Активность</span>
  <table style="margin-top:20px;font-size: 12px;">
    <tr>
      <th>Time (<?php echo date('T')?>)</th>
      <th>Callsign</th>
<?php
    if (DISPLAYNAME == "YES" && file_exists(DMRIDDATPATH."/DMRIds.dat") && ! empty(DMRIDDATPATH."/DMRIds.dat")) { echo "<th>Name</th>"; }
?>
      <th>Dur(s)</th>
      <th>Loss</th>
      <th>BER</th>
    </tr>
<?php
$i = 0;
for ($i = 0;  ($i <= 29); $i++) { //Last 20 calls
	if (isset($lastHeard[$i])) {
		$listElem = $lastHeard[$i];
		if ( $listElem[2] ) {
			$utc_time = $listElem[0];
                        $utc_tz =  new DateTimeZone('UTC');
                        date_default_timezone_set('Europe/Moscow');
                        $local_tz = new DateTimeZone(date_default_timezone_get());
                        $dt = new DateTime($utc_time, $utc_tz);
                        $dt->setTimeZone($local_tz);
                        $local_time = $dt->format('H:i:s M j');

		echo"<tr>";
		echo"<td align=\"left\">&nbsp;$local_time</td>";
		if ((is_numeric($listElem[2]) || strpos($listElem[2], "openSPOT") !== FALSE) && (strlen($listElem[2])==7)) {
		    echo "<td align=\"left\" width=\"100px\" style=\"color:#464646;\">&nbsp;<span style=\"color:#464646;\">$listElem[2]</span></a></td>";
		} elseif (!preg_match('/[A-Za-z].*[0-9]|[0-9].*[A-Za-z]/', $listElem[2])|| $listElem[2] == "N0CALL") {
 	                       echo "<td align=\"left\" style=\"color:#464646;\"><b>&nbsp;$listElem[2]</b></td>";
		} else {
		    if (strpos($listElem[2],"-") > 0) { $listElem[2] = substr($listElem[2], 0, strpos($listElem[2],"-")); }
        else {
			    echo "<td align=\"left\">&nbsp;<b>$listElem[2]</b></a></td>";
		    }
		}
		// Display NAME by DV8AWC
		if ( DISPLAYNAME == "YES" && file_exists(DMRIDDATPATH."/DMRIds.dat") && ! empty(DMRIDDATPATH."/DMRIds.dat")) {
		$arr2 = $listElem[2];
		if (is_numeric($arr2) || $arr2 == "FCS" || $arr2 == "MMDVM" || $arr2 == "P25"|| $arr2 == "N0CALL") {
			echo "<td align=\"left\" style=\"color:#464646;font-size: 10px;\">&nbsp;<b>&nbsp;</b></td>";
		} else {
			$pos = strpos($dmrIDline, $arr2." ");
			if ($pos != false) {
				$name = substr($dmrIDline, ($pos + strlen($arr2." ")));
				$name = ltrim($name, " ");
				$x = strpos($name, "\n");
				$y = strpos($name, " ");
				$name = rtrim($name, " ");
				if ($x < $y) {
					$name = substr($name, 0, $x);
					echo "<td align=\"left\" style=\"color:#464646;font-size: 10px;\">&nbsp;<b>".$name."</b></td>";
				} else {
					$name = substr($name, 0, $y);
					echo "<td align=\"left\" style=\"color:#464646;font-size: 10px;\">&nbsp;<b>".$name."</b></td>";
				}
			} else {
				echo "<td align=\"left\" style=\"color:#464646;font-size: 10px;\">&nbsp;<b>&nbsp;</b></td>";
			}
		    }
		}

		if ($listElem[6] == null) {
                             if ($listElem[1] == "DMR Slot 2" && $listElem[5] == "Net")  {echo "<td colspan=\"3\" style=\"background:#f93;\">&nbsp;&nbsp;&nbsp;RX DMR&nbsp;&nbsp;&nbsp;</td>";}
                             if ($listElem[1] == "DMR Slot 1" && $listElem[5] == "Net")  {echo "<td colspan=\"3\" style=\"background:#f93;\">&nbsp;&nbsp;&nbsp;RX DMR&nbsp;&nbsp;&nbsp;</td>";}
                             if ($listElem[1] == "YSF" && $listElem[5] == "Net")  {echo "<td colspan=\"3\" style=\"background:#ff9;\">&nbsp;&nbsp;&nbsp;RX YSF&nbsp;&nbsp;&nbsp;</td>";}
                             if ($listElem[1] == "P25" && $listElem[5] == "Net")  {echo "<td colspan=\"3\" style=\"background:#f9f;\">&nbsp;&nbsp;&nbsp;RX P25&nbsp;&nbsp;&nbsp;</td>";}
			     if ($listElem[1] == "NXDN" && $listElem[5] == "Net")  {echo "<td colspan=\"3\" style=\"background:#c9f;\">&nbsp;&nbsp;&nbsp;RX NXDN&nbsp;&nbsp;</td>";}
                             if ($listElem[1] == "D-Star" && $listElem[5] == "Net")  {echo "<td colspan=\"3\" style=\"background:#ade;\">&nbsp;&nbsp;&nbsp;RX D-Star</td>";}
                             if ($listElem[5] == "LNet")  {echo "<td colspan=\"3\" style=\"background:#f33;\">TX</td>";}
			} else if ($listElem[6] == "DMR Data") {
				echo "<td colspan=\"3\" style=\"background:#1d1;\">DMR Data</td>";
			} else if ($listElem[6] == "GPS") {
				echo "<td colspan=\"3\" style=\"background:#1d1;\"><a style=\"display:block;\" target=\"_blank\" href=https://www.openstreetmap.org/?mlat=".floatval($listElem[9])."&mlon=".floatval($listElem[10])."><b>GPS</b></a></td>";
			} else {
			echo "<td>$listElem[6]</td>";

			// Colour the Loss Field
			if (floatval($listElem[7]) < 1) { echo "<td>$listElem[7]</td>"; }
			elseif (floatval($listElem[7]) == 1) { echo "<td style=\"background:#1d1;\">$listElem[7]</td>"; }
			elseif (floatval($listElem[7]) > 1 && floatval($listElem[7]) <= 3) { echo "<td style=\"background:#fa0;\">$listElem[7]</td>"; }
			else { echo "<td style=\"background:#f33;color:#f9f9f9;\">$listElem[7]</td>"; }

			// Colour the BER Field
			if (floatval($listElem[8]) == 0) { echo "<td>$listElem[8]</td>"; }
			elseif (floatval($listElem[8]) >= 0.0 && floatval($listElem[8]) <= 1.9) { echo "<td style=\"background:#1d1;\">$listElem[8]</td>"; }
			elseif (floatval($listElem[8]) >= 2.0 && floatval($listElem[8]) <= 4.9) { echo "<td style=\"background:#fa0;\">$listElem[8]</td>"; }
			else { echo "<td style=\"background:#f33;color:#f9f9f9;\">$listElem[8]</td>"; }
		}
		echo"</tr>\n";
		}
	}
}

?>
  </table>