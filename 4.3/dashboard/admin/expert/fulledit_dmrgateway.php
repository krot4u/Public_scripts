<?php
/**
 * Raw text editor for /etc/dmrgateway.
 *
 * Companion to edit_dmrgateway.php — same target file, but this view
 * exposes the entire INI as a single textarea so the operator can
 * make edits the structured form doesn't cover. POST data is staged
 * to /tmp/<obfuscated>.tmp then sudo-copied back to /etc/dmrgateway.
 * Restarts BOTH mmdvmhost.service AND dmrgateway.service after save.
 */
require_once($_SERVER['DOCUMENT_ROOT'].'/config/security_headers.php');
require_once($_SERVER['DOCUMENT_ROOT'].'/config/csrf.php');
require_once($_SERVER['DOCUMENT_ROOT'].'/config/banner_warnings.inc');
setSecurityHeaders();

// CSRF protection — see config/csrf.php for the full rationale.
// Must run BEFORE any output: bootstraps the session on GET (so
// Set-Cookie ships) and rejects forged POSTs cleanly with 403
// before any state change (sed-i, fopen+fwrite, sudo cp, etc.).
csrf_verify();

// Layer 2 of the default-password protection — see config/banner_warnings.inc.
// MUST run BEFORE any output so header('Location: ...') works.
pistar_warnings_enforce_redirect();

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
  <?php pistar_warnings_render(); ?>
  <div class="container">
  <?php include './header-menu.inc'; ?>
  <div class="contentwide">
  <?php
// A3-3 — see edit_ircddbgateway.php for the full TOCTOU rationale.
$filepath = tempnam('/tmp', 'pistar-edit-');
register_shutdown_function(function() use ($filepath) { @unlink($filepath); });
exec('sudo cp /etc/dmrgateway ' . escapeshellarg($filepath));
exec('sudo chown www-data:www-data ' . escapeshellarg($filepath));
exec('sudo chmod 600 ' . escapeshellarg($filepath));

if(isset($_POST['data'])) {
        // Write submitted data into the staging file.
        $fh = fopen($filepath, 'w');
        fwrite($fh, $_POST['data']);
        fclose($fh);
        // L-5: atomic install replaces the prior cp + chmod + chown
        // triplet (rejected by the tightened sudoers — see
        // edit_mmdvmhost.php for the full rationale).
        exec('sudo mount -o remount,rw /');
        exec('sudo install -m 644 -o root -g root '
             . escapeshellarg($filepath) . ' /etc/dmrgateway');
        exec('sudo mount -o remount,ro /');

        // Reload the affected daemon
    exec('sudo systemctl restart mmdvmhost.service');            // Reload MMDVMHost
    exec('sudo systemctl restart dmrgateway.service');            // Reload DMRGateway
}

// Re-read for the form's textarea.
$fh = fopen($filepath, 'r');
$theData = fread($fh, filesize($filepath));
fclose($fh);

?>
<form name="test" method="post" action="">
<?php csrf_field(); ?>
<textarea name="data" cols="80" rows="45"><?php echo htmlspecialchars((string)$theData, ENT_QUOTES, 'UTF-8'); ?></textarea><br />
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

