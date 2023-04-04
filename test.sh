#!/usr/bin/env python

import wiringpi
import subprocess
import time
import daemon

# Set up the GPIO pin
PIN = 8
wiringpi.wiringPiSetup()
wiringpi.pinMode(PIN, wiringpi.GPIO.INPUT)

# Define a list of commands to execute
commands = [
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_1.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_2.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_3.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_4.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_5.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_6.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_7.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_8.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_9.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_10.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_11.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_12.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_13.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_14.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_15.cfg.unix',
    'kill -9 $(cat /var/run/frnclient.pid) && /opt/alterfrn/FRNClientConsole.Linux-aarch64.r7312 run channel_16.cfg.unix',
]

# Define a flag to keep track of whether a command has already been executed
command_executed = False

# Define a function that listens for changes on the GPIO pin
def listen_for_gpio():
    while True:
        # Get the current state of the pin
        state = wiringpi.digitalRead(PIN)

        # Execute a command if the pin is set to high and a command has not already been executed
        if state == wiringpi.GPIO.HIGH and not command_executed:
            command = commands.pop(0)
            subprocess.call(command, shell=True)
            command_executed = True

        # Reset the flag if the pin is set to low
        if state == wiringpi.GPIO.LOW:
            command_executed = False

        # Sleep for a short period of time to avoid excessive CPU usage
        time.sleep(0.1)

# Run the function as a daemon
with daemon.DaemonContext():
    listen_for_gpio()