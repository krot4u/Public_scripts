<?php
function format_time($seconds) {
	$secs = intval($seconds % 60);
	$mins = intval($seconds / 60 % 60);
	$hours = intval($seconds / 3600 % 24);
	$days = intval($seconds / 86400);
	$uptimeString = "";

	if ($days > 0) {
		$uptimeString .= $days;
		$uptimeString .= (($days == 1) ? "&nbsp;day" : "&nbsp;days");
	}
	if ($hours > 0) {
		$uptimeString .= (($days > 0) ? ", " : "") . $hours;
		$uptimeString .= (($hours == 1) ? "&nbsp;hr" : "&nbsp;hrs");
	}
	if ($mins > 0) {
		$uptimeString .= (($days > 0 || $hours > 0) ? ", " : "") . $mins;
		$uptimeString .= (($mins == 1) ? "&nbsp;min" : "&nbsp;mins");
	}
	if ($secs > 0) {
		$uptimeString .= (($days > 0 || $hours > 0 || $mins > 0) ? ", " : "") . $secs;
		$uptimeString .= (($secs == 1) ? "&nbsp;s" : "&nbsp;s");
	}
	return $uptimeString;
}

function format_uptime($seconds) {
    $secs = intval($seconds % 60);
    $mins = intval($seconds / 60 % 60);
    $hours = intval($seconds / 3600 % 24);
    $days = intval($seconds / 86400);
    $uptimeString = "";

    if ($days > 0) {
    $uptimeString .= $days;
    $uptimeString .= (($days == 1) ? "&nbsp;day" : "&nbsp;days");
    }
    if ($hours > 0) {
    $uptimeString .= (($days > 0) ? ", " : "") . $hours;
    $uptimeString .= (($hours == 1) ? "&nbsp;hr" : "&nbsp;hrs");
    }
    if ($mins > 0) {
    $uptimeString .= (($days > 0 || $hours > 0) ? ", " : "") . $mins;
    $uptimeString .= (($mins == 1) ? "&nbsp;min" : "&nbsp;mins");
    }
    return $uptimeString;
}

function startsWith($haystack, $needle) {
    return $needle === "" || strrpos($haystack, $needle, -strlen($haystack)) !== false;
}

function isProcessRunning($processName, $full = false, $refresh = false) {
  if ($full) {
    static $processes_full = array();
    if ($refresh) $processes_full = array();
    if (empty($processes_full))
      exec('ps -eo args', $processes_full);
  } else {
    static $processes = array();
    if ($refresh) $processes = array();
    if (empty($processes))
      exec('ps -eo comm', $processes);
  }
  foreach (($full ? $processes_full : $processes) as $processString) {
    if (strpos($processString, $processName) !== false)
      return true;
  }
  return false;
}