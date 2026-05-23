#!/bin/bash
set -uo pipefail
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== db-server user-data started: $(date) ==="

# Retry helper — package mirrors via S3 endpoint can be briefly slow
retry() {
  local n=0 max=5
  until "$@"; do
    n=$((n+1))
    [ "$n" -ge "$max" ] && { echo "FAILED after $max attempts: $*"; return 1; }
    echo "retry $n/$max: $*"; sleep 10
  done
}

# Install MariaDB only — no full system update (faster, fewer failure points)
retry dnf install -y mariadb105-server

systemctl enable --now mariadb

echo "=== db-server user-data finished: $(date) ==="