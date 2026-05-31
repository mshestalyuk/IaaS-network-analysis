#!/usr/bin/env bash
# ===========================================================================
# Etap 2 — Traffic generation orchestrator
# Runs all five traffic-type scripts in sequence and tees the output to a
# timestamped log file (useful evidence for the Etap 5 report).
#
# Run this on the BASTION, after starting the packet capture on the web server.
# ===========================================================================
set -uo pipefail
cd "$(dirname "$0")"
source ./config.sh

LOG="traffic-run-$(date +%Y%m%d-%H%M%S).log"

{
  echo "############################################################"
  echo "#  Etap 2 - Network Traffic Generation"
  echo "#  Started: $(date)"
  echo "#  Web target: ${WEB_PRIVATE_IP}   DB target: ${DB_PRIVATE_IP}"
  echo "############################################################"

  # Guard against an unconfigured config.sh
  if [[ "${WEB_PRIVATE_IP}" == *CHANGE_ME* || "${DB_PRIVATE_IP}" == *CHANGE_ME* ]]; then
    echo
    echo "ERROR: edit config.sh and set the real WEB_PRIVATE_IP / DB_PRIVATE_IP."
    exit 1
  fi

  for script in 01-http.sh 02-ssh.sh 03-dns.sh 04-icmp.sh 05-portscan.sh; do
    echo
    echo "------------------------------------------------------------"
    bash "./${script}"
    sleep 2
  done

  echo
  echo "############################################################"
  echo "#  All traffic generated. Finished: $(date)"
  echo "#  Now stop the capture on the web server (stop-capture.sh)."
  echo "############################################################"
} 2>&1 | tee "${LOG}"

echo
echo "[*] Full run log saved to: ${LOG}"