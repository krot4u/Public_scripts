<?php
if ($_GET['run']) {
  # This code will run if ?run=true is set.
  exec("/usr/local/sbin/sendLogs.sh");
}
?>