#!/usr/bin/env bash
###############################################################################
# Cloud Agent install script for the Pi-Star dashboard (PHP web app).
#
# This repository is the web UI that normally runs on a Pi-Star hotspot. It
# reads its state from system files under /etc, /usr/local/etc and
# /var/log/pi-star that are created by the MMDVMHost/ircDDBGateway stack.
#
# On a Cloud Agent VM none of that radio stack exists, so this script:
#   1. Installs PHP (the only runtime dependency).
#   2. Lays down representative *sample* config + lookup data so the dashboard
#      renders in "MMDVMHost" mode exactly as it would on real hardware.
#
# It is intentionally idempotent: it can be re-run at any time and only the
# static fixtures are (re)written here. The date-stamped activity log that
# powers the "Last Heard" table is regenerated on every boot by start.sh.
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing PHP runtime"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
# php-cli provides the interpreter and the built-in dev web server used by the
# dashboard. No composer/npm packages exist in this project.
sudo apt-get install -y -qq php-cli

echo "==> Creating sample Pi-Star system layout"
sudo mkdir -p /var/log/pi-star /usr/local/etc /etc/default /etc/sysconfig
sudo chmod 0755 /var/log/pi-star

# ---------------------------------------------------------------------------
# Pi-Star release marker (parsed as INI by the dashboard header).
# ---------------------------------------------------------------------------
sudo tee /etc/pistar-release >/dev/null <<'EOF'
[Pi-Star]
Version = 4.2.0
Repo = Release
HostFiles = 20240101
Build = 20240101
Kernel = Cloud-Agent
Hardware = RPi
EOF

# ---------------------------------------------------------------------------
# Mode marker: presence of this file puts the dashboard into MMDVMHost mode.
# ---------------------------------------------------------------------------
sudo tee /etc/dstar-radio.mmdvmhost >/dev/null <<'EOF'
mmdvmhost
EOF

# ---------------------------------------------------------------------------
# Main MMDVMHost config (standard MMDVM.ini layout). All sections the
# dashboard reads are present so no undefined-section warnings occur.
# ---------------------------------------------------------------------------
sudo tee /etc/mmdvmhost >/dev/null <<'EOF'
[General]
Callsign=TASKENT
Id=250000001
Timeout=180
Duplex=0
RFModeHang=10
NetModeHang=3
ModeHang=10

[Info]
RXFrequency=434000000
TXFrequency=434000000
Power=1
Latitude=41.311081
Longitude=69.240562
Height=0
Location=Cloud Agent
Description=Pi-Star Dashboard Dev
URL=https://qra-team.online/

[Modem]
Port=/dev/ttyACM0
Protocol=uart

[D-Star]
Enable=1
Module=B

[DMR]
Enable=1
ColorCode=1
SelfOnly=0

[System Fusion]
Enable=1

[P25]
Enable=0
NAC=293

[NXDN]
Enable=0
RAN=1

[POCSAG]
Enable=0
Frequency=439987500

[D-Star Network]
Enable=1
GatewayAddress=127.0.0.1

[DMR Network]
Enable=1
Address=84.232.5.113
Port=62031
Slot1=1
Slot2=1

[System Fusion Network]
Enable=1

[P25 Network]
Enable=0

[NXDN Network]
Enable=0

[POCSAG Network]
Enable=0
EOF

# ---------------------------------------------------------------------------
# ircDDBGateway config (key=value) used for the D-Star / APRS / IRC panels.
# ---------------------------------------------------------------------------
sudo tee /etc/ircddbgateway >/dev/null <<'EOF'
gatewayCallsign=TASKENT
gatewayAddress=127.0.0.1
ircddbEnabled=1
ircddbHostname=rr.openquad.net
aprsEnabled=1
aprsHostname=euro.aprs2.net
aprsPort=14580
EOF

# ---------------------------------------------------------------------------
# dstarrepeater config (RPT1/RPT2 panel).
# ---------------------------------------------------------------------------
sudo tee /etc/dstarrepeater >/dev/null <<'EOF'
callsign=TASKENT  B
gateway=TASKENT  G
EOF

# ---------------------------------------------------------------------------
# dmrgateway / dapnetgateway configs (parsed as INI). Direct DMR master is
# used above (Address != 127.0.0.1) so these can stay minimal.
# ---------------------------------------------------------------------------
sudo tee /etc/dmrgateway >/dev/null <<'EOF'
[DMR Network 1]
Enabled=0
Name=BrandMeister
Address=84.232.5.113
Port=62031

[DMR Network 2]
Enabled=0
Name=DMR+
Address=

[DMR Network 3]
Enabled=0
Name=

[XLX Network 1]
Enabled=0
Address=
EOF

sudo tee /etc/dapnetgateway >/dev/null <<'EOF'
[DAPNET]
Address=dapnet.afu.rwth-aachen.de
EOF

# ---------------------------------------------------------------------------
# Dashboard CSS / lookup-service marker (optional but avoids fallbacks).
# ---------------------------------------------------------------------------
sudo tee /etc/pistar-css.ini >/dev/null <<'EOF'
[Background]
Page = edf0f5
Content = ffffff
Banners = dd4b39

[Text]
Banners = ffffff
BannersDrop = 303030

[Tables]
HeadDrop = 8b0000
BgEven = EBEDEF
BgOdd = d0d0d0

[Content]
Text = 000000

[Lookup]
Service = RadioID

[BannerH1]
Enabled = 0
Text =

[BannerExtText]
Enabled = 0
Text =
EOF

# ---------------------------------------------------------------------------
# Host / ID lookup data. Ship the DMR master this hotspot "connects" to and
# reuse the ID databases that already live in the repo.
# ---------------------------------------------------------------------------
sudo tee /usr/local/etc/DMR_Hosts.txt >/dev/null <<'EOF'
# Name             Id  Address        Password  Port
BM_2340_Uzbekistan 12 84.232.5.113   passw0rd  62031
EOF

sudo tee /usr/local/etc/YSFHosts.txt >/dev/null <<'EOF'
00001;UZ-YSF;Uzbekistan Fusion;42.1.1.1;42000;41.31;69.24;
EOF

for f in DMRIds.dat dmrid.dat NXDN.csv; do
    if [ -f "$REPO_ROOT/$f" ]; then
        sudo cp "$REPO_ROOT/$f" "/usr/local/etc/$f"
    fi
done

# Generate the initial activity log so the dashboard has data immediately even
# before start.sh runs (start.sh refreshes it with the current date on boot).
"$REPO_ROOT/.cursor/gen-sample-log.sh"

echo "==> install.sh complete"
