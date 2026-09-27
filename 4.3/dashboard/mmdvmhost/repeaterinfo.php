<?php
/**
 * Repeater information sidebar (MMDVMHost mode).
 *
 * The heaviest partial in the dashboard — refreshed every 1 second by
 * /index.php to give the operator a live view of:
 *   - "Modes Enabled" / "Net Status" — colour-coded grids painted via
 *     {@see showMode()} from mmdvmhost/functions.php; one cell per
 *     protocol covering D-Star, DMR, YSF, P25, NXDN, M17, FM, POCSAG
 *     plus cross-mode bridges (DMR2YSF, DMR2NXDN, YSF2DMR, YSF2NXDN,
 *     YSF2P25, "DMR XMode", "YSF XMode").
 *   - Current TRX state (idle / listening / RX / TX) with mode-aware
 *     colouring driven by {@see getActualMode()}.
 *   - TX/RX frequencies, modem firmware, modem TCXO frequency.
 *   - Per-protocol repeater info: D-Star module/IRC/APRS, DMR ID/CC
 *     /TS1/TS2/master, YSF host, P25 NAC, NXDN RAN, M17 settings,
 *     POCSAG frequency, DAPNET / APRS gateway state.
 *
 * Data sources: /etc/mmdvmhost (parsed INI), /etc/ircddbgateway (flat
 * key=value), /etc/{ysf,p25,nxdn,m17,dmr,dapnet,aprs,dgid,ysf2*}gateway,
 * /etc/dstar-radio.{mmdvmhost,dstarrepeater}, plus log tails for the
 * "currently linked to" cells.
 *
 * Heavy on log-parsing via mmdvmhost/functions.php helpers — see that
 * file for the underlying substr-offset parsers and example log lines.
 *
 * Includes a per-callsign aprspass() implementation (the standard
 * APRS-IS verification hash) used elsewhere via this file's include
 * chain.
 */

// AJAX-loaded partial (1 s polling cadence) — embeddable variant
// only. Omits the X-Frame-Options / frame-ancestors directives the
// parent already asserts; they apply to iframe ancestry, not XHR.
require_once($_SERVER['DOCUMENT_ROOT'] . '/config/security_headers.php');
setEmbeddableSecurityHeaders();

include_once $_SERVER['DOCUMENT_ROOT'].'/config/config.php';          // MMDVMDash Config
include_once $_SERVER['DOCUMENT_ROOT'].'/mmdvmhost/tools.php';        // MMDVMDash Tools
include_once $_SERVER['DOCUMENT_ROOT'].'/mmdvmhost/functions.php';    // MMDVMDash Functions
include_once $_SERVER['DOCUMENT_ROOT'].'/config/language.php';          // Translation Code

require_once($_SERVER['DOCUMENT_ROOT'].'/config/ircddblocal.php');

//Load the ircDDBGateway config file
$configs = array();
if ($configfile = fopen($gatewayConfigPath,'r')) {
        while ($line = fgets($configfile)) {
                list($key,$value) = preg_split('/=/',$line);
                $value = trim(str_replace('"','',$value));
                if ($key != 'ircddbPassword' && strlen($value) > 0)
                $configs[$key] = $value;
        }

}

//Load the DStarRepeater config file
$configdstar = array();
if ($configdstarfile = fopen('/etc/dstarrepeater','r')) {
        while ($line1 = fgets($configdstarfile)) {
        if (strpos($line1, '=') !== false) {
                    list($key1,$value1) = preg_split('/=/',$line1);
                    $value1 = trim(str_replace('"','',$value1));
                    if (strlen($value1) > 0)
                    $configdstar[$key1] = $value1;
        }
        }
}

//Load the dmrgateway config file
$dmrGatewayConfigFile = '/etc/dmrgateway';
if (fopen($dmrGatewayConfigFile,'r')) { $configdmrgateway = parse_ini_file($dmrGatewayConfigFile, true); }

//Load the dapnetgateway config file
$dapnetGatewayConfigFile = '/etc/dapnetgateway';
if (fopen($dapnetGatewayConfigFile,'r')) { $configdapnetgateway = parse_ini_file($dapnetGatewayConfigFile, true); }

// Load the ysf2dmr config file
if (file_exists('/etc/ysf2dmr')) {
    $ysf2dmrConfigFile = '/etc/ysf2dmr';
    if (fopen($ysf2dmrConfigFile,'r')) { $configysf2dmr = parse_ini_file($ysf2dmrConfigFile, true); }
}
// Load the ysf2nxdn config file
if (file_exists('/etc/ysf2nxdn')) {
    $ysf2nxdnConfigFile = '/etc/ysf2nxdn';
    if (fopen($ysf2nxdnConfigFile,'r')) { $configysf2nxdn = parse_ini_file($ysf2nxdnConfigFile, true); }
}
// Load the ysf2p25 config file
if (file_exists('/etc/ysf2p25')) {
    $ysf2p25ConfigFile = '/etc/ysf2p25';
    if (fopen($ysf2p25ConfigFile,'r')) { $configysf2p25 = parse_ini_file($ysf2p25ConfigFile, true); }
}
// Load the dmr2ysf config file
if (file_exists('/etc/dmr2ysf')) {
    $dmr2ysfConfigFile = '/etc/dmr2ysf';
    if (fopen($dmr2ysfConfigFile,'r')) { $configdmr2ysf = parse_ini_file($dmr2ysfConfigFile, true); }
}
// Load the dmr2nxdn config file
if (file_exists('/etc/dmr2nxdn')) {
    $dmr2nxdnConfigFile = '/etc/dmr2nxdn';
    if (fopen($dmr2nxdnConfigFile,'r')) { $configdmr2nxdn = parse_ini_file($dmr2nxdnConfigFile, true); }
}
?>

<table>
  <tr><th colspan="2"><?php echo $lang['modes_enabled'];?></th></tr>
  <tr><?php showMode("D-Star", $mmdvmconfigs);?><?php showMode("DMR", $mmdvmconfigs);?></tr>
  <tr><?php showMode("M17", $mmdvmconfigs);?><?php showMode("NXDN", $mmdvmconfigs);?></tr>
  <tr><?php showMode("P25", $mmdvmconfigs);?><?php showMode("System Fusion", $mmdvmconfigs);?></tr>
  <tr><?php showMode("DMR XMode", $mmdvmconfigs);?><?php showMode("YSF XMode", $mmdvmconfigs);?></tr>
  <tr><?php showMode("FM", $mmdvmconfigs);?><?php showMode("POCSAG", $mmdvmconfigs);?></tr>
</table>
<br />

<table>
  <tr><th colspan="2"><?php echo $lang['net_status'];?></th></tr>
  <tr><?php showMode("D-Star Network", $mmdvmconfigs);?><?php showMode("DMR Network", $mmdvmconfigs);?></tr>
  <tr><?php showMode("M17 Network", $mmdvmconfigs);?><?php showMode("NXDN Network", $mmdvmconfigs);?></tr>
  <tr><?php showMode("P25 Network", $mmdvmconfigs);?><?php showMode("System Fusion Network", $mmdvmconfigs);?></tr>
  <tr><?php showMode("DMR2NXDN Network", $mmdvmconfigs);?><?php showMode("DMR2YSF Network", $mmdvmconfigs);?></tr>
  <tr><?php showMode("YSF2DMR Network", $mmdvmconfigs);?><?php showMode("YSF2NXDN Network", $mmdvmconfigs);?></tr>
  <tr><?php showMode("YSF2P25 Network", $mmdvmconfigs);?><?php showMode("POCSAG Network", $mmdvmconfigs);?></tr>
</table>
<br />

<table>
<tr><th colspan="2"><?php echo $lang['radio_info'];?></th></tr>
<tr><th>Trx</th><?php
// TRX Status code
if (isset($lastHeard[0])) {
    $listElem = $lastHeard[0];
    if ( $listElem[2] && $listElem[6] == null && $listElem[5] !== 'RF') {
            // $listElem[1] is the parsed mode string from the
            // last-heard log line — RF-controllable, so escape
            // before interpolating into HTML. (Same source as
            // the lh.php / localtx.php fixes in #21.)
            echo "<td style=\"background:#F6414B;\">TX " . htmlspecialchars((string)$listElem[1], ENT_QUOTES, 'UTF-8') . "</td>";
            }
            else {
            if (getActualMode($lastHeard, $mmdvmconfigs) === 'idle') {
                    echo "<td style=\"background:#3BB273; color:#030;\">Listening</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === NULL) {
                    if (isProcessRunning("MMDVMHost")) { echo "<td style=\"background:#3BB273; color:#030;\">Listening</td>"; } else { echo "<td style=\"background:#3D4657; color:#b0b0b0;\">OFFLINE</td>"; }
                    }
            elseif ($listElem[2] && $listElem[6] == null && getActualMode($lastHeard, $mmdvmconfigs) === 'D-Star') {
                    echo "<td style=\"background:#4aa361;\">RX D-Star</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'D-Star') {
                    echo "<td style=\"background:#ade;\">Listening D-Star</td>";
                    }
            elseif ($listElem[2] && $listElem[6] == null && getActualMode($lastHeard, $mmdvmconfigs) === 'DMR') {
                    echo "<td style=\"background:#4aa361;\">RX DMR</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'DMR') {
                    echo "<td style=\"background:#f93;\">Listening DMR</td>";
                    }
            elseif ($listElem[2] && $listElem[6] == null && getActualMode($lastHeard, $mmdvmconfigs) === 'YSF') {
                    echo "<td style=\"background:#4aa361;\">RX YSF</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'YSF') {
                    echo "<td style=\"background:#ff9;\">Listening YSF</td>";
                    }
            elseif ($listElem[2] && $listElem[6] == null && getActualMode($lastHeard, $mmdvmconfigs) === 'P25') {
                    echo "<td style=\"background:#4aa361;\">RX P25</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'P25') {
                    echo "<td style=\"background:#f9f;\">Listening P25</td>";
                    }
        elseif ($listElem[2] && $listElem[6] == null && getActualMode($lastHeard, $mmdvmconfigs) === 'NXDN') {
                    echo "<td style=\"background:#4aa361;\">RX NXDN</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'NXDN') {
                    echo "<td style=\"background:#c9f;\">Listening NXDN</td>";
                    }
        elseif ($listElem[2] && $listElem[6] == null && getActualMode($lastHeard, $mmdvmconfigs) === 'M17') {
                    echo "<td style=\"background:#4aa361;\">RX M17</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'M17') {
                    echo "<td style=\"background:#f9f;\">Listening M17</td>";
                    }
        elseif ($listElem[2] && $listElem[6] == null && getActualMode($lastHeard, $mmdvmconfigs) === 'FM') {
                    echo "<td style=\"background:#4aa361;\">RX FM</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'FM') {
                    echo "<td style=\"background:#f9f;\">Listening FM</td>";
                    }
        elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'POCSAG') {
                    echo "<td style=\"background:#4aa361;\">POCSAG</td>";
                    }
            else {
                    // getActualMode() returns log-derived strings;
                    // escape before HTML interpolation.
                    echo "<td>" . htmlspecialchars((string)getActualMode($lastHeard, $mmdvmconfigs), ENT_QUOTES, 'UTF-8') . "</td>";
                    }
        }
    }
else {
    echo "<td></td>";
}
?></tr>
<tr><th>Tx</th><td style="background: #CACDCE;"><?php echo htmlspecialchars((string)getMHZ(getConfigItem("Info", "TXFrequency", $mmdvmconfigs)), ENT_QUOTES, 'UTF-8'); ?></td></tr>
<tr><th>Rx</th><td style="background: #CACDCE;"><?php echo htmlspecialchars((string)getMHZ(getConfigItem("Info", "RXFrequency", $mmdvmconfigs)), ENT_QUOTES, 'UTF-8'); ?></td></tr>
<?php
// Each of getDVModemFirmware()/getDVModemTCXOFreq() shells out to
// `grep ... | tail -1` over the entire MMDVM-YYYY-MM-DD.log file,
// which can be tens of MB late in a busy day. Capturing the
// return into a local before the truthiness test halves the per-
// request log-grep cost (was: one fork in the if(), one for the
// echo's value).
$fwVersion = getDVModemFirmware();
if ($fwVersion) {
echo '<tr><th>FW</th><td style="background: #CACDCE;">'.htmlspecialchars((string)$fwVersion, ENT_QUOTES, 'UTF-8').'</td></tr>'."\n";
} ?>
<?php
$tcxoFreq = getDVModemTCXOFreq();
if ($tcxoFreq) {
echo '<tr><th>TCXO</th><td style="background: #CACDCE;">'.htmlspecialchars((string)$tcxoFreq, ENT_QUOTES, 'UTF-8').'</td></tr>'."\n";
} ?>
</table>

<?php
$testMMDVModeDSTAR = getConfigItem("D-Star", "Enable", $mmdvmconfigs);
if ( $testMMDVModeDSTAR == 1 ) { //Hide the D-Star Reflector information when D-Star Network not enabled.
echo "<br />\n";
echo "<table>\n";
echo "<tr><th colspan=\"2\">".$lang['dstar_repeater']."</th></tr>\n";
// Config values from /etc/dstarrepeater and /etc/ircddbgateway
// — operator-controlled, but defensive escape before HTML
// interpolation. The legacy `&nbsp;` substitution stays but
// runs AFTER the htmlspecialchars so the entity isn't double-
// encoded.
echo "<tr><th>RPT1</th><td style=\"background: #CACDCE;\">".str_replace(' ', '&nbsp;', htmlspecialchars((string)$configdstar['callsign'], ENT_QUOTES, 'UTF-8'))."</td></tr>\n";
echo "<tr><th>RPT2</th><td style=\"background: #CACDCE;\">".str_replace(' ', '&nbsp;', htmlspecialchars((string)$configdstar['gateway'], ENT_QUOTES, 'UTF-8'))."</td></tr>\n";
echo "<tr><th colspan=\"2\">".$lang['dstar_net']."</th></tr>\n";
if ($configs['aprsEnabled']) {
    echo "<tr><th>APRS</th><td style=\"background: #CACDCE;\">".htmlspecialchars(substr((string)$configs['aprsHostname'], 0, 16), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
}
if ($configs['ircddbEnabled']) {
    echo "<tr><th>IRC</th><td style=\"background: #CACDCE;\">".htmlspecialchars(substr((string)$configs['ircddbHostname'], 0, 16), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
}
// getActualLink() returns log-parsed strings (DMR talkgroups,
// D-Star reflector names, NXDN/M17 link state etc.) which can
// carry RF-controllable bytes; escape before display.
echo "<tr><td colspan=\"2\" style=\"background: #CACDCE;\">".htmlspecialchars((string)getActualLink($reverseLogLinesMMDVM, "D-Star"), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
echo "</table>\n";
}

$testMMDVModeDMR = getConfigItem("DMR", "Enable", $mmdvmconfigs);
if ( $testMMDVModeDMR == 1 ) { //Hide the DMR information when DMR mode not enabled.
// DMR_Hosts.txt: read once via getDMRHostsLines() (functions.php) and
// cached for the request, so this scan and the YSF2DMR scan further
// down both iterate the same in-memory line array instead of two
// separate fopen/fgets passes over a 3-6K-line SD-card file.
$dmrMasterHost = getConfigItem("DMR Network", "Address", $mmdvmconfigs);
$dmrMasterPort = getConfigItem("DMR Network", "Port", $mmdvmconfigs);
if ($dmrMasterHost == '127.0.0.1') {
    if (isset($configdmrgateway['XLX Network 1']['Address'])) { $xlxMasterHost1 = $configdmrgateway['XLX Network 1']['Address']; }
    else { $xlxMasterHost1 = ""; }
    $dmrMasterHost1 = $configdmrgateway['DMR Network 1']['Address'];
    $dmrMasterHost2 = $configdmrgateway['DMR Network 2']['Address'];
    $dmrMasterHost3 = str_replace('_', ' ', $configdmrgateway['DMR Network 3']['Name']);
    if (isset($configdmrgateway['DMR Network 4']['Name'])) {$dmrMasterHost4 = str_replace('_', ' ', $configdmrgateway['DMR Network 4']['Name']);}
    if (isset($configdmrgateway['DMR Network 5']['Name'])) {$dmrMasterHost5 = str_replace('_', ' ', $configdmrgateway['DMR Network 5']['Name']);}
    if (isset($configdmrgateway['DMR Network 6']['Name'])) {$dmrMasterHost6 = str_replace('_', ' ', $configdmrgateway['DMR Network 6']['Name']);}
    foreach (getDMRHostsLines() as $dmrMasterLine) {
                $dmrMasterHostF = preg_split('/\s+/', $dmrMasterLine);
        if ((count($dmrMasterHostF) >= 2) && (strpos($dmrMasterHostF[0], '#') === FALSE) && ($dmrMasterHostF[0] != '')) {
            if ((strpos($dmrMasterHostF[0], 'XLX_') === 0) && ($xlxMasterHost1 == $dmrMasterHostF[2])) { $xlxMasterHost1 = str_replace('_', ' ', $dmrMasterHostF[0]); }
            if ((strpos($dmrMasterHostF[0], 'BM_') === 0) && ($dmrMasterHost1 == $dmrMasterHostF[2])) { $dmrMasterHost1 = str_replace('_', ' ', $dmrMasterHostF[0]); }
            if ((strpos($dmrMasterHostF[0], 'DMR+_') === 0) && ($dmrMasterHost2 == $dmrMasterHostF[2])) { $dmrMasterHost2 = str_replace('_', ' ', $dmrMasterHostF[0]); }
        }
    }
    if (strlen($xlxMasterHost1) > 19) { $xlxMasterHost1 = substr($xlxMasterHost1, 0, 17) . '..'; }
    if (strlen($dmrMasterHost1) > 19) { $dmrMasterHost1 = substr($dmrMasterHost1, 0, 17) . '..'; }
    if (strlen($dmrMasterHost2) > 19) { $dmrMasterHost2 = substr($dmrMasterHost2, 0, 17) . '..'; }
    if (strlen($dmrMasterHost3) > 19) { $dmrMasterHost3 = substr($dmrMasterHost3, 0, 17) . '..'; }
    if (isset($dmrMasterHost4)) { if (strlen($dmrMasterHost4) > 19) { $dmrMasterHost4 = substr($dmrMasterHost4, 0, 17) . '..'; } }
    if (isset($dmrMasterHost5)) { if (strlen($dmrMasterHost5) > 19) { $dmrMasterHost5 = substr($dmrMasterHost5, 0, 17) . '..'; } }
    if (isset($dmrMasterHost6)) { if (strlen($dmrMasterHost6) > 19) { $dmrMasterHost6 = substr($dmrMasterHost6, 0, 17) . '..'; } }
}
else {
    foreach (getDMRHostsLines() as $dmrMasterLine) {
                $dmrMasterHostF = preg_split('/\s+/', $dmrMasterLine);
        if ((count($dmrMasterHostF) >= 4) && (strpos($dmrMasterHostF[0], '#') === FALSE) && ($dmrMasterHostF[0] != '')) {
            if (($dmrMasterHost == $dmrMasterHostF[2]) && ($dmrMasterPort == $dmrMasterHostF[4])) { $dmrMasterHost = str_replace('_', ' ', $dmrMasterHostF[0]); }
        }
    }
    if (strlen($dmrMasterHost) > 19) { $dmrMasterHost = substr($dmrMasterHost, 0, 17) . '..'; }
}

echo "<br />\n";
echo "<table>\n";
echo "<tr><th colspan=\"2\">".$lang['dmr_repeater']."</th></tr>\n";
// All getConfigItem returns and $dmrMasterHost* values below
// originate from /etc/mmdvmhost or /etc/dmrgateway (parse_ini)
// or from log-parsed `exec(grep | awk)` pipelines. Escape every
// echoed value so an editor-injected payload (closes the read
// path of the M-3 stored XSS class) or a hostile log line can't
// break out of the table cell.
echo "<tr><th>DMR ID</th><td style=\"background: #CACDCE;\">".htmlspecialchars((string)getConfigItem("General", "Id", $mmdvmconfigs), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
echo "<tr><th>DMR CC</th><td style=\"background: #CACDCE;\">".htmlspecialchars((string)getConfigItem("DMR", "ColorCode", $mmdvmconfigs), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
echo "<tr><th>TS1</th>";
if (getConfigItem("DMR Network", "Slot1", $mmdvmconfigs) == 1) { echo "<td style=\"background:#3BB273;\">enabled</td></tr>\n"; } else { echo "<td style=\"background:#3D4657; color:#b0b0b0;\">disabled</td></tr>\n"; }
echo "<tr><th>TS2</th>";
if (getConfigItem("DMR Network", "Slot2", $mmdvmconfigs) == 1) { echo "<td style=\"background:#3BB273;\">enabled</td></tr>\n"; } else { echo "<td style=\"background:#3D4657; color:#b0b0b0;\">disabled</td></tr>\n"; }
echo "<tr><th colspan=\"2\">".$lang['dmr_master']."</th></tr>\n";
if (getEnabled("DMR Network", $mmdvmconfigs) == 1) {
        if ($dmrMasterHost == '127.0.0.1') {
            if ((isset($configdmrgateway['XLX Network 1']['Enabled'])) && ($configdmrgateway['XLX Network 1']['Enabled'] == 1)) {
                echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$xlxMasterHost1, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
            }
                        if ( !isset($configdmrgateway['XLX Network 1']['Enabled']) && isset($configdmrgateway['XLX Network']['Enabled']) && $configdmrgateway['XLX Network']['Enabled'] == 1) {
                if (file_exists("/var/log/pi-star/DMRGateway-".gmdate("Y-m-d").".log")) { $xlxMasterHost1 = exec('grep \'XLX, Linking\|XLX, Unlinking\|XLX, Logged\' /var/log/pi-star/DMRGateway-'.gmdate("Y-m-d").'.log | tail -1 | awk \'{print $5 " " $8 " " $9}\''); }
                                else { $xlxMasterHost1 = exec('grep \'XLX, Linking\|XLX, Unlinking\|XLX, Logged\' /var/log/pi-star/DMRGateway-'.gmdate("Y-m-d", time() - 86340).'.log | tail -1 | awk \'{print $5 " " $8 " " $9}\''); }
                if ( strpos($xlxMasterHost1, 'Linking') !== false ) { $xlxMasterHost1 = str_replace('Linking ', '', $xlxMasterHost1); }
                else if ( strpos($xlxMasterHost1, 'Unlinking') !== false ) { $xlxMasterHost1 = "XLX Not Linked"; }
                else if ( strpos($xlxMasterHost1, 'Logged') !== false ) { $xlxMasterHost1 = "XLX Not Linked"; }
                echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$xlxMasterHost1, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
                        }
            if ($configdmrgateway['DMR Network 1']['Enabled'] == 1) {
                echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$dmrMasterHost1, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
            }
            if ($configdmrgateway['DMR Network 2']['Enabled'] == 1) {
                echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$dmrMasterHost2, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
            }
            if ($configdmrgateway['DMR Network 3']['Enabled'] == 1) {
                echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$dmrMasterHost3, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
            }
            if (isset($configdmrgateway['DMR Network 4']['Enabled'])) {
                if ($configdmrgateway['DMR Network 4']['Enabled'] == 1) {
                    echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$dmrMasterHost4, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
                }
            }
            if (isset($configdmrgateway['DMR Network 5']['Enabled'])) {
                if ($configdmrgateway['DMR Network 5']['Enabled'] == 1) {
                    echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$dmrMasterHost5, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
                }
            }
            if (isset($configdmrgateway['DMR Network 6']['Enabled'])) {
                if ($configdmrgateway['DMR Network 6']['Enabled'] == 1) {
                    echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$dmrMasterHost6, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
                }
            }
        }
        else {
            echo "<tr><td  style=\"background: #CACDCE;\" colspan=\"2\">".htmlspecialchars((string)$dmrMasterHost, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
        }
    }
    else {
        echo "<tr><td colspan=\"2\" style=\"background:#3D4657; color:#b0b0b0;\">No DMR Network</td></tr>\n";
    }
echo "</table>\n";
}

$testMMDVModeYSF = getConfigItem("System Fusion Network", "Enable", $mmdvmconfigs);
if ( isset($configdmr2ysf['Enabled']['Enabled']) ) { $testDMR2YSF = $configdmr2ysf['Enabled']['Enabled']; }
if ( $testMMDVModeYSF == 1 || $testDMR2YSF ) { //Hide the YSF information when System Fusion Network mode not enabled.
        $ysfLinkedTo = getActualLink($reverseLogLinesYSFGateway, "YSF");
        if ($ysfLinkedTo == 'Not Linked' || $ysfLinkedTo == 'Service Not Started') {
                $ysfLinkedToTxt = $ysfLinkedTo;
        } else {
                $ysfHostFile = fopen("/usr/local/etc/YSFHosts.txt", "r");
                $ysfLinkedToTxt = "null";
                while (!feof($ysfHostFile)) {
                        $ysfHostFileLine = fgets($ysfHostFile);
                        $ysfRoomTxtLine = preg_split('/;/', $ysfHostFileLine);
                        if (empty($ysfRoomTxtLine[0]) || empty($ysfRoomTxtLine[1])) continue;
                        if (($ysfRoomTxtLine[0] == $ysfLinkedTo) || ($ysfRoomTxtLine[1] == $ysfLinkedTo)) {
                                $ysfLinkedToTxt = $ysfRoomTxtLine[1];
                                break;
                        }
                }
                if ($ysfLinkedToTxt != "null") { $ysfLinkedToTxt = $ysfLinkedToTxt; } else { $ysfLinkedToTxt = $ysfLinkedTo; }
                $ysfLinkedToTxt = str_replace('_', ' ', $ysfLinkedToTxt);
        }
        if (strlen($ysfLinkedToTxt) > 19) { $ysfLinkedToTxt = substr($ysfLinkedToTxt, 0, 17) . '..'; }
        echo "<br />\n";
        echo "<table>\n";
        echo "<tr><th colspan=\"2\">".$lang['ysf_net']."</th></tr>\n";
        echo "<tr><td colspan=\"2\"style=\"background: #CACDCE;\">".htmlspecialchars((string)$ysfLinkedToTxt, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
        echo "</table>\n";
}

if ( isset($configysf2dmr['Enabled']['Enabled']) ) { $testYSF2DMR = $configysf2dmr['Enabled']['Enabled']; }
if ( $testYSF2DMR ) { //Hide the YSF2DMR information when YSF2DMR Network mode not enabled.
        // Reuses the in-memory DMR_Hosts.txt line array cached by
        // getDMRHostsLines() — same data the DMR block above just
        // walked, no second SD-card read.
        $dmrMasterHost = $configysf2dmr['DMR Network']['Address'];
        foreach (getDMRHostsLines() as $dmrMasterLine) {
                $dmrMasterHostF = preg_split('/\s+/', $dmrMasterLine);
        if ((count($dmrMasterHostF) >= 2) && (strpos($dmrMasterHostF[0], '#') === FALSE) && ($dmrMasterHostF[0] != '')) {
                        if ($dmrMasterHost == $dmrMasterHostF[2]) { $dmrMasterHost = str_replace('_', ' ', $dmrMasterHostF[0]); }
                }
        }
        if (strlen($dmrMasterHost) > 19) { $dmrMasterHost = substr($dmrMasterHost, 0, 17) . '..'; }

        echo "<br />\n";
        echo "<table>\n";
        echo "<tr><th colspan=\"2\">YSF2DMR</th></tr>\n";
    echo "<tr><th>DMR ID</th><td style=\"background: #CACDCE;\">".htmlspecialchars((string)$configysf2dmr['DMR Network']['Id'], ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    echo "<tr><th colspan=\"2\">YSF2".$lang['dmr_master']."</th></tr>\n";
        echo "<tr><td colspan=\"2\"style=\"background: #CACDCE;\">".htmlspecialchars((string)$dmrMasterHost, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
        echo "</table>\n";
}

$testMMDVModeP25 = getConfigItem("P25 Network", "Enable", $mmdvmconfigs);
if ( isset($configysf2p25['Enabled']['Enabled']) ) { $testYSF2P25 = $configysf2p25['Enabled']['Enabled']; }
if ( $testMMDVModeP25 == 1 || $testYSF2P25 ) { //Hide the P25 information when P25 Network mode not enabled.
    echo "<br />\n";
    echo "<table>\n";
    if (getConfigItem("P25", "NAC", $mmdvmconfigs)) {
        echo "<tr><th colspan=\"2\">".$lang['p25_radio']."</th></tr>\n";
        echo "<tr><th style=\"width:70px\">NAC</th><td>".htmlspecialchars((string)getConfigItem("P25", "NAC", $mmdvmconfigs), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    } else {
        echo "<tr><th colspan=\"2\">".$lang['p25_radio']."</th></tr>\n";
        echo "<tr><th style=\"width:70px\">NAC</th><td>0</td></tr>\n";
    }
    echo "<tr><th colspan=\"2\">".$lang['p25_net']."</th></tr>\n";
    echo "<tr><td colspan=\"2\"style=\"background: #CACDCE;\">".htmlspecialchars((string)getActualLink($logLinesP25Gateway, "P25"), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    echo "</table>\n";
}

$testMMDVModeNXDN = getConfigItem("NXDN Network", "Enable", $mmdvmconfigs);
if ( isset($configysf2nxdn['Enabled']['Enabled']) ) { if ($configysf2nxdn['Enabled']['Enabled'] == 1) { $testYSF2NXDN = 1; } }
if ( isset($configdmr2nxdn['Enabled']['Enabled']) ) { if ($configdmr2nxdn['Enabled']['Enabled'] == 1) { $testDMR2NXDN = 1; } }
if ( $testMMDVModeNXDN == 1 || isset($testYSF2NXDN) || isset($testDMR2NXDN) ) { //Hide the NXDN information when NXDN Network mode not enabled.
    echo "<br />\n";
    echo "<table>\n";
    if (getConfigItem("NXDN", "RAN", $mmdvmconfigs)) {
        echo "<tr><th colspan=\"2\">".$lang['nxdn_radio']."</th></tr>\n";
        echo "<tr><th style=\"width:70px\">RAN</th><td>".htmlspecialchars((string)getConfigItem("NXDN", "RAN", $mmdvmconfigs), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    } else {
        echo "<tr><th colspan=\"2\">".$lang['nxdn_radio']."</th></tr>\n";
        echo "<tr><th style=\"width:70px\">RAN</th><td>0</td></tr>\n";
    }
    echo "<tr><th colspan=\"2\">".$lang['nxdn_net']."</th></tr>\n";
    if (file_exists('/etc/nxdngateway')) {
        echo "<tr><td colspan=\"2\"style=\"background: #CACDCE;\">".htmlspecialchars((string)getActualLink($logLinesNXDNGateway, "NXDN"), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    } else {
        echo "<tr><td colspan=\"2\"style=\"background: #CACDCE;\">TG 65000</td></tr>\n";
    }
    echo "</table>\n";
}

$testMMDVModeM17 = getConfigItem("M17 Network", "Enable", $mmdvmconfigs);
if ( $testMMDVModeM17 == 1 ) { //Hide the M17 information when P25 Network mode not enabled.
    echo "<br />\n";
    echo "<table>\n";
    if (getConfigItem("M17", "CAN", $mmdvmconfigs)) {
        echo "<tr><th colspan=\"2\">".$lang['m17_radio']."</th></tr>\n";
        echo "<tr><th style=\"width:70px\">CAN</th><td>".htmlspecialchars((string)getConfigItem("M17", "CAN", $mmdvmconfigs), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    } else {
        echo "<tr><th colspan=\"2\">".$lang['m17_radio']."</th></tr>\n";
        echo "<tr><th style=\"width:70px\">CAN</th><td>0</td></tr>\n";
    }
    echo "<tr><th colspan=\"2\">".$lang['m17_net']."</th></tr>\n";
    echo "<tr><td colspan=\"2\"style=\"background: #CACDCE;\">".htmlspecialchars((string)getActualLink($logLinesM17Gateway, "M17"), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    echo "</table>\n";
}

$testMMDVModePOCSAG = getConfigItem("POCSAG Network", "Enable", $mmdvmconfigs);
if ( $testMMDVModePOCSAG == 1 ) { //Hide the POCSAG information when POCSAG Network mode not enabled.
    echo "<br />\n";
    echo "<table>\n";
    echo "<tr><th colspan=\"2\">POCSAG</th></tr>\n";
    echo "<tr><th>Tx</th><td>".htmlspecialchars((string)getMHZ(getConfigItem("POCSAG", "Frequency", $mmdvmconfigs)), ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    if (isset($configdapnetgateway['DAPNET']['Address'])) {
        $dapnetGatewayRemoteAddr = $configdapnetgateway['DAPNET']['Address'];
        if (strlen($dapnetGatewayRemoteAddr) > 19) { $dapnetGatewayRemoteAddr = substr($dapnetGatewayRemoteAddr, 0, 17) . '..'; }
        echo "<tr><th colspan=\"2\">POCSAG Master</th></tr>\n";
        echo "<tr><td colspan=\"2\"style=\"background: #CACDCE;\">".htmlspecialchars((string)$dapnetGatewayRemoteAddr, ENT_QUOTES, 'UTF-8')."</td></tr>\n";
    }
    echo "</table>\n";
}
