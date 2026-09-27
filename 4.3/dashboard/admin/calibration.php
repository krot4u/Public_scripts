<?php
/**
 * Modem calibration UI.
 *
 * Three responsibilities, all served from this single endpoint:
 *   1. /admin/calibration.php?action=start  — invokes the
 *      /usr/local/sbin/pistar-calibration-start wrapper, which owns
 *      the localhost-bound nc UDP listener + script(1) + MMDVMCal
 *      pipeline. Captured output streams into /tmp/pi-star_mmdvmcal.log.
 *   2. /admin/calibration.php?cmd=<single-letter>&param=<value> —
 *      sends commands to the running mmdvmcal process via UDP
 *      socket on 127.0.0.1:33273 (mmdvmcal's IPC port).
 *   3. /admin/calibration.php?ajax — tails /tmp/pi-star_mmdvmcal.log
 *      using a session-stored byte offset so the browser can render
 *      the live calibration output and the BER chart.
 *
 *   4. /admin/calibration.php?action=saveoffset&param=<int> — persists
 *      the calibrated RX/TX offset by reading /etc/mmdvmhost,
 *      preg_replace-ing RXOffset/TXOffset, and atomic-installing the
 *      result (intval()-validated; see L-7 cleanup commit for why
 *      this is no longer a sudo-sed pipeline).
 *
 * The form itself is mostly client-side JS (jQuery + plotly) that
 * sends commands and renders the rolling Bit Error Rate plot.
 */
require_once($_SERVER['DOCUMENT_ROOT'].'/config/security_headers.php');
require_once($_SERVER['DOCUMENT_ROOT'].'/config/csrf.php');
require_once($_SERVER['DOCUMENT_ROOT'].'/config/banner_warnings.inc');
setSecurityHeaders();

// CSRF protection — see config/csrf.php for the full rationale.
// Must run BEFORE any output: bootstraps the session on GET (so
// Set-Cookie ships) and rejects forged POSTs cleanly with 403
// before the start / saveoffset / cmd handlers run.
//
// Calibration's state-changing operations were historically GETs
// (sendaction/sendcmd in the inline JS sent via $.ajax type:
// 'GET'). That meant a hostile page could embed e.g.
// `<img src="/admin/calibration.php?action=start">` and trigger
// the privileged `sudo … pistar-mmdvmcal` startup just because
// the operator's browser had cached basic-auth. The handlers
// below now read $_POST exclusively; the JS sends type: 'POST'
// with the csrf_token rendered into a JS variable from the GET-
// rendered page. CSRF-token verification gates every state
// change. The ?ajax log-tail polling stays as GET (read-only,
// idempotent — safe as GET by REST convention).
csrf_verify();

// Layer 2 of the default-password protection — see config/banner_warnings.inc.
// MUST run BEFORE any output so header('Location: ...') works.
pistar_warnings_enforce_redirect();

// Load the language support
require_once('config/language.php');
// Load the Pi-Star Release file
$pistarReleaseConfig = '/etc/pistar-release';
$configPistarRelease = array();
$configPistarRelease = parse_ini_file($pistarReleaseConfig, true);
// Load the Version Info
require_once('config/version.php');

// Sanity Check that this file has been opened correctly
if ($_SERVER["PHP_SELF"] == "/admin/calibration.php") {

  // ------------------------------------------------------------------
  // State-changing handlers — POST only, CSRF-verified above.
  //
  // mmdvmcal's command set is small and well-defined; we mirror it
  // explicitly here so the server never forwards arbitrary bytes to
  // the running daemon's UDP IPC port. The whitelists below are
  // what the inline JS (sendaction / sendcmd) ever generates.
  // ------------------------------------------------------------------

  if (isset($_POST['action'])) {
      if ($_POST['action'] === 'start') {
          // Calibration is now driven by the pistar-calibration-start
          // wrapper (in Pi-Star_Binaries_sbin), which owns the
          // localhost-bound nc UDP listener + script(1) + MMDVMCal
          // pipeline that this code used to run inline. The wrapper:
          //   - binds nc to 127.0.0.1:33273 (the dashboard's IPC port —
          //     unbound 0.0.0.0 would let any LAN device drive the
          //     radio modem during calibration);
          //   - holds a single-instance flock so a second click is a
          //     no-op until the running session ends or is stopped;
          //   - detaches via setsid so this system() call returns
          //     immediately while the pipeline keeps running;
          //   - writes captured output to /tmp/pi-star_mmdvmcal.log,
          //     which the ?ajax tail loop below reads via session
          //     byte-offset.
          //
          // Wrapping the pipeline as one allowlistable script kept
          // `sudo -i script -qfc ...` out of the dashboard's sudoers
          // — `sudo -i` is essentially "root login shell + run cmd"
          // and can't be safely path-scoped. The sub-command `stop`
          // tears down a running calibration via fuser + killall.
          // Calling `stop` first is idempotent (no-op if nothing's
          // running) and gives a clean slate before each fresh start.
          system('sudo /usr/local/sbin/pistar-calibration-start stop > /dev/null 2>&1');
          system('sudo /usr/local/sbin/pistar-calibration-start > /dev/null 2>&1');
      } elseif ($_POST['action'] === 'saveoffset') {
          if (isset($_POST['param']) && strlen($_POST['param'])) {
              // intval() forces an integer — mmdvmhost accepts a
              // signed integer offset (negative is fine).
              $offset = intval($_POST['param']);

              // L-7: drop the prior `sudo sed -i` pair in favour of a
              // PHP-side rewrite + atomic install. The two RXOffset/
              // TXOffset keys live in /etc/mmdvmhost's [Modem] section;
              // the stock config has exactly one occurrence of each
              // line at start-of-line, so an anchored preg_replace is
              // safe without full INI section awareness. /etc/mmdvmhost
              // is mode 644 so the read does not need sudo.
              $mmdvmContent = @file_get_contents('/etc/mmdvmhost');
              if ($mmdvmContent !== false) {
                  $mmdvmContent = preg_replace(
                      '/^RXOffset=.*$/m',
                      'RXOffset=' . $offset,
                      $mmdvmContent
                  );
                  $mmdvmContent = preg_replace(
                      '/^TXOffset=.*$/m',
                      'TXOffset=' . $offset,
                      $mmdvmContent
                  );
                  // A3-3: per-request random staging path defeats
                  // predictable-name pre-create / symlink attacks.
                  $stage = tempnam('/tmp', 'pistar-calib-');
                  file_put_contents($stage, $mmdvmContent);

                  // Atomic install (B5/L-5 pattern). Re-seal the rootfs
                  // on every exit path — the original handler had a
                  // bug here that's preserved by the new envelope.
                  system('sudo mount -o remount,rw /');
                  system('sudo install -m 644 -o root -g root '
                       . escapeshellarg($stage) . ' /etc/mmdvmhost');
                  system('sudo mount -o remount,ro /');
                  @unlink($stage);
              } else {
                  error_log('Pi-Star calibration.php: /etc/mmdvmhost unreadable; saveoffset skipped');
              }
          }
      }
      // Anything else: silent ignore (could be a stale form replay or
      // a probe). Don't echo errors that would leak the action set.
      exit();
  }

  if (isset($_POST['cmd']) && strlen($_POST['cmd'])) {
      // Whitelist of mmdvmcal commands the inline JS ever sends.
      //
      //   q  Stop / quit calibration
      //   k  D-Star BER mode
      //   b  DMR Simplex BER mode
      //   J  YSF BER mode
      //   j  P25 BER mode
      //   n  NXDN BER mode
      //   f  Frequency offset down
      //   F  Frequency offset up
      //   z  Set step size      (param: 25 | 50 | 100)
      //   e  Set frequency (Hz) (param: digits)
      //
      // Anything outside this set silently no-ops. The file-level
      // CSRF check has already passed; this is defence-in-depth
      // against a legit-authenticated session being tricked into
      // sending arbitrary bytes to the running mmdvmcal.
      $cmd = $_POST['cmd'];
      $allowed = array('q', 'k', 'b', 'J', 'j', 'n', 'f', 'F', 'z', 'e');
      if (!in_array($cmd, $allowed, true)) {
          error_log("calibration: rejected unknown cmd '" . substr($cmd, 0, 16) . "'");
          exit();
      }

      // Per-command param validation. Any param outside the per-cmd
      // whitelist is dropped (the cmd byte itself still goes through
      // unchanged — that matches the legacy "param missing" path).
      $param = isset($_POST['param']) ? (string)$_POST['param'] : '';
      if ($param !== '') {
          if ($cmd === 'z' && !in_array($param, array('25', '50', '100'), true)) {
              error_log("calibration: rejected step size '" . substr($param, 0, 16) . "'");
              $param = '';
          } elseif ($cmd === 'e' && !preg_match('/\A\d{6,12}\z/', $param)) {
              // 6..12 digits covers HF (3.5 MHz = 7 digits) through
              // 23 cm (1.3 GHz = 10 digits) plus a little headroom.
              error_log("calibration: rejected frequency '" . substr($param, 0, 16) . "'");
              $param = '';
          }
      }

      $sock = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
      socket_bind($sock, '127.0.0.1', 33272) || exit();
      socket_sendto($sock, $cmd, strlen($cmd), 0, '127.0.0.1', 33273);
      if ($param !== '') {
          usleep(500 * 1000);
          socket_sendto($sock, $param . "\n", strlen($param) + 1, 0, '127.0.0.1', 33273);
      }
      if ($cmd === 'q') {
          sleep(1);
          // Send a newline to unblock anything mmdvmcal is waiting on
          // (and to drop the nc-piped pipe cleanly).
          socket_sendto($sock, "\n", 1, 0, '127.0.0.1', 33273);
      }
      socket_close($sock);
      exit();
  }

  // Sanity Check Passed.
  header('Cache-Control: no-cache');
  // session_start() is no longer called here — csrf_verify() at the
  // top of the file already started the session via
  // csrf_session_start(). A second session_start() would emit a
  // "session is already active" NOTICE on PHP 8.x. The existing
  // $_SESSION['mmdvmcal_offset'] log-tail logic below works
  // unchanged against the already-active session.

  if (!isset($_GET['ajax'])) {
    //unset($_SESSION['mmdvmcal_offset']);
    if (file_exists('/tmp/pi-star_mmdvmcal.log')) {
      $_SESSION['mmdvmcal_offset'] = filesize('/tmp/pi-star_mmdvmcal.log');
    } else {
      $_SESSION['mmdvmcal_offset'] = 0;
    }
  }

  if (isset($_GET['ajax'])) {
    //session_start();
    if (!file_exists('/tmp/pi-star_mmdvmcal.log')) {
      exit();
    }

    $handle = fopen('/tmp/pi-star_mmdvmcal.log', 'rb');
    if (isset($_SESSION['mmdvmcal_offset'])) {
      fseek($handle, 0, SEEK_END);
      if ($_SESSION['mmdvmcal_offset'] > ftell($handle)) //log rotated/truncated
        $_SESSION['mmdvmcal_offset'] = 0; //continue at beginning of the new log
      $data = stream_get_contents($handle, -1, $_SESSION['mmdvmcal_offset']);
      $_SESSION['mmdvmcal_offset'] += strlen($data);
      echo nl2br($data);
      }
    else {
      fseek($handle, 0, SEEK_END);
      $_SESSION['mmdvmcal_offset'] = ftell($handle);
      }
  exit();
  }

  $RXFrequency = exec('grep "RXFrequency" /etc/mmdvmhost | awk -F "=" \'{print $2}\'');
  $RXOffset = exec('grep "RXOffset" /etc/mmdvmhost | awk -F "=" \'{print $2}\'');

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
    <meta name="Description" content="Pi-Star Calibration" />
    <meta name="KeyWords" content="Pi-Star" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="pragma" content="no-cache" />
    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />
    <meta http-equiv="Expires" content="0" />
    <title>Pi-Star - <?php echo $lang['digital_voice']." ".$lang['dashboard']." - Calibration";?></title>
    <link rel="stylesheet" type="text/css" href="css/pistar-css.php" />
    <script type="text/javascript" src="/jquery.min.js"></script>
    <script type="text/javascript" src="/jquery-timing.min.js"></script>
    <script type="text/javascript" src="/plotly-basic.min.js"></script>
    <script type="text/javascript">

    var rxoffset = ~~'<?php echo $RXOffset; ?>';

    // CSRF token for the AJAX POSTs below. Issued by the GET-render
    // path (this script tag is inside the GET response) and embedded
    // verbatim — same-origin policy prevents a hostile site from
    // reading this value. Every state-changing AJAX call carries it
    // in the POST body; the PHP handler at the top of this file
    // calls csrf_verify() before any side-effect.
    var csrf_token = '<?php echo htmlspecialchars(csrf_token(), ENT_QUOTES, 'UTF-8'); ?>';

    function sendaction(action='', param='')
    {
      if (action === 'start') { document.getElementById("btnStart").disabled = true; }
      if (action === 'saveoffset') { rxoffset = ~~param }
      $.ajax({
        url: 'calibration.php',
        type: 'POST',
        data: {
          'action': action,
          'param': param,
          'csrf_token': csrf_token
        },
        cache: false,
        success: function(msg) {}
      });
      return false;
    }

    var sendcmd_lock=false;

    function sendcmd(cmd='', param='')
    {
      if (sendcmd_lock) { return false; }
      if (param !== '') { sendcmd_lock = true; } //if we have param, lock to prevent cmd overlap while waiting param
      $.ajax({
        url: 'calibration.php',
        type: 'POST',
        data: {
          'cmd': cmd,
          'param': param,
          'csrf_token': csrf_token
        },
        cache: false,
        success: function(msg) {},
        complete: function() { sendcmd_lock = false; }
      });
      return false;
    }

    var cnt=0; tcnt=0;
    var cfrms=0; cbits=0, cberr=0;
    var tfrms=0; tbits=0, tberr=0;
    var eot=false;

    $(function() {
      $.repeat(1000, function() {
        $.get('/admin/calibration.php?ajax', function(data) {
         if (data.length > 0) {
<?php if (isset($_GET['debug'])) { ?>
          var objDiv = document.getElementById("tail");
          var isScrolledToBottom = objDiv.scrollHeight - objDiv.clientHeight <= objDiv.scrollTop + 1;
          $('#tail').append(data);
          if (isScrolledToBottom)
            objDiv.scrollTop = objDiv.scrollHeight;
<?php } ?>

          if (("\n"+data).includes("Version:")) {
            setTimeout(function(){ sendcmd('e', (~~'<?php echo $RXFrequency; ?>'+rxoffset).toString() ); }, 1000);
          }
          if (("\n"+data).includes("Finnished...")) {
            $('#ledStart').attr("src", 'images/20red.png');
            $('#ledDStar').attr("src", 'images/20red.png');
            $('#ledDMR').attr("src", 'images/20red.png');
            $('#ledYSF').attr("src", 'images/20red.png');
            $('#ledP25').attr("src", 'images/20red.png');
            $('#ledNXDN').attr("src", 'images/20red.png');
            document.getElementById("btnStart").disabled = false;
          }

          if (("\n"+data).includes("\nBER Test Mode (FEC) for D-Star")) {
            $('#ledStart').attr("src", 'images/20green.png');
            $('#ledDStar').attr("src", 'images/20green.png');
            $('#ledDMR').attr("src", 'images/20red.png');
            $('#ledYSF').attr("src", 'images/20red.png');
            $('#ledP25').attr("src", 'images/20red.png');
            $('#ledNXDN').attr("src", 'images/20red.png');
          }
          if (("\n"+data).includes("\nBER Test Mode (FEC) for DMR Simplex")) {
            $('#ledStart').attr("src", 'images/20green.png');
            $('#ledDStar').attr("src", 'images/20red.png');
            $('#ledDMR').attr("src", 'images/20green.png');
            $('#ledYSF').attr("src", 'images/20red.png');
            $('#ledP25').attr("src", 'images/20red.png');
            $('#ledNXDN').attr("src", 'images/20red.png');
          }
          if (("\n"+data).includes("\nBER Test Mode (FEC) for YSF")) {
            $('#ledStart').attr("src", 'images/20green.png');
            $('#ledDStar').attr("src", 'images/20red.png');
            $('#ledDMR').attr("src", 'images/20red.png');
            $('#ledYSF').attr("src", 'images/20green.png');
            $('#ledP25').attr("src", 'images/20red.png');
            $('#ledNXDN').attr("src", 'images/20red.png');
          }
          if (("\n"+data).includes("\nBER Test Mode (FEC) for P25")) {
            $('#ledStart').attr("src", 'images/20green.png');
            $('#ledDStar').attr("src", 'images/20red.png');
            $('#ledDMR').attr("src", 'images/20red.png');
            $('#ledYSF').attr("src", 'images/20red.png');
            $('#ledP25').attr("src", 'images/20green.png');
            $('#ledNXDN').attr("src", 'images/20red.png');
          }
          if (("\n"+data).includes("\nBER Test Mode (FEC) for NXDN")) {
            $('#ledStart').attr("src", 'images/20green.png');
            $('#ledDStar').attr("src", 'images/20red.png');
            $('#ledDMR').attr("src", 'images/20red.png');
            $('#ledYSF').attr("src", 'images/20red.png');
            $('#ledP25').attr("src", 'images/20red.png');
            $('#ledNXDN').attr("src", 'images/20green.png');
          }

          if (data.includes("voice end received,")) {
            eot=true;
          }

          var regex = / frequency: (\d+)/g
          while (match = regex.exec(data)) {
            $('#ledStart').attr("src", 'images/20green.png');
            $("#lblFrequency").text(match[1] + ' Hz');
            $("#lblOffset").text(~~match[1] - ~~'<?php echo $RXFrequency; ?>');
          }

          var regex = /\% \((\d+)\/(\d+)\)/g
          while (match = regex.exec(data)) {
            cfrms += 1;
            cberr += ~~match[1];
            cbits += ~~match[2];
            tfrms += 1;
            tberr += ~~match[1];
            tbits += ~~match[2];
          }
         }

          if (cbits > 0) {
            cnt++; tcnt++;
            var updfrq = $('#sltUpdFrq').val();
            if ((tcnt % updfrq == 0) || eot) {
                //$('#tail').append(cfrms +' , '+ cberr +' / '+ cbits +' , '+ (cberr/cbits*100).toFixed(2) + '%<br>');
                $("#lblFrames").text(cfrms);
                $("#lblBits").text(cbits);
                $("#lblErrors").text(cberr);
                $("#lblBER").text((cberr/cbits*100).toFixed(2)+'%');
                Plotly.extendTraces('chart', { x:[[cnt]], y:[[cberr/cbits*100]] }, [0]);
                if(cnt > 60*3) {
                    Plotly.relayout('chart', {
                        xaxis: {range: [cnt-60*3,cnt]}
                    });
                }
                cfrms=0; cbits=0; cberr=0;

                //$('#tail').append('total: ' + tfrms +' , '+ tberr +' / '+ tbits +' , '+ (tberr/tbits*100).toFixed(2) + '%<br>');
                $("#lblTFrames").text(tfrms);
                $("#lblTBits").text(tbits);
                $("#lblTErrors").text(tberr);
                $("#lblTBER").text((tberr/tbits*100).toFixed(2)+'%');
                $("#lblTSec").text(tcnt);
                if (eot) {
                  eot=false;
                  tfrms=0; tbits=0; tberr=0; tcnt=0;
                }
            }
          }

        });
      });
    });
    </script>
  </head>
  <body>
  <?php pistar_warnings_render(); ?>
  <div class="container">
  <div class="header">
  <div style="font-size: 8px; text-align: right; padding-right: 8px;">Pi-Star:<?php echo $configPistarRelease['Pi-Star']['Version']?> / Dashboard:<?php echo $version; ?></div>
  <h1>Pi-Star - <?php echo $lang['digital_voice']." ".$lang['dashboard']." - Calibration";?></h1>
  <a href="http://pi-star/?"><div align="center"><img src="/images/header_new.png" alt="QRA-Team Pi-Star" /></a>
  <p style="padding-right: 5px; text-align: right; color: #ffffff;">
    <a href="/" style="color: #ffffff;"><?php echo $lang['dashboard'];?></a> |
    <a href="/admin/" style="color: #ffffff;"><?php echo $lang['admin'];?></a> |
    <a href="/admin/power.php" style="color: #ffffff;"><?php echo $lang['power'];?></a> |
    <a href="/admin/config_backup.php" style="color: #ffffff;"><?php echo $lang['backup_restore'];?></a> |
    <a href="/admin/configure.php" style="color: #ffffff;"><?php echo $lang['configuration'];?></a>
  </p>
  </div>
  <div class="contentwide">
  <table width="100%">
  <tr><th>Calibration Tool</th></tr>
  <tr><td align="left">

<table width="800" border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td align="center" valign="middle"><table border="0" cellspacing="0" cellpadding="5">
      <tr>
        <td><input name="btnStart" type="button" id="btnStart" onclick="sendaction('start');" value="Start" /></td>
        <td><img src="images/20red.png" name="ledStart" width="20" height="20" id="ledStart" /></td>
      </tr>
      <tr>
        <td><input name="btnStop" type="button" id="btnStop" onclick="sendcmd('q');" value="Stop" /></td>
        <td>&nbsp;</td>
      </tr>
    </table></td>

    <td align="center" valign="middle"><table border="0" cellspacing="0" cellpadding="4" height="160">
      <tr>
        <td><input name="btnDStar" type="button" id="btnDStar" onclick="sendcmd('k');" value="D-Star" /></td>
        <td><img src="images/20red.png" name="ledDStar" width="20" height="20" id="ledDStar" /></td>
        </tr>
      <tr>
        <td><input name="btnDMR" type="button" id="btnDMR" onclick="sendcmd('b');" value="DMR" /></td>
        <td><img src="images/20red.png" name="ledDMR" width="20" height="20" id="ledDMR" /></td>
        </tr>
      <tr>
        <td><input name="btnYSF" type="button" id="btnYSF" onclick="sendcmd('J');" value="YSF" /></td>
        <td><img src="images/20red.png" name="ledYSF" width="20" height="20" id="ledYSF" /></td>
        </tr>
      <tr>
        <td><input name="btnP25" type="button" id="btnP25" onclick="sendcmd('j');" value="P25" /></td>
        <td><img src="images/20red.png" name="ledP25" width="20" height="20" id="ledP25" /></td>
        </tr>
      <tr>
        <td><input name="btnNXDN" type="button" id="btnNXDN" onclick="sendcmd('n');" value="NXDN" /></td>
        <td><img src="images/20red.png" name="ledNXDN" width="20" height="20" id="ledNXDN" /></td>
        </tr>
    </table></td>

    <td align="center" valign="middle"><table border="0" cellspacing="0" cellpadding="5" height="160">
      <tr>
        <td align="left">Base Freq.:</td>
        <td colspan="3" id="lblBaseFreq"><?php echo $RXFrequency; ?> Hz</td>
      </tr>
      <tr>
        <td align="left">Frequency:</td>
        <td colspan="3" id="lblFrequency"><?php echo $RXFrequency + $RXOffset; ?> Hz</td>
      </tr>
      <tr>
        <td align="left">Offset:</td>
        <td><input name="btnFreqM" type="button" id="btnFreqM" onclick="sendcmd('f');" value="-" /></td>
        <td id="lblOffset" style="width:5ch"><?php echo $RXOffset; ?></td>
        <td><input name="btnFreqP" type="button" id="btnFreqP" onclick="sendcmd('F');" value="+" /></td>
      </tr>
      <tr>
        <td align="left">Step:</td>
        <td colspan="3"><input type="button" onclick="sendcmd('z','25');" value="25" /> <input type="button" onclick="sendcmd('z','50');" value="50" /> <input type="button" onclick="sendcmd('z','100');" value="100" /></td>
      </tr>
      <tr>
        <td align="left">&nbsp;</td>
        <td colspan="3"><input name="button8" type="button" onclick="sendaction('saveoffset',$('#lblOffset').text());" value="Save Offset" /></td>
      </tr>
    </table></td>

    <td align="center" valign="middle"><table border="0" cellspacing="0" cellpadding="5" height="160">
      <tr>
        <th style="width:8ch">&nbsp;</th>
        <th style="width:9ch">Current</th>
        <th style="width:9ch">Total</th>
      </tr>
      <tr>
        <td align="left">Frames:</td>
        <td id="lblFrames">&nbsp;</td>
        <td id="lblTFrames">&nbsp;</td>
      </tr>
      <tr>
        <td align="left">Bits:</td>
        <td id="lblBits">&nbsp;</td>
        <td id="lblTBits">&nbsp;</td>
      </tr>
      <tr>
        <td align="left">Errors:</td>
        <td id="lblErrors">&nbsp;</td>
        <td id="lblTErrors">&nbsp;</td>
      </tr>
      <tr>
        <td align="left">BER:</td>
        <td id="lblBER">&nbsp;</td>
        <td id="lblTBER">&nbsp;</td>
      </tr>
      <tr>
        <td align="left">Seconds:</td>
        <td id="lblSec" style="padding:0;"><select name="sltUpdFrq" id="sltUpdFrq" style="margin:0;">
                          <option value="1">1</option>
                          <option value="2">2</option>
                          <option value="3">3</option>
                          <option value="5" selected="selected">5</option>
                          <option value="10">10</option>
                          <option value="30">30</option>
                        </select>
        </td>
        <td id="lblTSec">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
</table>

  </td></tr>
  <tr><td align="left">
        <div id="chart"></div>
        <script type="text/javascript">
            Plotly.newPlot('chart', [{
                x: [0],
                y: [0],
                type: 'scatter',
                mode: 'lines',
                fill: 'tozeroy',
                line: {color: '#dd4b39'}
            }], {title:'Bit Error Rate (BER)', xaxis:{title:'Seconds',rangemode:'tozero'}, yaxis:{title:'%',rangemode:'tozero',range:[0,5]} }, {staticPlot: true});
        </script>
      </td></tr>
<?php if (isset($_GET['debug'])) { ?>
  <tr><td align="left"><div id="tail"></div></td></tr>
<?php } ?>
  </table>
  </div>
  <div class="footer">
  Pi-Star web config, &copy; Andy Taylor (MW0MWZ) 2014-<?php echo date("Y"); ?>.<br />
  Need help? Click <a style="color: #ffffff;" href="https://www.facebook.com/groups/pistarusergroup/" target="_new">here for the Support Group</a><br />
  Get your copy of Pi-Star from <a style="color: #ffffff;" href="http://www.pistar.uk/downloads/" target="_blank">here</a>.<br />
  <br />
  </div>
  </div>
  </body>
  </html>

<?php
}
