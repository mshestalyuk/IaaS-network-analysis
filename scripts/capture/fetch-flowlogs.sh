#!/usr/bin/env bash
# ===========================================================================
# Etap 3 — Fetch VPC Flow Logs
# Pulls the VPC Flow Log records from CloudWatch Logs to a local text file.
# Maps to: "VPC Flow Logs - zbieranie metadanych ruchu"
#
# RUN THIS ON YOUR WSL MACHINE (not on an EC2 instance) — it uses your local
# AWS credentials. The EC2 instances have no IAM role for CloudWatch.
#
# Usage:   ./fetch-flowlogs.sh [output.txt] [minutes-back]
# ===========================================================================
set -uo pipefail

LOG_GROUP="/vpc/flow-logs/security-lab"
REGION="eu-central-1"
OUT_FILE="${1:-flowlogs-$(date +%Y%m%d-%H%M%S).txt}"
MINUTES_BACK="${2:-60}"

START_MS=$(( ( $(date +%s) - MINUTES_BACK * 60 ) * 1000 ))

echo "[*] Log group : ${LOG_GROUP}"
echo "[*] Region    : ${REGION}"
echo "[*] Window    : last ${MINUTES_BACK} min"

aws logs filter-log-events \
  --region "${REGION}" \
  --log-group-name "${LOG_GROUP}" \
  --start-time "${START_MS}" \
  --query 'events[].message' \
  --output text \
  | tr '\t' '\n' > "${OUT_FILE}"

LINES=$(grep -c . "${OUT_FILE}" 2>/dev/null || echo 0)
echo "[*] Saved ${LINES} flow records  ->  ${OUT_FILE}"

if [ "${LINES}" -gt 0 ]; then
  echo
  echo "[*] Quick summary (field 13 = action):"
  echo "    ACCEPT : $(grep -c ' ACCEPT '  "${OUT_FILE}" || true)"
  echo "    REJECT : $(grep -c ' REJECT '  "${OUT_FILE}" || true)"
  echo
  echo "[*] Top 10 destination ports:"
  awk '{print $7}' "${OUT_FILE}" | sort -n | uniq -c | sort -rn | head -10 \
    | sed 's/^/    /'
fi

echo
echo "[*] Flow Log record format (space-separated):"
echo "    version account-id interface-id srcaddr dstaddr srcport dstport"
echo "    protocol packets bytes start end ACTION log-status"