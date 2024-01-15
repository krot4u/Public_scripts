<?php
// Load the language support
require_once('config/language.php');
// Load the Pi-Star Release file
$pistarReleaseConfig = '/etc/pistar-release';
$configPistarRelease = array();
$configPistarRelease = parse_ini_file($pistarReleaseConfig, true);
// Load the Version Info
require_once('config/version.php');

// Sanity Check that this file has been opened correctly
if ($_SERVER["PHP_SELF"] == "/admin/sendlogs.php") {
  // Sanity Check Passed.
  header('Cache-Control: no-cache');
  session_start();
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
    <meta name="Description" content="Pi-Star Power" />
    <meta name="KeyWords" content="Pi-Star" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="pragma" content="no-cache" />
    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
    <meta http-equiv="Expires" content="0" />
    <title>Pi-Star - <?php echo $lang['digital_voice']." ".$lang['dashboard']." - ".$lang['power'];?></title>
    <link rel="stylesheet" type="text/css" href="css/pistar-css.php" />
  </head>
  <body>
  <div class="container">
  <div class="header">
  <div style="font-size: 8px; text-align: right; padding-right: 8px;">Pi-Star:<?php echo $configPistarRelease['Pi-Star']['Version']?> / <?php echo $lang['dashboard'].": ".$version; ?></div>
  <h1>Pi-Star <?php echo $lang['digital_voice']." - ".$lang['power'];?></h1>
  <a href="http://pi-star/?"><div align="center"><img src="/images/header.png" alt="QRA-Team Pi-Star" /></a>
  <p style="padding-right: 5px; text-align: right; color: #ffffff;">
    <a href="/" style="color: #ffffff;"><?php echo $lang['dashboard'];?></a> |
    <a href="/admin/" style="color: #ffffff;"><?php echo $lang['admin'];?></a> |
    <a href="/admin/update.php" style="color: #ffffff;"><?php echo $lang['update'];?></a> |
    <a href="/admin/config_backup.php" style="color: #ffffff;"><?php echo $lang['backup_restore'];?></a> |
    <a href="/admin/configure.php" style="color: #ffffff;"><?php echo $lang['configuration'];?></a>
  </p>
  </div>
  <div class="contentwide">
  <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Get the input value from the form
        $inputValue = $_POST["inputField"];
        // Validate or sanitize the input if needed
        // Run the Bash script with the input as an argument
        #shell_exec("/usr/local/sbin/sendLogs.sh" . escapeshellarg($inputValue));
        shell_exec("/usr/local/sbin/sendLogs.sh" $inputValue);

        // Display the result or handle it as needed
        echo "<p><strong>Логи отправленны Администраторам!</strong></p>";
        echo "<p><strong>Спасибо!</strong></p>";
        echo "<p><strong>Ваш QRA-Team!</strong></p>";
    } else {
        // Display the form
        ?>
    <form action="sendlogs.php" method="post">
        <label for="inputField" style="color: #ffffff;">Token:</label>
        <input type="password" name="inputField" id="inputField" required>
        <button type="submit">Отправить логи</button>
    </form>
        <?php
    }
    ?>
  </div>
  <div class="footer">
  Pi-Star web config, &copy; Andy Taylor (MW0MWZ) 2014-<?php echo date("Y"); ?>.<br />
  Need help? Click <a style="color: #ffffff;" href="https://help.qra-team.online/" target="_new">here for Support</a><br />
  Get your copy of Pi-Star from <a style="color: #ffffff;" href="http://www.pistar.uk/downloads/" target="_blank">here</a>.<br />
  <br />
  </div>
  </div>
  </body>
  </html>
  <?php
}
?>
