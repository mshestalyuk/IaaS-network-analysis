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

# Traffic-generation 
retry dnf install -y \
  nmap \
  bind-utils \
  httpd-tools \
  tcpdump \
  curl \
  iputils \
  traceroute \
  net-tools

echo "=== bastion user-data finished: $(date) ==="