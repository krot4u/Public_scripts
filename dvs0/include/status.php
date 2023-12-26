<?php
include_once dirname(dirname(__FILE__)).'/include/config.php';
include_once dirname(dirname(__FILE__)).'/include/tools.php';
include_once dirname(dirname(__FILE__)).'/include/functions.php';
?>
<span style="font-weight: bold;font-size:14px;color: #FAFAFA;">Статус системы</span>
<link rel="stylesheet" type="text/css" media="screen and (min-device-width: 380px)" href="./css/css.php" />
<link rel="stylesheet" type="text/css" media="screen and (max-device-width: 379px)" href="./css/css-mini.php" />
<fieldset style="background-color:#e8e8e8e8;width:160px;margin-top:6px;;margin-bottom:0px;margin-left:0px;margin-right:3px;font-size:12px;border-top-left-radius: 5px; border-top-right-radius: 5px;border-bottom-left-radius: 5px; border-bottom-right-radius: 5px;">
<?php
$testMMDVModeDMR = getConfigItem("DMR", "Enable", $mmdvmconfigs);
if ( $testMMDVModeDMR == 1 ) { //Hide the DMR information when DMR mode not enabled.

$dmrMasterFile = fopen("/var/lib/mmdvm/DMR_Hosts.txt", "r");
$dmrMasterHost = getConfigItem("DMR Network", "Address", $mmdvmconfigs);
$dmrMasterPort = getConfigItem("DMR Network", "Port", $mmdvmconfigs);
if ($dmrMasterHost == '127.0.0.1' AND file_exists('/opt/DMRGateway/DMRGateway.ini')) {
    $dmrGatewayConfigFile = '/opt/DMRGateway/DMRGateway.ini';
    if (fopen($dmrGatewayConfigFile,'r')) { $configdmrgateway = parse_ini_file($dmrGatewayConfigFile, true); }
    if (isset($configdmrgateway['XLX Network 1']['Address'])) { $xlxMasterHost1 = $configdmrgateway['XLX Network 1']['Address']; }
    else { $xlxMasterHost1 = ""; }
    $dmrMasterHost1 = $configdmrgateway['DMR Network 1']['Address'];
    $dmrMasterHost2 = $configdmrgateway['DMR Network 2']['Address'];
    $dmrMasterHost3 = str_replace('_', ' ', $configdmrgateway['DMR Network 3']['Name']);
    if (isset($configdmrgateway['DMR Network 4']['Name'])) {$dmrMasterHost4 = str_replace('_', ' ', $configdmrgateway['DMR Network 4']['Name']);}
    if (isset($configdmrgateway['DMR Network 5']['Name'])) {$dmrMasterHost5 = str_replace('_', ' ', $configdmrgateway['DMR Network 5']['Name']);}
    while (!feof($dmrMasterFile)) {
	$dmrMasterLine = fgets($dmrMasterFile);
                $dmrMasterHostF = preg_split('/\s+/', $dmrMasterLine);
	if ((count($dmrMasterHostF) >= 2) && (strpos($dmrMasterHostF[0], '#') === FALSE) && ($dmrMasterHostF[0] != '')) {
	    if ((strpos($dmrMasterHostF[0], 'XLX_') === 0) && ($xlxMasterHost1 == $dmrMasterHostF[2])) { $xlxMasterHost1 = str_replace('_', ' ', $dmrMasterHostF[0]); }
	    if ((strpos($dmrMasterHostF[0], 'BM_') === 0) && ($dmrMasterHost1 == $dmrMasterHostF[2])) { $dmrMasterHost1 = str_replace('_', ' ', $dmrMasterHostF[0]); }
	    if ((strpos($dmrMasterHostF[0], 'DMR+_') === 0) && ($dmrMasterHost2 == $dmrMasterHostF[2])) { $dmrMasterHost2 = str_replace('_', ' ', $dmrMasterHostF[0]); }
	}
    }
    if (strlen($xlxMasterHost1) > 19) { $xlxMasterHost1 = substr($xlxMasterHost1, 0, 17) . '..'; }
   //if (strlen($dmrMasterHost1) > 19) { $dmrMasterHost1 = substr($dmrMasterHost1, 0, 17) . '..'; }
   //if (strlen($dmrMasterHost2) > 19) { $dmrMasterHost2 = substr($dmrMasterHost2, 0, 17) . '..'; }
   //if (strlen($dmrMasterHost3) > 19) { $dmrMasterHost3 = substr($dmrMasterHost3, 0, 17) . '..'; }
   //if (isset($dmrMasterHost4)) { if (strlen($dmrMasterHost4) > 19) { $dmrMasterHost4 = substr($dmrMasterHost4, 0, 17) . '..'; } }
   //if (isset($dmrMasterHost5)) { if (strlen($dmrMasterHost5) > 19) { $dmrMasterHost5 = substr($dmrMasterHost5, 0, 17) . '..'; } }
}
else {
    while (!feof($dmrMasterFile)) {
	$dmrMasterLine = fgets($dmrMasterFile);
                $dmrMasterHostF = preg_split('/\s+/', $dmrMasterLine);
	if ((count($dmrMasterHostF) >= 4) && (strpos($dmrMasterHostF[0], '#') === FALSE) && ($dmrMasterHostF[0] != '')) {
	    if (($dmrMasterHost == $dmrMasterHostF[2]) && ($dmrMasterPort == $dmrMasterHostF[4])) { $dmrMasterHost = str_replace('_', ' ', $dmrMasterHostF[0]); }
	}
    }
}
fclose($dmrMasterFile);

#$ip = isset($_SERVER['HTTP_CLIENT_IP'])?$_SERVER['HTTP_CLIENT_IP']:isset($_SERVER['HTTP_X_FORWARDED_FOR'])?$_SERVER['HTTP_X_FORWARDED_FOR']:$_SERVER['REMOTE_ADDR'];
$ip = ($_SERVER['HTTP_CLIENT_IP']?$_SERVER['HTTP_CLIENT_IP']:$_SERVER['HTTP_X_FORWARDED_FOR'])?$_SERVER['HTTP_X_FORWARDED_FOR']:$_SERVER['REMOTE_ADDR'];

$net1= cidr_match($ip,"192.168.0.0/16");
$net2= cidr_match($ip,"172.16.0.0/12");
$net3= cidr_match($ip,"127.0.0.0/8");
$net4= cidr_match($ip,"10.0.0.0/8");
$net5= cidr_match($ip,REMOTENET);
	
if (file_exists('/tmp/ABInfo_'.ABINFO.'.json')) {
    $abinfo = getABInfo('/tmp/ABInfo_'.ABINFO.'.json');
    echo "<table style=\"margin-top:4px;\">\n";
    echo "<tr><th colspan=\"2\">";
    if ($net1 == TRUE || $net2 == TRUE || $net3 == TRUE || $net4 == TRUE || $net5 == TRUE) {
    echo "<div class=\"tooltip\" style=\"font-size:12px;\">Analog Bridge Info<span class=\"tooltiptext\" style=\"font-size:11px;\">";
    echo "<br>&nbsp;decoderFallBack: ".$abinfo['use_fallback'];
    echo "<br>&nbsp;useEmulator: ".$abinfo['use_emulator'];
    echo "<br>&nbsp;Mute: ".$abinfo['mute'];
    echo "<br>&nbsp;[TLV]";
    echo "<br>&nbsp;&nbsp;&nbsp;address: ".$abinfo['tlv']['ip'];
    echo "<br>&nbsp;&nbsp;&nbsp;txPort: ".$abinfo['tlv']['tx_port'];
    echo "<br>&nbsp;&nbsp;&nbsp;rxPort: ".$abinfo['tlv']['rx_port'];
    echo "<br>&nbsp;&nbsp;&nbsp;ambeMode: ".$abinfo['tlv']['ambe_mode'];
    echo "<br>&nbsp;&nbsp;&nbsp;AMBE Size: ".$abinfo['tlv']['ambe_size'];
    echo "<br>&nbsp;[Digital]<br/>";
    echo "&nbsp;&nbsp;&nbsp;Callsign: ".$abinfo['digital']['call'];
    echo "<br>&nbsp;&nbsp;&nbsp;gatewayID: ".$abinfo['digital']['gw'];
    echo "<br>&nbsp;&nbsp;&nbsp;repeaterID: ".$abinfo['digital']['rpt'];
    echo "<br>&nbsp;&nbsp;&nbsp;txTG: ".$abinfo['digital']['tg'];
    if (strlen($abinfo['last_tune']) > 8) { $lasttune = "<br>&nbsp;&nbsp;&nbsp;&nbsp;".$abinfo['last_tune']; }
    else {$lasttune = $abinfo['last_tune'];}
    echo "<br>&nbsp;&nbsp;&nbsp;Last tune: ".$lasttune;
    echo "<br>&nbsp;&nbsp;&nbsp;txTS: ".$abinfo['digital']['ts'];
    echo "<br>&nbsp;&nbsp;&nbsp;colorCode: ".$abinfo['digital']['cc'];
    echo "<br>&nbsp;[USRP]<br/>";
    echo "&nbsp;&nbsp;&nbsp;address: ".$abinfo['usrp']['ip'];
    echo "<br>&nbsp;&nbsp;&nbsp;txPort: ".$abinfo['usrp']['tx_port'];
    echo "<br>&nbsp;&nbsp;&nbsp;rxPort: ".$abinfo['usrp']['rx_port'];
    echo "<br>&nbsp;&nbsp;&nbsp;Ping: ".$abinfo['usrp']['ping'];
    echo "<br>&nbsp;&nbsp;&nbsp;[To PCM]";;
    echo "<br>&nbsp;&nbsp;&nbsp;&nbsp;usrpA: ".$abinfo['usrp']['to_pcm']['shape']."&nbsp;";
    echo "<br>&nbsp;&nbsp;&nbsp;&nbsp;Gain: ".$abinfo['usrp']['to_pcm']['gain'];
    echo "<br>&nbsp;&nbsp;&nbsp;[To AMBE]";;
    echo "<br>&nbsp;&nbsp;&nbsp;&nbsp;tlvA: ".$abinfo['usrp']['to_ambe']['shape']."&nbsp;";
    echo "<br>&nbsp;&nbsp;&nbsp;&nbsp;Gain: ".$abinfo['usrp']['to_ambe']['gain'];
    echo "<br>&nbsp;[DV3000]<br/>";
    echo "&nbsp;&nbsp;&nbsp;address: ".$abinfo['dv3000']['ip'];
    echo "<br>&nbsp;&nbsp;&nbsp;rxPort: ".$abinfo['dv3000']['port'];
    echo "<br>&nbsp;&nbsp;&nbsp;Serial: ".$abinfo['dv3000']['use_serial'];
    echo "<br>&nbsp;[Analog Bridge]";
    echo "<br>&nbsp;&nbsp;&nbsp;Version: ".$abinfo['ab']['version'];
    echo "<br/></span></div></th></tr>\n";
    if (!preg_match('/[A-Za-z].*[0-9]|[0-9].*[A-Za-z]/',$abinfo['digital']['call'])) { $call="";
    } else { $call=$abinfo['digital']['call']; }
    echo "<tr><th width=50%>Callsign</th><td style=\"background: #f9f9f9f9;color:#b44010;font-weight: bold;\">".$call."</td></tr>\n";
    echo "<tr><th width=50%>GW ID</th><td style=\"background: #f9f9f9;\">".$abinfo['digital']['gw']."</td></tr>\n";
    echo "<tr><th width=50%>RPT ID</th><td style=\"background: #f9f9f9;\">".$abinfo['digital']['rpt']."</td></tr>\n";
    echo "<tr><th width=50%>Mode</th><td style=\"background: #f9f9f9;font-weight: bold;color:#b44010;\">".$abinfo['tlv']['ambe_mode']."</td></tr>\n";
    echo "<tr><th width=50%>Tx TG</th><td style=\"background: #f9f9f9;font-weight: bold;color:#ef7215;\">".$abinfo['digital']['tg']."</td></tr>\n";
    echo "<tr><th width=50%>AB ver</th><td style=\"background: #f9f9f9;\">".$abinfo['ab']['version']."</td></tr>\n";
    echo "</table>\n"; }
    else { echo "<span style=\"font-size:13px;\">Analog Bridge Info</span></th></tr>\n";
    if (!preg_match('/[A-Za-z].*[0-9]|[0-9].*[A-Za-z]/',$abinfo['digital']['call'])) { $call="";
    } else { $call=$abinfo['digital']['call']; }
    echo "<tr><th width=50%>Callsign</th><td style=\"background: #f9f9f9f9;color:#b44010;font-weight: bold;\">".$call."</td></tr>\n";
    echo "<tr><th width=50%>Mode</th><td style=\"background: #f9f9f9;font-weight: bold;color:#b44010;\">".$abinfo['tlv']['ambe_mode']."</td></tr>\n";
    echo "<tr><th width=50%>Tx TG</th><td style=\"background: #f9f9f9;font-weight: bold;color:#ef7215;\">".$abinfo['digital']['tg']."</td></tr>\n";
    echo "<tr><th width=50%>AB ver</th><td style=\"background: #f9f9f9;\">".$abinfo['ab']['version']."</td></tr>\n";
    echo "</table>\n"; }
}


// TRX Status code
echo '<br><table><tr><th colspan="2">TRX Info</th></tr><tr>';
if (isProcessRunning("MMDVM_Bridge")) {
if (isset($lastHeard[0])) {
    $listElem = $lastHeard[0];
    if ( $listElem[2] && $listElem[6] == null && $listElem[5] == 'LNet') {
            echo "<td style=\"background:#f33;\">TX $listElem[1]</td>";
            }
            else {
            if (getActualMode($lastHeard, $mmdvmconfigs) === 'idle') {
                    echo "<td style=\"background:#0b0; color:#030;\">Listening</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === NULL) {
                    if (isProcessRunning("MMDVM_Bridge")) { echo "<td style=\"background:#0b0; color:#030;\">Listening</td>"; 
		} else { echo "<td style=\"background:#ffffed; color:#b0b0b0;font-weight: bold\">OFFLINE</td>"; }
                    }
            elseif ($listElem[2] && $listElem[6] == null && $abinfo['tlv']['ambe_mode']== "DSTAR" && getActualMode($lastHeard, $mmdvmconfigs) === 'D-Star') {
                    echo "<td style=\"background:#4aa361;\">RX D-Star</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'D-Star') {
                    echo "<td style=\"background:#ade;\">Listening D-Star</td>";
                    }
            elseif ($listElem[2] && $listElem[6] == null && $abinfo['tlv']['ambe_mode']== "DMR" && getActualMode($lastHeard, $mmdvmconfigs) === 'DMR') {
                    echo "<td style=\"background:#4aa361;\">RX DMR</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'DMR') {
                    echo "<td style=\"background:#f93;\">Listening DMR</td>";
                    }
            elseif ($listElem[2] && $listElem[6] == null && ($abinfo['tlv']['ambe_mode']== "YSFN" || $abinfo['tlv']['ambe_mode']== "YSFW") && getActualMode($lastHeard, $mmdvmconfigs) === 'YSF') {
                    echo "<td style=\"background:#4aa361;\">RX YSF</td>";
                    }
            elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'YSF') {
                    echo "<td style=\"background:#ff9;\">Listening YSF</td>";
                    }
            elseif ($listElem[2] && $listElem[6] == null && $abinfo['tlv']['ambe_mode']== "P25" && getActualMode($lastHeard, $mmdvmconfigs) === 'P25') {
    	        echo "<td style=\"background:#4aa361;\">RX P25</td>";
    	        }
    	elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'P25') {
    	        echo "<td style=\"background:#f9f;\">Listening P25</td>";
    	        }
	elseif ($listElem[2] && $listElem[6] == null && $abinfo['tlv']['ambe_mode']== "NXDN" && getActualMode($lastHeard, $mmdvmconfigs) === 'NXDN') {
    	        echo "<td style=\"background:#4aa361;\">RX NXDN</td>";
    	        }
    	elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'NXDN') {
    	        echo "<td style=\"background:#c9f;\">Listening NXDN</td>";
    	        }
	elseif (getActualMode($lastHeard, $mmdvmconfigs) === 'POCSAG') {
    	        echo "<td style=\"background:#4aa361;\">POCSAG</td>";
    	        }
    	else {
    	        echo "<td>".getActualMode($lastHeard, $mmdvmconfigs)."</td>";
    	        }
	}
    }
 else { echo "<td></td>";}
} else { echo "<td style=\"background:#ffffed; color:#b0b0b0;font-weight: bold\">OFFLINE</td>"; }
echo "</tr></table>\n";
echo "<br />\n";
echo "<table>\n";;
echo "<tr><th colspan=\"2\">DMR Master</th></tr>\n";
if (getEnabled("DMR Network", $mmdvmconfigs) == 0) {
	if ($dmrMasterHost == '127.0.0.1' && isProcessRunning("DMRGateway")) {
	    if ((isset($configdmrgateway['XLX Network 1']['Enabled'])) && ($configdmrgateway['XLX Network 1']['Enabled'] == 1)) {
		echo "<tr><td  style=\"background: #ffffed;\" colspan=\"2\"><span style=\"color:#b5651d;font-weight: bold\">".$xlxMasterHost1."</span></td></tr>\n";
	    }
                if ( !isset($configdmrgateway['XLX Network 1']['Enabled']) && isset($configdmrgateway['XLX Network']['Enabled']) && $configdmrgateway['XLX Network']['Enabled'] == 1) {
		if (file_exists("/var/log/mmdvm/DMRGateway-".gmdate("Y-m-d").".log")) { $xlxMasterHost1 = exec('grep -a \'XLX, Linking\|Unlinking\' /var/log/mmdvm/DMRGateway-'.gmdate("Y-m-d").'.log | tail -1 | awk \'{print $5 " " $8 " " $9}\''); 
		} else { $xlxMasterHost1 = exec('grep -a \'XLX, Linking\|Unlinking\' /var/log/mmdvm/DMRGateway-'.gmdate("Y-m-d", time() - 86340).'.log | tail -1 | awk \'{print $5 " " $8 " " $9}\''); }
		if ( strpos($xlxMasterHost1, 'Linking') !== false ) { $xlxMasterHost1 = str_replace('Linking ', '', $xlxMasterHost1); }
		else if ( strpos($xlxMasterHost1, 'Unlinking') !== false ) { $xlxMasterHost1 = "XLX Not Linked"; }
		echo "<tr><td  style=\"background: #ffffed;\" colspan=\"2\"><span style=\"color:#b5651d;font-weight: bold\">".$xlxMasterHost1."</span></td></tr>\n";
                        }
	    if ($configdmrgateway['DMR Network 1']['Enabled'] == 1) {
		$dmrMasterhost1 = str_replace(' ', '_', $dmrMasterHost1);
                echo getDMRGstat($dmrMasterhost1);
	    }
	    if ($configdmrgateway['DMR Network 2']['Enabled'] == 1) {
		$dmrMasterhost2 = str_replace(' ', '_', $dmrMasterHost2);
                echo getDMRGstat($dmrMasterhost2);
	    }
	    if ($configdmrgateway['DMR Network 3']['Enabled'] == 1) {
		$dmrMasterhost3 = str_replace(' ', '_', $dmrMasterHost3);
                echo getDMRGstat($dmrMasterhost3);
	    }
	    if (isset($configdmrgateway['DMR Network 4']['Enabled'])) {
		if ($configdmrgateway['DMR Network 4']['Enabled'] == 1) {
		$dmrMasterhost4 = str_replace(' ', '_', $dmrMasterHost4);
                echo getDMRGstat($dmrMasterhost4);
	    }
	    if (isset($configdmrgateway['DMR Network 5']['Enabled'])) {
		if ($configdmrgateway['DMR Network 5']['Enabled'] == 1) {
		$dmrMasterhost5 = str_replace(' ', '_', $dmrMasterHost5);
                echo getDMRGstat($dmrMasterhost5);
		}
	      }
	    }
	} 	
	elseif (isProcessRunning("MMDVM_Bridge")) {
		if (file_exists("/var/log/mmdvm/MMDVM_Bridge-".gmdate("Y-m-d").".log")) { $dmrstat = exec('grep -a \'DMR, Logged\|DMR, Closing DMR\|DMR, Opening DMR\|DMR, Connection\' /var/log/mmdvm/MMDVM_Bridge-'.gmdate("Y-m-d").'.log | tail -1 | awk \'{print $5 " " $10}\'');
		} else {$dmrstat = exec('grep -a \'DMR, Logged\|DMR, Closing DMR\|DMR, Opening DMR\|DMR, Connection\' /var/log/mmdvm/MMDVM_Bridge-'.gmdate("Y-m-d", time() - 86340).'.log | tail -1 | awk \'{print $5 " " $10}\''); }
                 if (($dmrstat !="") && (strpos($dmrstat, ':') !== false) ) { 
		    $dmrMasterHost = trim(substr($dmrstat,7,strpos($dmrstat,':')-strlen(trim(substr($dmrstat, strpos($dmrstat,':')-1)))));
		  $dmrMasterPort=trim(substr($dmrstat,strpos($dmrstat,":")+1));
		    $dmrMasterFile = fopen("/var/lib/mmdvm/DMR_Hosts.txt", "r");
		    while (!feof($dmrMasterFile)) {
			$dmrMasterLine = fgets($dmrMasterFile);
            		$dmrMasterHostF = preg_split('/\s+/', $dmrMasterLine);
			if ((count($dmrMasterHostF) >= 4) && (strpos($dmrMasterHostF[0], '#') === FALSE) && ($dmrMasterHostF[0] != '')) {
			if (($dmrMasterHost == $dmrMasterHostF[2]) && ($dmrMasterPort == $dmrMasterHostF[4])) { $dmrMasterHost = str_replace('_', ' ', $dmrMasterHostF[0]); }
				}
			    }
			fclose($dmrMasterFile);
		} 
		$dmrMasterHost = str_replace('_', ' ', $dmrMasterHost);
    		if (strlen($dmrMasterHost) > 19) { $dmrMasterHost = substr($dmrMasterHost, 0, 17) . '..'; }
		if ( strpos($dmrstat, 'Logged') !== false ) {
                        echo "<tr><td  style=\"background: #ffffed;\" colspan=\"2\"><span style=\"color:#b5651d;font-weight: bold\">".$dmrMasterHost."</span></td></tr>\n";}
		else if (strpos($dmrstat, 'Opening') !== false || strpos($dmrstatus, 'Closing') !== false || strpos($dmrstatus, 'Connection') !== false) { 
			echo "<tr><td  style=\"background: #ffffed;\" colspan=\"2\"><span style=\"color:#b0b0b0;font-weight: bold\">Not Connected</span></td></tr>\n"; }
		}
    else {
	    echo "<tr><td colspan=\"2\" style=\"background:#0b0; color:#030;font-weight: bold\"><b>Qra-Team-Master</b></td></tr>\n";
        }
    }
    else {
	    echo "<tr><td colspan=\"2\" style=\"background:#0b0; color:#030;font-weight: bold\"><b>Qra-Team-Master</b></td></tr>\n";
    }
echo "</table>\n";
}
$testMMDVModeYSF = getConfigItem("System Fusion Network", "Enable", $mmdvmconfigs);
if ( $testMMDVModeYSF == 1 ) { //Hide the YSF information when System Fusion Network mode not enabled.
        $ysfLinkedTo = getActualLink($reverseLogLinesYSFGateway, "YSF");
        if ($ysfLinkedTo == 'Not Linked' || $ysfLinkedTo == 'No YSF Network') {
                $ysfLinkedToTxt = '<span style="color:#b0b0b0;"><b>'.$ysfLinkedTo.'</b></span>';
        } else {
                $ysfHostFile = fopen("/var/lib/mmdvm/YSFHosts.txt", "r");
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
                if ($ysfLinkedToTxt != "null") { 
	    if (strlen($ysfLinkedToTxt) > 20) { $ysfLinkedToTxt = substr($ysfLinkedToTxt, 0, 18) . '..'; }
	    $ysfLinkedToTxt = "Room<br/><span style=\"color:#b5651d;font-weight: bold;\">".$ysfLinkedToTxt."</span>"; 
	} else { 
	    if (strlen($ysfLinkedTo) > 20) { $ysfLinkedToTxt = substr($ysfLinkedTo, 0, 18) . '..'; }
	    $ysfLinkedToTxt = "Linked to<br/><span style=\"color:#b5651d;font-weight: bold\">".$ysfLinkedTo."</span>"; 
	}
	    $ysfLinkedToTxt = str_replace('_', ' ', $ysfLinkedToTxt);
        }
        echo "<br />\n";
        echo "<table>\n";
        echo "<tr><th colspan=\"2\">YSF Net</th></tr>\n";
        echo "<tr><td colspan=\"2\" style=\"background: #ffffed;\">".$ysfLinkedToTxt."</td></tr>\n";
        echo "</table>\n";
}
$testMMDVModeP25 = getConfigItem("P25 Network", "Enable", $mmdvmconfigs);
if ( $testMMDVModeP25 == 1 ) { //Hide the P25 information when P25 Network mode not enabled.
    echo "<br />\n";
    echo "<table>\n";
    echo "<tr><th colspan=\"2\">P25 Net</th></tr>\n";
    echo "<tr><td colspan=\"2\" style=\"background: #ffffed;\">".getActualLink($logLinesP25Gateway, "P25")."</td></tr>\n";
    echo "</table>\n";
}

$testMMDVModeNXDN = getConfigItem("NXDN Network", "Enable", $mmdvmconfigs);
if ( $testMMDVModeNXDN == 1 ) { //Hide the NXDN information when NXDN Network mode not enabled.
    echo "<br />\n";
    echo "<table>\n";
    echo "<tr><th colspan=\"2\">NXDN Net</th></tr>\n";
    if (file_exists('/opt/NXDNGateway/NXDNGateway.ini')) {
	echo "<tr><td colspan=\"2\" style=\"background: #ffffed;\">".getActualLink($logLinesNXDNGateway, "NXDN")."</td></tr>\n";
    } else {
	echo "<tr><td colspan=\"2\" style=\"background: #ffffff;\">Linked to <span style=\"color:#b5651d;font-weight: bold;\">TG65000</span></td></tr>\n";
    }
    echo "</table>\n";
}
$testMMDVModeDSTAR = getConfigItem("D-Star Network", "Enable", $mmdvmconfigs);
if ( $testMMDVModeDSTAR == 1 ) { //Hide the D-Star Reflector information when D-Star Network not enabled.
//Load the ircDDBGateway config file
$configs = array();
if ($configfile = fopen('/etc/ircddbgateway','r')) {
        while ($line = fgets($configfile)) {
                list($key,$value) = preg_split('/=/',$line);
                $value = trim(str_replace('"','',$value));
                if ($key != 'ircddbPassword' && strlen($value) > 0)
                $configs[$key] = $value;
        }
}
    echo "<br />\n";
    echo "<table>\n";
    echo "<tr><th colspan=\"2\">D-Star Net</th></tr>\n";
    if (isProcessRunning("ircddbgatewayd")) { echo "<tr><th width=\"20%\">IRC</th><td style=\"background: #ffffff;color:brown;\">".substr($configs['ircddbHostname'], 0 ,16)."</td></tr>\n";}
    echo "<tr><td colspan=\"2\" style=\"background: #ffffed;\">".getActualLink($reverseLogLinesMMDVM, "D-Star")."</td></tr>\n";
    echo "</table>\n";
}

?>
</fieldset>
