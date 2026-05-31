#!/bin/bash
set -uo pipefail
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== web-server user-data started: $(date) ==="

retry() {
  local n=0 max=5
  until "$@"; do
    n=$((n+1))
    [ "$n" -ge "$max" ] && { echo "FAILED after $max attempts: $*"; return 1; }
    echo "retry $n/$max: $*"; sleep 10
  done
}

retry dnf install -y httpd
systemctl enable --now httpd

cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html><body>
<h1>Security Lab — Web Server</h1>
<p>Instance is running.</p>
</body></html>
HTML

echo "=== web-server user-data finished: $(date) ==="