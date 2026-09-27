<?php
/**
 * Expert INI editor for /etc/mmdvmhost.
 *
 * Renders a per-section / per-key form built from parse_ini_file()
 * output, accepts edits via POST, then writes the result back to
 * /etc/mmdvmhost using the standard Pi-Star copy-via-/tmp pattern:
 *   1. sudo cp /etc/mmdvmhost /tmp/<obfuscated>.tmp + chown www-data
 *      + chmod 600 (so PHP can edit the temp).
 *   2. fopen('w') and fwrite the rebuilt INI text into the temp.
 *   3. sudo mount -o remount,rw / + sudo install -m 644 -o root -g
 *      root temp -> /etc/mmdvmhost + sudo mount -o remount,ro / to
 *      seal the rootfs again. (L-5: collapses the prior cp + chmod +
 *      chown triplet into one atomic call — same idiom used by
 *      configure.php's gateway-save block. The triplet would also
 *      be rejected by the tightened /etc/sudoers.d/pistar-dashboard
 *      because it allowlists install but not bare cp+chmod+chown
 *      against /etc/<gateway>.)
 *   4. sudo systemctl restart mmdvmhost.service to pick up the change.
 *
 * Admin-only access; the dashboard's Apache basic-auth gate is the
 * sole protection. The validation is what's in the form (none, in
 * effect — operator-typed values are written raw). Treat with care.
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
//Do some file wrangling...
// A3-3 — see edit_ircddbgateway.php for the full TOCTOU rationale.
// tempnam() creates the staging file mode 600 owned by www-data
// with an unguessable random suffix.
$filepath = tempnam('/tmp', 'pistar-edit-');
exec('sudo cp /etc/mmdvmhost ' . escapeshellarg($filepath));
exec('sudo chown www-data:www-data ' . escapeshellarg($filepath));
exec('sudo chmod 600 ' . escapeshellarg($filepath));
// Clean up the /tmp staging file on script exit so the
// editor's potentially-secrets-bearing copy of /etc/<config>
// doesn't persist between requests. @-suppression handles
// the case where a sudo mv (e.g. fulledit_bmapikey) already
// consumed the staging file before script end.
register_shutdown_function(function() use ($filepath) { @unlink($filepath); });

//after the form submit
if($_POST) {
    $data = $_POST;
    //update ini file, call function
    update_ini_file($data, $filepath);
}

//this is the function going to update your ini file
    function update_ini_file($data, $filepath)
    {
        $content = "";

        //parse the ini file to get the sections
        //parse the ini file using default parse_ini_file() PHP function
        $parsed_ini = parse_ini_file($filepath, true);

        foreach($data as $section=>$values) {
            // UnBreak special cases
            $section = str_replace("_", " ", $section);
            $content .= "[".$section."]\n";
            //append the values
            foreach($values as $key=>$value) {
                if ($section == "DMR Network" && $key == "Password" && $value) {
                    $value = str_replace('"', "", $value);
                    $content .= $key."=\"".$value."\"\n";
                }
                elseif ($section == "DMR Network" && $key == "Options" && $value) {
                    $value = str_replace('"', "", $value);
                    $content .= $key."=\"".$value."\"\n";
                }
                elseif ($section == "DMR Network" && $key == "Options" && !$value) {
                    $content .= $key."= \n";
                }
                elseif ($value == '') {
                                        $content .= $key."=none\n";
                                        }
                else {
                    $content .= $key."=".$value."\n";
                }
            }
            $content .= "\n";
        }

        //write it into file
        if (!$handle = fopen($filepath, 'w')) {
            return false;
        }

        $success = fwrite($handle, $content);
        fclose($handle);

        // Updates complete - install the working file back to the
        // proper location. L-5: atomic install replaces the prior
        // cp + chmod + chown triplet (which the tightened
        // /etc/sudoers.d/pistar-dashboard rejects on the bare
        // chmod/chown against /etc/<file> — only the install pattern
        // is allowlisted there).
        exec('sudo mount -o remount,rw /');
        exec('sudo install -m 644 -o root -g root '
             . escapeshellarg($filepath) . ' /etc/mmdvmhost');
        exec('sudo mount -o remount,ro /');

        // Reload the affected daemon
        exec('sudo systemctl restart mmdvmhost.service');        // Reload the daemon
        return $success;
    }

//parse the ini file using default parse_ini_file() PHP function
$parsed_ini = parse_ini_file($filepath, true);

echo '<form action="" method="post">'."\n";
echo csrf_field_html()."\n";
    foreach($parsed_ini as $section=>$values) {
        // INI section / key / value all come from /etc/mmdvmhost.
        // Operator-trusted in principle, but the M-3 audit class
        // means a value with a literal `"` or `<` (legitimate INI
        // content — e.g. "Options=foo=1,bar" or a callsign with a
        // space) breaks out of `value="…"` attributes and renders
        // as HTML.
        //
        // htmlspecialchars(ENT_QUOTES) preserves round-trip safety:
        //   on display:   `"` -> `&quot;`, `<` -> `&lt;` etc.
        //   browser decode (form parse): `&quot;` -> `"` again.
        //   POST: the raw byte gets back to the save handler.
        //   save handler at line ~108: writes `key=value` to INI
        //   verbatim — no further escaping or unescaping.
        // So values like `Options="foo=1,bar"` go in, get displayed
        // as `Options=&quot;foo=1,bar&quot;`, the browser still shows
        // `"foo=1,bar"` in the input field, and re-saving produces
        // a byte-identical INI line.
        $sectionHtml = htmlspecialchars((string)$section, ENT_QUOTES, 'UTF-8');
        // keep the section as hidden text so we can update once the form submitted
        echo "<input type=\"hidden\" value=\"$sectionHtml\" name=\"$sectionHtml\" />\n";
        echo "<table>\n";
        echo "<tr><th colspan=\"2\">$sectionHtml</th></tr>\n";
        // print all other values as input fields, so can edit.
        // note the name='' attribute it has both section and key
        foreach($values as $key=>$value) {
            $keyHtml   = htmlspecialchars((string)$key, ENT_QUOTES, 'UTF-8');
            $valueHtml = htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
            if (($key == "Options") || ($value)) {
                echo "<tr><td align=\"right\" width=\"30%\">$keyHtml</td><td align=\"left\"><input type=\"text\" name=\"{$sectionHtml}[$keyHtml]\" value=\"$valueHtml\" /></td></tr>\n";
            }
            elseif (($key == "Display") && ($value == '')) {
                echo "<tr><td align=\"right\" width=\"30%\">$keyHtml</td><td align=\"left\"><input type=\"text\" name=\"{$sectionHtml}[$keyHtml]\" value=\"None\" /></td></tr>\n";
            }
            else {
                echo "<tr><td align=\"right\" width=\"30%\">$keyHtml</td><td align=\"left\"><input type=\"text\" name=\"{$sectionHtml}[$keyHtml]\" value=\"0\" /></td></tr>\n";
            }
        }
        echo "</table>\n";
        echo '<input type="submit" value="'.$lang['apply'].'" />'."\n";
        echo "<br />\n";
    }
echo "</form>";
?>
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

