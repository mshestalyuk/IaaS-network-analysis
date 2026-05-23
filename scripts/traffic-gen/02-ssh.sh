#!/usr/bin/env bash
# ===========================================================================
# Etap 2 — SSH traffic
# Opens SSH sessions from the bastion to the web and db servers.
# Maps to: "Ruch SSH - sesje administracyjne miedzy instancjami"
#
# REQUIRES SSH agent forwarding. Connect to the bastion with -A:
#   ssh -A -i ~/.ssh/id_ed25519 ec2-user@<BASTION_PUBLIC_IP>
# so your key is available on the bastion for the onward hops.
# ===========================================================================
set -uo pipefail
cd "$(dirname "$0")"
source ./config.sh

echo "=== [SSH] traffic generation ==="

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes"

echo "[*] SSH sessions to WEB server (${WEB_PRIVATE_IP})"
for cmd in "hostname" "uptime" "df -h /" "id"; do
  out=$(ssh $SSH_OPTS "ec2-user@${WEB_PRIVATE_IP}" "$cmd" 2>/dev/null) \
    && echo "    web \$ $cmd  ->  $out" \
    || echo "    web \$ $cmd  ->  FAILED (check 'ssh -A' agent forwarding)"
done

echo
echo "[*] SSH sessions to DB server (${DB_PRIVATE_IP}, private subnet)"
for cmd in "hostname" "systemctl is-active mariadb"; do
  out=$(ssh $SSH_OPTS "ec2-user@${DB_PRIVATE_IP}" "$cmd" 2>/dev/null) \
    && echo "    db  \$ $cmd  ->  $out" \
    || echo "    db  \$ $cmd  ->  FAILED (check agent forwarding)"
done

echo "=== [SSH] done ==="