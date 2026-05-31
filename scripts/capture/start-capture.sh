#!/usr/bin/env bash
# ===========================================================================
# Etap 3 — Start packet capture
# Runs on an EC2 instance (primary: the WEB server). Starts tcpdump in the
# background, writing a .pcap file.
# Maps to: "tcpdump na instancjach EC2 - zapis plikow .pcap"
#
# Usage:   ./start-capture.sh [output.pcap]
# ===========================================================================
set -uo pipefail

PCAP_FILE="${1:-/tmp/capture-$(date +%Y%m%d-%H%M%S).pcap}"
PID_FILE="/tmp/tcpdump.pid"

# tcpdump is not in the base AL2023 image — install on demand.
if ! command -v tcpdump >/dev/null 2>&1; then
  echo "[*] tcpdump not found — installing..."
  sudo dnf install -y tcpdump
fi

# Refuse to start a second capture on top of a running one.
if [ -f "$PID_FILE" ] && sudo kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "[!] A capture is already running (PID $(cat "$PID_FILE"))."
  echo "[!] Stop it first with stop-capture.sh"
  exit 1
fi

echo "[*] Starting packet capture on all interfaces"
echo "[*] Output file: ${PCAP_FILE}"

# -i any  : all interfaces      -n : no name resolution
# -s 0    : full packet payload -w : write raw pcap
sudo nohup tcpdump -i any -n -s 0 -w "${PCAP_FILE}" >/tmp/tcpdump.log 2>&1 &
CAP_PID=$!

echo "${CAP_PID}"  | sudo tee "${PID_FILE}"        >/dev/null
echo "${PCAP_FILE}" | sudo tee /tmp/tcpdump.current >/dev/null
sleep 1

if sudo kill -0 "${CAP_PID}" 2>/dev/null; then
  echo "[*] Capture running (PID ${CAP_PID})."
  echo "[*] Generate traffic now, then run ./stop-capture.sh"
else
  echo "[!] tcpdump failed to start — check /tmp/tcpdump.log"
  exit 1
fi