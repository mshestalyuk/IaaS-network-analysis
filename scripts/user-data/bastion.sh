#!/bin/bash
set -uo pipefail
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== bastion user-data started: $(date) ==="

retry() {
  local n=0 max=5
  until "$@"; do
    n=$((n+1))
    [ "$n" -ge "$max" ] && { echo "FAILED after $max attempts: $*"; return 1; }
    echo "retry $n/$max: $*"; sleep 10
  done
}

# Traffic-generation + analysis toolkit for Etap 2/3.
# Note: curl is already present (curl-minimal); do NOT add "curl" — it conflicts.
retry dnf install -y \
  nmap \
  bind-utils \
  httpd-tools \
  tcpdump \
  traceroute

echo "=== bastion user-data finished: $(date) ==="