#!/usr/bin/env python3
"""Fixed-target iperf runner. Only the dashboard's Unix socket can start tests."""
import argparse
import copy
import json
import logging
import math
import os
import socket
import socketserver
import subprocess
import threading


PROFILES = {"tcp": (5, "10M", None), "udp": (5, "1M", 1200),
            "dmr": (12, "7333", 55)}


def command(binary, host, port, profile, direction):
    duration, bitrate, length = PROFILES[profile]
    args = [binary, "-4", "-c", host, "-p", str(port), "-J", "-t",
            str(duration), "-b", bitrate, "--connect-timeout", "3000"]
    if length:
        args += ["-u", "-l", str(length)]
    if direction == "download":
        args += ["-R"]
    return args


def result(document, profile, direction):
    if document.get("error"):
        raise ValueError("Сервер iperf3 отклонил тест или связь прервалась.")
    end = document["end"]
    # Receiver statistics matter: upload must use the server's report.
    summary = end.get("sum_received")
    if summary is None and profile != "tcp":
        summary = end.get("sum")
    if summary is None:
        raise ValueError("iperf3 не вернул статистику приёмника.")
    rate = float(summary["bits_per_second"])
    if not math.isfinite(rate) or rate < 0:
        raise ValueError("Некорректная скорость в ответе iperf3.")
    udp = profile != "tcp"
    return {"profile": profile, "direction": direction, "mbps": rate / 1e6,
            "jitter_ms": summary.get("jitter_ms") if udp else None,
            "lost_percent": summary.get("lost_percent") if udp else None,
            "packets": summary.get("packets") if udp else None}


class Runner:
    def __init__(self, binary, host, port):
        self.binary, self.host, self.port = binary, host, port
        self.lock = threading.Lock()
        self.state = {"status": "idle", "stage": "", "results": [], "error": None}

    def snapshot(self):
        with self.lock:
            return copy.deepcopy(self.state)

    def start(self):
        with self.lock:
            if self.state["status"] == "running":
                return False
            self.state = {"status": "running", "stage": "", "results": [], "error": None}
        threading.Thread(target=self.run, daemon=True).start()
        return True

    def run(self):
        try:
            # DNS is resolved once per run; force the data path to IPv4.
            host = socket.getaddrinfo(self.host, self.port, socket.AF_INET,
                                      socket.SOCK_STREAM)[0][4][0]
            for profile in PROFILES:
                for direction in ("upload", "download"):
                    with self.lock:
                        self.state["stage"] = profile + "_" + direction
                    process = subprocess.run(
                        command(self.binary, host, self.port, profile, direction),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                        timeout=PROFILES[profile][0] + 15, text=True, check=False)
                    if process.returncode:
                        raise ValueError("Тест не выполнен: проверьте доступность iperf3 и TCP/UDP-порта сервера.")
                    item = result(json.loads(process.stdout), profile, direction)
                    with self.lock:
                        self.state["results"].append(item)
            with self.lock:
                self.state["status"] = "done"
        except (OSError, ValueError, KeyError, TypeError, subprocess.TimeoutExpired) as error:
            logging.warning("Measurement failed (%s)", type(error).__name__)
            message = str(error) if isinstance(error, ValueError) and not isinstance(error, json.JSONDecodeError) else "Не удалось получить результат iperf3. Проверьте сервис и конфигурацию."
            with self.lock:
                self.state.update(status="error", error=message)


class Handler(socketserver.StreamRequestHandler):
    def handle(self):
        self.connection.settimeout(3)
        try:
            request = json.loads(self.rfile.readline(1024))
            action = request.get("action")
            if action not in ("state", "start"):
                response = {"error": "Неизвестное действие."}
            elif action == "start" and not self.server.runner.start():
                response = {"error": "Измерение уже выполняется.", "busy": True}
            else:
                response = {"server": "QRA-XLX", "state": self.server.runner.snapshot()}
            self.wfile.write((json.dumps(response, ensure_ascii=False) + "\n").encode())
        except (ValueError, OSError, AttributeError):
            return


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", default="/etc/qra-speedtest.json")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO)
    with open(args.config, encoding="utf-8") as stream:
        config = json.load(stream)
    runner = Runner(config.get("iperf", "/usr/bin/iperf3"), config["host"], int(config["port"]))
    path = config.get("socket", "/run/qra-speedtest/agent.sock")
    if os.path.exists(path):
        os.unlink(path)
    with socketserver.UnixStreamServer(path, Handler) as server:
        server.runner = runner
        os.chmod(path, 0o660)
        server.serve_forever()


if __name__ == "__main__":
    main()
