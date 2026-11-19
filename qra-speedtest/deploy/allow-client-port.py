#!/usr/bin/python3
"""Reapply the fixed endpoint's outbound rules from Pi-Star's IPv4 firewall hook."""
import argparse
import ipaddress
import json
from pathlib import Path
import shlex
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--install-hook', action='store_true')
    args = parser.parse_args()
    with open('/etc/qra-speedtest.json', encoding='utf-8') as stream:
        config = json.load(stream)
    host = str(ipaddress.IPv4Address(config['host']))
    port = int(config['port'])
    if not 1024 <= port <= 65535:
        raise ValueError('Invalid measurement port')
    if args.install_hook:
        install_hook()
    for protocol in ('tcp', 'udp'):
        rule = ['OUTPUT', '-d', host, '-p', protocol, '--dport', str(port),
                '-m', 'comment', '--comment', 'qra-speedtest-client', '-j', 'ACCEPT']
        if subprocess.run(['iptables', '-w', '-C', *rule],
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode:
            subprocess.run(['iptables', '-w', '-I', rule[0], '1', *rule[1:]], check=True)
    remove_old_rules(host, port)


def install_hook():
    path = Path('/root/ipv4.fw')
    text = path.read_text() if path.exists() else ''
    marker = '# QRA speedtest client'
    if marker in text:
        return
    backup = Path('/root/ipv4.fw.qra-speedtest-backup')
    if path.exists() and not backup.exists():
        shutil.copy2(path, backup)
    with path.open('a') as stream:
        stream.write('\n' + marker + ' — restore the endpoint after firewall reload.\n'
                     'if [ -x /opt/qra-speedtest/allow-client-port.py ]; then\n'
                     '    /opt/qra-speedtest/allow-client-port.py\nfi\n')


def remove_old_rules(host, port):
    rules = subprocess.check_output(['iptables', '-w', '-S', 'OUTPUT'], text=True)
    for line in rules.splitlines():
        args = shlex.split(line)
        if args[:2] != ['-A', 'OUTPUT'] or '--comment' not in args:
            continue
        if args[args.index('--comment') + 1] != 'qra-speedtest-client':
            continue
        network = ipaddress.IPv4Network(args[args.index('-d') + 1]) if '-d' in args else None
        if network == ipaddress.IPv4Network(host + '/32') and '--dport' in args:
            if args[args.index('--dport') + 1] == str(port):
                continue
        subprocess.run(['iptables', '-w', '-D', 'OUTPUT', *args[2:]], check=True)


if __name__ == '__main__':
    main()
