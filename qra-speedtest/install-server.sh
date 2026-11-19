#!/usr/bin/env bash
set -euo pipefail
source_dir="$(cd "$(dirname "$0")" && pwd)"
test "$(id -u)" = 0 || { echo 'Запустите установщик от root.' >&2; exit 1; }
test "$#" = 2 || { echo 'Использование: install-server.sh BIND_IPV4 PORT' >&2; exit 1; }
python3 - "$1" "$2" <<'PY'
import ipaddress, sys
ipaddress.IPv4Address(sys.argv[1])
assert 1024 <= int(sys.argv[2]) <= 65535, 'Порт должен быть 1024..65535'
PY
iperf_bin="${IPERF_BIN:-/usr/bin/iperf3}"
test -x "$iperf_bin"
command -v iptables >/dev/null
command -v iptables-restore >/dev/null
iperf_help="$("$iperf_bin" --help)"
for option in server-max-duration server-bitrate-limit idle-timeout; do
    [[ "$iperf_help" == *"--$option"* ]] || { echo "iperf3 не поддерживает --$option; обновите пакет." >&2; exit 1; }
done
printf 'BIND_ADDRESS=%s\nPORT=%s\nIPERF_BIN=%s\n' "$1" "$2" "$iperf_bin" > /etc/qra-speedtest-server.conf
chmod 0644 /etc/qra-speedtest-server.conf
install -d -m 0755 /opt/qra-speedtest
install -m 0755 "$source_dir/deploy/open-server-port.sh" /opt/qra-speedtest/open-server-port.sh
install -m 0644 "$source_dir/qra-speedtest-server.service" /etc/systemd/system/qra-speedtest-server.service
bash "$source_dir/deploy/disable-ipv6.sh"
systemctl daemon-reload
systemctl enable qra-speedtest-server.service
systemctl restart qra-speedtest-server.service
systemctl is-active --quiet qra-speedtest-server.service
