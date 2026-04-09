#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y mariadb105-server
systemctl enable --now mariadb
