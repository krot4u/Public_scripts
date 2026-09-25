#!/usr/bin/env bash
###############################################################################
# Generates a representative MMDVMHost activity log for the current UTC day.
#
# The dashboard reads /var/log/pi-star/MMDVM-<UTC-date>.log and parses the
# "received ... from CALL to TARGET" lines into the "Last Heard" table. Because
# the filename is date-based, this is regenerated on every boot (from start.sh)
# so the demo data is always for "today" and appears live.
#
# Safe to run repeatedly; it overwrites only today's sample log.
###############################################################################
set -euo pipefail

LOG_DIR="/var/log/pi-star"
LOG_FILE="${LOG_DIR}/MMDVM-$(date -u +%F).log"

SUDO=""
if [ ! -w "$LOG_DIR" ]; then SUDO="sudo"; fi
$SUDO mkdir -p "$LOG_DIR"

ts() { date -u -d "-$1 minutes" +"%Y-%m-%d %H:%M:%S.000"; }

# A spread of completed network/RF transmissions across DMR (both slots),
# D-Star and YSF, with varied BER so the dashboard's colour coding is visible.
$SUDO tee "$LOG_FILE" >/dev/null <<EOF
M: $(ts 58) MMDVM Host is starting
M: $(ts 58) Opening the DMR Network
M: $(ts 57) DMR, Logged into the master successfully
M: $(ts 45) DMR Slot 2, received network end of voice transmission from EW1ABC to TG 2340, 12.3 seconds, 0% packet loss, BER: 0.4%
M: $(ts 41) DMR Slot 1, received network end of voice transmission from UK7XYZ to TG 91, 4.7 seconds, 1% packet loss, BER: 1.8%
M: $(ts 37) D-Star, received network end of transmission from DG9VH    to CQCQCQ  , 3.2 seconds, 0% packet loss, BER: 0.5%
M: $(ts 33) DMR Slot 2, received network end of voice transmission from 2500123 to TG 2341, 8.1 seconds, 0% packet loss, BER: 0.0%
M: $(ts 28) YSF, received network end of transmission from JA1ZZZ    to ALL     , 6.5 seconds, 2% packet loss, BER: 3.1%
M: $(ts 22) DMR Slot 1, received network end of voice transmission from EW1ABC to TG 2340, 5.0 seconds, 4% packet loss, BER: 5.6%
M: $(ts 15) DMR Slot 2, received network end of voice transmission from MW0MWZ to TG 235, 2.4 seconds, 0% packet loss, BER: 0.2%
M: $(ts 9) D-Star, received network end of transmission from EA4ABC    to CQCQCQ  , 1.9 seconds, 0% packet loss, BER: 0.7%
M: $(ts 4) DMR Slot 2, received network end of voice transmission from UB3DEF to TG 2340, 9.8 seconds, 0% packet loss, BER: 0.9%
EOF

echo "==> Wrote sample activity log: $LOG_FILE"
