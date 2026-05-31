#!/usr/bin/env bash
# ===========================================================================
# Etap 3 — Stop packet capture
# Stops the tcpdump started by start-capture.sh and reports on the .pcap.
# Run on the same instance where the capture was started.
# ===========================================================================
set -uo pipefail

PID_FILE="/tmp/tcpdump.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "[!] No PID file found — no capture appears to be running."
  exit 1
fi

PID=$(cat "$PID_FILE")
echo "[*] Stopping capture (PID ${PID})"
sudo kill "${PID}" 2>/dev/null || echo "[!] Process already gone."
sleep 1
sudo rm -f "$PID_FILE"

PCAP=$(sudo cat /tmp/tcpdump.current 2>/dev/null || echo "")
if [ -n "$PCAP" ] && [ -f "$PCAP" ]; then
  # Hand ownership to ec2-user so it can be scp'd off without sudo.
  sudo chown ec2-user:ec2-user "$PCAP"
  PKTS=$(sudo tcpdump -r "$PCAP" 2>/dev/null | wc -l)
  echo "[*] Capture file : ${PCAP}"
  echo "[*] Size         : $(du -h "$PCAP" | cut -f1)"
  echo "[*] Packets      : ${PKTS}"
  echo
  echo "[*] Copy it to your machine (run this FROM your WSL terminal):"
  echo "    scp -i ~/.ssh/id_ed25519 -o ProxyJump=ec2-user@<BASTION_IP> \\"
  echo "        ec2-user@<THIS_HOST_PRIVATE_IP>:${PCAP} ./"
else
  echo "[!] Could not locate the pcap file."
fi