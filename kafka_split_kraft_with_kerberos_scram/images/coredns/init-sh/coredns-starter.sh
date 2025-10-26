#!/bin/bash
set -e

echo "Starting CoreDNS..."
echo "Configuration file: /etc/coredns/Corefile"
echo "Zone files:"
ls -la /etc/coredns/*.db 2>/dev/null || echo "No zone files found"

/usr/local/bin/coredns -conf=/etc/coredns/Corefile -plugins 2>/dev/null || {
    echo "Configuration validation failed!"
    exit 1
}

/usr/local/bin/coredns -conf=/etc/coredns/Corefile