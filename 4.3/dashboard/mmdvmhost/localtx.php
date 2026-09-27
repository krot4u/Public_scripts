<?php
/**
 * Local TX list (MMDVMHost mode) — recent locally-originated RF
 * transmissions across every enabled mode. The "what THIS hotspot has
 * been keying up" view; complements lh.php which shows network traffic
 * too.
 *
 * AJAX-loaded partial; refreshed every 1.5 seconds by /index.php in
 * MMDVMHost mode. Same column layout as lh.php (time / mode / callsign /
 * target / source / duration / loss / BER) but filters `$lastHeard` for
 * RF-source rows only.
 *
 * In-progress RF calls (no end-of-transmission yet) get a red-cell
 * highlight and an infinity duration symbol to flag the live state.
 *
 * Callsign links use the operator's chosen lookup service (RadioID or
 * QRZ from /etc/pistar-css.ini's [Lookup] Service key) plus aprs.fi
 * for D-Star dPRS.
 *
 * Data flow: relies on `$lastHeard` populated by mmdvmhost/functions.php.
 */


require_once($_SERVER['DOCUMENT_ROOT'] . '/config/security_headers.php');
// AJAX-loaded partial — embeddable variant only. See the note in
// mmdvmhost/lh.php for why the historical double-call was wrong.
setEmbeddableSecurityHeaders();

include_once $_SERVER['DOCUMENT_ROOT'].'/config/config.php';          // MMDVMDash Config
include_once $_SERVER['DOCUMENT_ROOT'].'/mmdvmhost/tools.php';        // MMDVMDash Tools
include_once $_SERVER['DOCUMENT_ROOT'].'/mmdvmhost/functions.php';    // MMDVMDash Functions
include_once $_SERVER['DOCUMENT_ROOT'].'/config/language.php';          // Translation Code
$localTXList = $lastHeard;

// Check if the config file exists
if (file_exists('/etc/pistar-css.ini')) {
    // Use the values from the file
    $piStarCssFile = '/etc/pistar-css.ini';
    if (fopen($piStarCssFile,'r')) { $piStarCss = parse_ini_file($piStarCssFile, true); }

    // Set the Values from the config file
    if (isset($piStarCss['Lookup']['Service'])) { $callsignLookupSvc = $piStarCss['Lookup']['Service']; }        // Lookup Service "QRZ" or "RadioID"
    else { $callsignLookupSvc = "RadioID"; }                                        // Set the default if its missing                                        // Set the default if its missing
} else {
    // Default values
    $callsignLookupSvc = "RadioID";
}

// Safety net
if (($callsignLookupSvc != "RadioID") && ($callsignLookupSvc != "QRZ")) { $callsignLookupSvc = "RadioID"; }

// Setup the URL(s)
$idLookupUrl = "https://database.radioid.net/database/view?id=";
if ($callsignLookupSvc == "RadioID") { $callsignLookupUrl = "https://database.radioid.net/database/view?callsign="; }
if ($callsignLookupSvc == "QRZ") { $callsignLookupUrl = "https://www.qrz.com/db/"; }

?>
<b><?php echo $lang['local_tx_list'];?></b>
  <table>
    <tr>
      <th><?php echo $lang['time'];?> (<?php echo date('T')?>)</th>
      <th><?php echo $lang['mode'];?></th>
      <th style="min-width:14ch"><?php echo $lang['callsign'];?></th>
      <th><?php echo $lang['target'];?></th>
      <th><?php echo $lang['src'];?></th>
      <th><?php echo $lang['dur'];?>(s)</th>
      <th style="min-width:5ch"><?php echo $lang['ber'];?></th>
      <th style="min-width:8ch">RSSI</th>
    </tr>
<?php
$counter = 0;
$i = 0;
$TXListLim = count($localTXList);
for ($i = 0; $i < $TXListLim; $i++) {
        $listElem = $localTXList[$i];
        if ($listElem[5] == "RF" && ($listElem[1] == "D-Star" || startsWith($listElem[1], "DMR") || $listElem[1] == "YSF" || $listElem[1]== "P25" || $listElem[1]== "NXDN" || $listElem[1]== "M17")) {
            if ($counter <= 19) { //last 20 calls
                $utc_time = $listElem[0];
                            $utc_tz =  new DateTimeZone('UTC');
                            $local_tz = new DateTimeZone(date_default_timezone_get ());
                            $dt = new DateTime($utc_time, $utc_tz);
                            $dt->setTimeZone($local_tz);
                            $local_time = $dt->format('H:i:s M jS');

            // Same normalisation pattern as mmdvmhost/lh.php — every
            // value below comes from log-line parsing of RF traffic
            // and could carry hostile bytes from a transmitting
            // station. See the note in lh.php for the rationale.
            $modeHtml = htmlspecialchars(str_replace('Slot ', 'TS', $listElem[1]), ENT_QUOTES, 'UTF-8');
            $cs       = htmlspecialchars((string)$listElem[2], ENT_QUOTES, 'UTF-8');
            $csUrl    = rawurlencode((string)$listElem[2]);
            $csSuffix = htmlspecialchars((string)$listElem[3], ENT_QUOTES, 'UTF-8');
            $tgtRaw   = (string)$listElem[4];
            if (strlen($tgtRaw) === 1) { $tgtRaw = str_pad($tgtRaw, 8, ' ', STR_PAD_LEFT); }
            $tgtHtml  = htmlspecialchars($tgtRaw, ENT_QUOTES, 'UTF-8');
            $src      = htmlspecialchars((string)$listElem[5], ENT_QUOTES, 'UTF-8');
            $dur      = htmlspecialchars((string)$listElem[6], ENT_QUOTES, 'UTF-8');
            $ber      = htmlspecialchars((string)(isset($listElem[8]) ? $listElem[8] : ''), ENT_QUOTES, 'UTF-8');
            $rssi     = htmlspecialchars((string)(isset($listElem[9]) ? $listElem[9] : ''), ENT_QUOTES, 'UTF-8');

            echo "<tr>";
            echo "<td align=\"left\">$local_time</td>";
            echo "<td align=\"left\">$modeHtml</td>";
            if (is_numeric($listElem[2])) {
                if ($listElem[2] > 9999) { echo "<td align=\"left\"><a href=\"".$idLookupUrl.$csUrl."\" target=\"_blank\">$cs</a></td>"; }
                else { echo "<td align=\"left\">$cs</td>"; }
            } elseif (!preg_match('/[A-Za-z].*[0-9]|[0-9].*[A-Za-z]/', $listElem[2])) {
                echo "<td align=\"left\">$cs</td>";
            } else {
                $csTrim = (strpos($listElem[2], "-") > 0)
                          ? substr($listElem[2], 0, strpos($listElem[2], "-"))
                          : (string)$listElem[2];
                $csTrimHtml = htmlspecialchars($csTrim, ENT_QUOTES, 'UTF-8');
                $csTrimUrl  = rawurlencode($csTrim);
                if ($listElem[3] && $listElem[3] != '    ' ) {
                    echo "<td align=\"left\"><div style=\"float:left;\"><a href=\"".$callsignLookupUrl.$csTrimUrl."\" target=\"_blank\">$csTrimHtml</a>/$csSuffix</div> <div style=\"text-align:right;\">&#40;<a href=\"https://aprs.fi/#!call=".$csTrimUrl."*\" target=\"_blank\">GPS</a>&#41;</div></td>";
                } else {
                    echo "<td align=\"left\"><div style=\"float:left;\"><a href=\"".$callsignLookupUrl.$csTrimUrl."\" target=\"_blank\">$csTrimHtml</a></div> <div style=\"text-align:right;\">&#40;<a href=\"https://aprs.fi/#!call=".$csTrimUrl."*\" target=\"_blank\">GPS</a>&#41;</div></td>";
                }
            }
            echo "<td align=\"left\">".str_replace(' ', '&nbsp;', $tgtHtml)."</td>";
            if ($listElem[5] == "RF"){
                echo "<td style=\"background:#3BB273;\">RF</td>";
            } else {
                echo "<td>$src</td>";
            }
            if ($listElem[6] == null) {
                // Live duration
                $utc_time = $listElem[0];
                $utc_tz =  new DateTimeZone('UTC');
                $now = new DateTime("now", $utc_tz);
                $dt = new DateTime($utc_time, $utc_tz);
                $duration = $now->getTimestamp() - $dt->getTimestamp();
                $duration_string = $duration<999 ? round($duration) . "+" : "&infin;";
                echo "<td colspan=\"3\" style=\"background:#F6414B;\">TX " . $duration_string . " sec</td>";
            } else if ($listElem[6] == "DMR Data") {
                echo "<td colspan=\"3\" style=\"background:#3BB273;\">DMR Data</td>";
            } else {
                echo "<td>$dur</td>"; //duration

                // Colour the BER Field
                if (floatval($listElem[8]) == 0) { echo "<td>$ber</td>"; }
                elseif (floatval($listElem[8]) >= 0.0 && floatval($listElem[8]) <= 1.9) { echo "<td style=\"background:#3BB273;\">$ber</td>"; }
                elseif (floatval($listElem[8]) >= 2.0 && floatval($listElem[8]) <= 4.9) { echo "<td style=\"background:#F6A641;\">$ber</td>"; }
                else { echo "<td style=\"background:#F6414B;\">$ber</td>"; }

                echo "<td>$rssi</td>"; //rssi
            }
            echo "</tr>\n";
            $counter++; }
        }
    }

?>
  </table>


