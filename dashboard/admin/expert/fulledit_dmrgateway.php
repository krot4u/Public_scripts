<?php
// Load the language support
require_once('../config/language.php');
//Load the Pi-Star Release file
$pistarReleaseConfig = '/etc/pistar-release';
$configPistarRelease = array();
$configPistarRelease = parse_ini_file($pistarReleaseConfig, true);
//Load the Version Info
require_once('../config/version.php');
?>
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" lang="en">
  <head>
    <meta name="robots" content="index" />
    <meta name="robots" content="follow" />
    <meta name="language" content="English" />
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    <meta name="Author" content="Andrew Taylor (MW0MWZ)" />
    <meta name="Description" content="Pi-Star Expert Editor" />
    <meta name="KeyWords" content="Pi-Star" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="pragma" content="no-cache" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon">
    <meta http-equiv="Expires" content="0" />
    <title>Pi-Star - Digital Voice Dashboard - Expert Editor</title>
    <link rel="stylesheet" type="text/css" href="../css/pistar-css.php" />
  </head>
  <body>
  <div class="container">
  <?php include './header-menu.inc'; ?>
  <div class="contentwide">
  <?php
// A3-3 / L-5 — stage via tempnam + install (sudoers rejects /usr/bin/cp to /etc).
$filepath = tempnam('/tmp', 'pistar-edit-');
register_shutdown_function(function() use ($filepath) { @unlink($filepath); });
exec('sudo cp /etc/dmrgateway ' . escapeshellarg($filepath));
exec('sudo chown www-data:www-data ' . escapeshellarg($filepath));

if(isset($_POST['data'])) {
        $fh = fopen($filepath, 'w');
        fwrite($fh, $_POST['data']);
        fclose($fh);
        exec('sudo mount -o remount,rw /');
        exec('sudo install -m 644 -o root -g root '
             . escapeshellarg($filepath) . ' /etc/dmrgateway');
        exec('sudo mount -o remount,ro /');

	exec('sudo systemctl restart mmdvmhost.service');
	exec('sudo systemctl restart dmrgateway.service');

        $fh = fopen($filepath, 'r');
        $theData = fread($fh, filesize($filepath));

} else {
        $fh = fopen($filepath, 'r');
        $theData = fread($fh, filesize($filepath));
}
fclose($fh);

?>
<form name="test" method="post" action="">
<textarea name="data" cols="80" rows="45"><?php echo $theData; ?></textarea><br />
<input type="submit" name="submit" value="<?php echo $lang['apply']; ?>" />
</form>

</div>

<div class="footer">
<a style="color: #47D4D4;" href="https://help.qra-team.online/" target="_new">&copy; QRA-Team Help</a><br />
XLX Server <a style="color: #47D4D4;" href="https://qra-team.online/" target="_new">Dashboard</a>.<br />
<a style="color: #47D4D4;" href="https://qra-team.ru" target="_new">QRA-Team.Ru</a>.<br />
&copy; Andy Taylor (MW0MWZ) 2014-<?php echo date("Y"); ?>.<br />
</div>

</div>
</body>
</html>
