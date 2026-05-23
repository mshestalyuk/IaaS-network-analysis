#!/usr/bin/env bash
# ===========================================================================
# Etap 2 — HTTP / HTTPS traffic
# Generates web traffic from the bastion towards the web server.
# Maps to: "Ruch HTTP/HTTPS - prosty web server (nginx) + zapytania curl/ab"
# ===========================================================================
set -uo pipefail
cd "$(dirname "$0")"
source ./config.sh

echo "=== [HTTP/HTTPS] traffic generation ==="

echo "[*] Plain HTTP GET requests to web server (port 80)"
for i in $(seq 1 5); do
  curl -s -o /dev/null -w "    request $i  ->  HTTP %{http_code}  (%{time_total}s)\n" \
    "http://${WEB_PRIVATE_IP}/"
done

echo
echo "[*] HTTP load test with ApacheBench — 100 requests, concurrency 10"
ab -n 100 -c 10 "http://${WEB_PRIVATE_IP}/" 2>/dev/null \
  | grep -E "Complete requests|Failed requests|Requests per second|Transfer rate" \
  | sed 's/^/    /'

echo
echo "[*] HTTPS request to an external site (encrypted — TLS handshake in pcap)"
curl -s -o /dev/null -w "    https://example.com  ->  HTTP %{http_code}\n" \
  https://example.com/ || echo "    (external HTTPS failed)"

echo
echo "[*] HTTPS attempt to web server (port 443 open in SG, no TLS listener)"
curl -s -o /dev/null -w "    https://${WEB_PRIVATE_IP}  ->  %{http_code}\n" \
  --max-time 5 "https://${WEB_PRIVATE_IP}/" 2>/dev/null \
  || echo "    connection refused / timeout  (expected — no HTTPS service)"

echo "=== [HTTP/HTTPS] done ==="