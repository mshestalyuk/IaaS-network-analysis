#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Target configuration for Etap 2 — network traffic generation.
# Fill these in BEFORE running any script.
#
# Get the values from your WSL machine:
#   cd environments/lab/ec2 && terragrunt output
#
# Use PRIVATE IPs — instance-to-instance traffic then stays inside the VPC
# and is recorded by VPC Flow Logs as intra-VPC traffic ("ruch miedzy
# instancjami" in the project brief).
# ---------------------------------------------------------------------------

# Web server — private IP. Primary traffic target and the tcpdump capture host.
WEB_PRIVATE_IP="10.0.1.155"

# Database server — private IP (lives in the private subnet).
DB_PRIVATE_IP="10.0.2.103"

# External host for internet-path traffic (DNS / ICMP). 8.8.8.8 is fine.
EXTERNAL_HOST="8.8.8.8"