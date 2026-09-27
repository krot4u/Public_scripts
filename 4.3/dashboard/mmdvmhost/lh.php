<?php
/**
 * Last-heard list (MMDVMHost mode) — last 20 unique transmissions across
 * every enabled mode (D-Star / DMR / YSF / P25 / NXDN / M17 / POCSAG).
 *
 * AJAX-loaded partial; refreshed every 1.5 seconds by /index.php in
 * MMDVMHost mode. Renders columns: time (UTC → local), mode, callsign,
 * target, source (RF / Net), duration, loss, BER. Callsign links use
 * the operator's chosen lookup service (RadioID or QRZ, from
 * /etc/pistar-css.ini's [Lookup] Service key) plus aprs.fi for D-Star
 * dPRS data.
 *
 * Data flow: relies on `$lastHeard` populated by mmdvmhost/functions.php
 * (which parses /var/log/pi-star/MMDVM-YYYY-MM-DD.log via shell
 * pipelines). This file just renders the array — see functions.php
 * for the parsing logic and log-line offset comments.
 */


require_once($_SERVER['DOCUMENT_ROOT'] . '/config/security_headers.php');
// AJAX-loaded partial; the parent page (index.php) sets the full
// security headers. setEmbeddableSecurityHeaders() ships the
// non-frame-related security headers without locking frame-
// ancestors, so the partial can be loaded into the parent via
// $.load(). Calling setSecurityHeaders() before this would emit
// X-Frame-Options + frame-ancestors 'self', which makes the
// embeddable variant a no-op (headers_sent() === true) — fixes
// the historical bug where the wrong variant won.
setEmbeddableSecurityHeaders();

include_once $_SERVER['DOCUMENT_ROOT'].'/config/config.php';          // MMDVMDash Config
include_once $_SERVER['DOCUMENT_ROOT'].'/mmdvmhost/tools.php';        // MMDVMDash Tools
include_once $_SERVER['DOCUMENT_ROOT'].'/mmdvmhost/functions.php';    // MMDVMDash Functions
include_once $_SERVER['DOCUMENT_ROOT'].'/config/language.php';          // Translation Code

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
<b><?php echo $lang['last_heard_list'];?></b>
  <table>
    <tr>
      <th><?php echo $lang['time'];?> (<?php echo date('T')?>)</th>
      <th><?php echo $lang['mode'];?></th>
      <th style="min-width:14ch"><?php echo $lang['callsign'];?></th>
      <th><?php echo $lang['target'];?></th>
      <th><?php echo $lang['src'];?></th>
      <th><?php echo $lang['dur'];?>(s)</th>
      <th><?php echo $lang['loss'];?></th>
      <th><?php echo $lang['ber'];?></th>
    </tr>
<?php
$i = 0;
for ($i = 0;  ($i <= 19); $i++) { //Last 20 calls
    if (isset($lastHeard[$i])) {
        $listElem = $lastHeard[$i];
        if ( $listElem[2] ) {
            $utc_time = $listElem[0];
                        $utc_tz =  new DateTimeZone('UTC');
                        $local_tz = new DateTimeZone(date_default_timezone_get ());
                        $dt = new DateTime($utc_time, $utc_tz);
                        $dt->setTimeZone($local_tz);
                        $local_time = $dt->format('H:i:s M jS');

        // Every value below comes from log-line parsing in
        // mmdvmhost/functions.php, which in turn parses log lines
        // produced by RF traffic. A station transmitting on RF
        // can put almost any byte sequence into the callsign or
        // target field; without escaping it lands in the
        // dashboard's HTML refresh every 1.5s. Normalise once
        // here so every echo below works on safe values.
        //
        //   $modeHtml      — "Slot 1" -> "TS1" cosmetic + escape
        //   $cs            — callsign (HTML-safe text)
        //   $csUrl         — callsign URL-encoded for href= path
        //   $csSuffix      — D-Star station ID after `/` (HTML-safe)
        //   $tgt           — target callsign / talkgroup (HTML-safe)
        //   $src           — source ("RF"/"Net"/etc.; HTML-safe)
        //   $dur, $loss, $ber — numeric; HTML-safe defensively.
        //
        // The downstream str_replace ' '->'&nbsp;' has to run
        // AFTER htmlspecialchars; the entity reference `&nbsp;`
        // is intentional raw HTML output, not data.
        $modeHtml = htmlspecialchars(str_replace('Slot ', 'TS', $listElem[1]), ENT_QUOTES, 'UTF-8');
        $cs       = htmlspecialchars((string)$listElem[2], ENT_QUOTES, 'UTF-8');
        $csUrl    = rawurlencode((string)$listElem[2]);
        $csSuffix = htmlspecialchars((string)$listElem[3], ENT_QUOTES, 'UTF-8');
        // Target normalisation: if it's a single character left-pad
        // it to 8 spaces (cosmetic, matches legacy layout). The
        // visible value is HTML-escaped, then spaces become
        // non-breaking-space entities AFTER the escape so the
        // entity isn't double-encoded.
        $tgtRaw   = (string)$listElem[4];
        if (strlen($tgtRaw) === 1) { $tgtRaw = str_pad($tgtRaw, 8, ' ', STR_PAD_LEFT); }
        $tgtHtml  = htmlspecialchars($tgtRaw, ENT_QUOTES, 'UTF-8');
        $src      = htmlspecialchars((string)$listElem[5], ENT_QUOTES, 'UTF-8');
        $dur      = htmlspecialchars((string)$listElem[6], ENT_QUOTES, 'UTF-8');
        $loss     = htmlspecialchars((string)(isset($listElem[7]) ? $listElem[7] : ''), ENT_QUOTES, 'UTF-8');
        $ber      = htmlspecialchars((string)(isset($listElem[8]) ? $listElem[8] : ''), ENT_QUOTES, 'UTF-8');

        echo "<tr>";
        echo "<td align=\"left\">$local_time</td>";
        echo "<td align=\"left\">$modeHtml</td>";
        if (is_numeric($listElem[2])) {
            if ($listElem[2] > 9999) { echo "<td align=\"left\"><a href=\"".$idLookupUrl.$csUrl."\" target=\"_blank\">$cs</a></td>"; }
            else { echo "<td align=\"left\">$cs</td>"; }
        } elseif (!preg_match('/[A-Za-z].*[0-9]|[0-9].*[A-Za-z]/', $listElem[2])) {
                        echo "<td align=\"left\">$cs</td>";
        } else {
            // Strip any "-suffix" before linking — re-derive the
            // url-encoded form from the trimmed value.
            $csTrim = (strpos($listElem[2], "-") > 0)
                      ? substr($listElem[2], 0, strpos($listElem[2], "-"))
                      : (string)$listElem[2];
            $csTrimHtml = htmlspecialchars($csTrim, ENT_QUOTES, 'UTF-8');
            $csTrimUrl  = rawurlencode($csTrim);
            if ( $listElem[3] && $listElem[3] != '    ' ) {
                echo "<td align=\"left\"><div style=\"float:left;\"><a href=\"".$callsignLookupUrl.$csTrimUrl."\" target=\"_blank\">$csTrimHtml</a>/$csSuffix</div> <div style=\"text-align:right;\">&#40;<a href=\"https://aprs.fi/#!call=".$csTrimUrl."*\" target=\"_blank\">GPS</a>&#41;</div></td>";
            } else {
                echo "<td align=\"left\"><div style=\"float:left;\"><a href=\"".$callsignLookupUrl.$csTrimUrl."\" target=\"_blank\">$csTrimHtml</a></div> <div style=\"text-align:right;\">&#40;<a href=\"https://aprs.fi/#!call=".$csTrimUrl."*\" target=\"_blank\">GPS</a>&#41;</div></td>";
            }
        }

        if ( substr($tgtRaw, 0, 6) === 'CQCQCQ' ) {
            echo "<td align=\"left\">$tgtHtml</td>";
        } else {
            echo "<td align=\"left\">".str_replace(' ', '&nbsp;', $tgtHtml)."</td>";
        }


        if ($listElem[5] == "RF"){
            echo "<td style=\"background:#3BB273;\">RF</td>";
        }else{
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
            echo "<td colspan =\"3\" style=\"background:#F6414B;\">TX " . $duration_string . " sec</td>";
        } else if ($listElem[6] == "DMR Data") {
            echo "<td colspan =\"3\" style=\"background:#3BB273;\">DMR Data</td>";
        } else if ($listElem[6] == "POCSAG Data") {
            echo "<td colspan =\"3\" style=\"background:#3BB273;\">POCSAG Data</td>";
        } else {
            echo "<td>$dur</td>";

            // Colour the Loss Field
            if (floatval($listElem[7]) < 1) { echo "<td>$loss</td>"; }
            elseif (floatval($listElem[7]) == 1) { echo "<td style=\"background:#3BB273;\">$loss</td>"; }
            elseif (floatval($listElem[7]) > 1 && floatval($listElem[7]) <= 3) { echo "<td style=\"background:#F6A641;\">$loss</td>"; }
            else { echo "<td style=\"background:#F6414B;\">$loss</td>"; }

            // Colour the BER Field
            if (floatval($listElem[8]) == 0) { echo "<td>$ber</td>"; }
            elseif (floatval($listElem[8]) >= 0.0 && floatval($listElem[8]) <= 1.9) { echo "<td style=\"background:#3BB273;\">$ber</td>"; }
            elseif (floatval($listElem[8]) >= 2.0 && floatval($listElem[8]) <= 4.9) { echo "<td style=\"background:#F6A641;\">$ber</td>"; }
            else { echo "<td style=\"background:#F6414B;\">$ber</td>"; }
        }
        echo "</tr>\n";
        }
    }
}

?>
  </table>



