#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y httpd
systemctl enable --now httpd

cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html><body>
<h1>Security Lab — Web Server</h1>
<p>Instance is running.</p>
</body></html>
HTML
