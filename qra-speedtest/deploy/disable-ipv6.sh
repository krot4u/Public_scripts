#!/usr/bin/env bash
set -euo pipefail
# Applied on first client installation and by the explicit server installer.
install -d -m 0755 /etc/sysctl.d
printf '%s\n' 'net.ipv6.conf.all.disable_ipv6 = 1' 'net.ipv6.conf.default.disable_ipv6 = 1' > /etc/sysctl.d/90-qra-speedtest-ipv4.conf
sysctl -p /etc/sysctl.d/90-qra-speedtest-ipv4.conf >/dev/null
