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

  <table width="100%">
    <tr><th>Expert Editors</th></tr>
    <tr><td align="center">
      <h2 style="color: #000000">**Предупреждение!**</h2>
      Редакторы Pi-Star Expert были созданы для более простого изменения некоторых  настроек<br />
      файлов конфигурации, без входа в Pi через консоль управления SSH.<br />

      Пожалуйста, имейте в виду, что внесенные здесь изменения могут привести к обновлению
      панели инструментов и перезаписи предыдущих настроек. Предполагается, что вы знаете,<br />
      что вы делаете, когда вносите изменения вручную, и что вы понимаете, какие настройки<br />
      влияют на работу с панелью инструментов и системы в целом.<br />

      Помня об этом предупреждении, вы можете вносить любые изменения по своему усмотрению.<br />
      В группе (ссылка внизу страницы) можно попросить о помощи, если/когда она вам понадобится.<br />
      73 и наслаждайтесь работой Pi-Star.<br />
      Команда Pi-Star.<br />
      <br />
    </td></tr>
  </table>
  </div>

<div class="footer">
Pi-Star / Pi-Star Dashboard, &copy; Andy Taylor (MW0MWZ) 2014-<?php echo date("Y"); ?>.<br />
Need help? Click <a style="color: #ffffff;" href="https://www.facebook.com/groups/pistarusergroup/" target="_new">here for the Support Group</a><br />
Get your copy of Pi-Star from <a style="color: #ffffff;" href="http://www.pistar.uk/downloads/" target="_new">here</a>.<br />
</div>

</div>
</body>
</html>