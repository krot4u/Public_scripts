#!/usr/bin/env bash
set -euo pipefail
# Open only the measurement port to every IPv4 client, before every service start.
test "$#" = 1
python3 - "$1" <<'PY'
import sys
assert 1024 <= int(sys.argv[1]) <= 65535
PY
if ! iptables -w -nL QRA_SPEEDTEST >/dev/null 2>&1; then
    iptables -w -N QRA_SPEEDTEST
fi
iptables-restore -w --noflush <<EOF
*filter
-F QRA_SPEEDTEST
-A QRA_SPEEDTEST -j ACCEPT
COMMIT
EOF
for protocol in tcp udp; do
    if ! iptables -w -C INPUT -p "$protocol" --dport "$1" -j QRA_SPEEDTEST 2>/dev/null; then
        iptables -w -I INPUT 1 -p "$protocol" --dport "$1" -j QRA_SPEEDTEST
    fi
done
python3 - "$1" <<'PY'
import shlex, subprocess, sys
port = sys.argv[1]
rules = subprocess.check_output(['iptables', '-w', '-S', 'INPUT'], text=True)
for line in rules.splitlines():
    args = shlex.split(line)
    if args[:2] != ['-A', 'INPUT'] or '-j' not in args:
        continue
    if args[args.index('-j') + 1] != 'QRA_SPEEDTEST':
        continue
    if '--dport' in args and args[args.index('--dport') + 1] == port:
        continue
    subprocess.run(['iptables', '-w', '-D', 'INPUT', *args[2:]], check=True)
PY
