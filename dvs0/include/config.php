<?php
// Report all errors except E_NOTICE
error_reporting(E_ALL & ~E_NOTICE);

define("ABINFO","50333");
define("ABINFO","50333");
// Put remote Network or IP address from which want to see tooltip ABInfo
// IP address has mast /32 for netoworks use /24 etc
define("REMOTENET", "127.0.0.1/32");
// RX Monitor YES = enabled NO = disabled
define("RXMONITOR","YES");
// Display NAME on Dashboard YES = enable or NO =  disable
define("DISPLAYNAME","NO");
//
define("LOGPATH", "/var/log/mmdvm");
define("MMDVMLOGPREFIX", "MMDVM_Bridge");
define("MMDVMINIPATH", "/opt/MMDVM_Bridge");
define("MMDVMINIFILENAME", "MMDVM_Bridge.ini");
define("DMRIDDATPATH", "/var/lib/mmdvm");
define("YSFGATEWAYLOGPREFIX", "YSFGateway");
define("YSFGATEWAYINIPATH", "/opt/YSFGateway");
define("YSFGATEWAYINIFILENAME", "YSFGateway.ini");
define("P25GATEWAYLOGPREFIX", "P25Gateway");
define("P25GATEWAYINIPATH", "/opt/P25Gateway");
define("P25GATEWAYINIFILENAME", "P25Gateway.ini");
define("NXDNGATEWAYLOGPREFIX", "NXDNGateway");
define("NXDNGATEWAYINIPATH", "/opt/NXDNGateway");
define("NXDNGATEWAYINIFILENAME", "NXDNGateway.ini");
define("LINKLOGPATH", "/var/log/ircddbgateway");
define("IRCDDBGATEWAY", "ircddbgatewayd");
define("IRCDDBGATEWAYINIFILENAME", "/etc/ircddbgateway");

?>
