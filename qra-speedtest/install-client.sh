#!/usr/bin/env bash
set -euo pipefail

# Run from the complete, reviewed module directory on Pi-Star.
source_dir="$(cd "$(dirname "$0")" && pwd)"
test "$(id -u)" = 0 || { echo 'Запустите установщик от root.' >&2; exit 1; }
test "$#" = 2 || { echo 'Использование: install-client.sh HOST PORT' >&2; exit 1; }
python3 -c 'import sys; sys.exit(sys.version_info < (3, 7))'
command -v iperf3 >/dev/null
test -d /var/www/dashboard/admin
getent group www-data >/dev/null
python3 - "$1" "$2" <<'PY'
import socket, sys
socket.getaddrinfo(sys.argv[1], int(sys.argv[2]), socket.AF_INET)
assert 1024 <= int(sys.argv[2]) <= 65535, 'Порт должен быть 1024..65535'
PY
if ! id qra-speedtest >/dev/null 2>&1; then
    useradd --system --no-create-home --shell /usr/sbin/nologin qra-speedtest
fi
install -d -m 0755 /opt/qra-speedtest /var/www/dashboard/admin/qra-speedtest
install -m 0644 "$source_dir/agent.py" /opt/qra-speedtest/agent.py
for name in api.php widget.html widget.css widget.js quality.js; do
    install -m 0644 "$source_dir/web/$name" "/var/www/dashboard/admin/qra-speedtest/$name"
done
install -m 0644 "$source_dir/web/dashboard-button.php" /var/www/dashboard/qra-speedtest-button.php
python3 - "$1" "$2" <<'PY'
import json, os, socket, sys
path = '/etc/qra-speedtest.json'
with open(path + '.tmp', 'w') as stream:
    host = socket.getaddrinfo(sys.argv[1], int(sys.argv[2]), socket.AF_INET, socket.SOCK_STREAM)[0][4][0]
    json.dump({'host': host, 'port': int(sys.argv[2])}, stream)
os.chmod(path + '.tmp', 0o644)
os.replace(path + '.tmp', path)
PY
install -m 0755 "$source_dir/deploy/allow-client-port.py" /opt/qra-speedtest/allow-client-port.py
/opt/qra-speedtest/allow-client-port.py --install-hook
install -m 0644 "$source_dir/qra-speedtest.service" /etc/systemd/system/qra-speedtest.service
bash "$source_dir/deploy/disable-ipv6.sh"
systemctl daemon-reload
systemctl enable qra-speedtest.service
systemctl restart qra-speedtest.service
systemctl is-active --quiet qra-speedtest.service
echo 'Агент установлен. Дашборд должен содержать include qra-speedtest-button.php.'
