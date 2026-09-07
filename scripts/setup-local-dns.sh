#!/bin/bash
# Sets up local DNS resolution for jocus.local
# Other devices on the same network can access the app using your machine's IP.
#
# On macOS: this uses /etc/hosts (this machine only).
# For other devices on the network, they need to either:
#   1. Add an entry in their /etc/hosts pointing jocus.local → your IP
#   2. Or simply use your machine's IP address directly (e.g., http://192.168.1.X)
#
# Usage: sudo ./scripts/setup-local-dns.sh

set -e

DOMAIN="jocus.local"
DOMAINS="$DOMAIN api.$DOMAIN assets.$DOMAIN minio.$DOMAIN"

# Get local IP
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "127.0.0.1")

echo "Your local IP: $LOCAL_IP"
echo ""

# Add entries to /etc/hosts
for d in $DOMAINS; do
  if grep -q "$d" /etc/hosts 2>/dev/null; then
    echo "✓ $d already in /etc/hosts"
  else
    echo "$LOCAL_IP    $d" >> /etc/hosts
    echo "✓ Added $d → $LOCAL_IP"
  fi
done

echo ""
echo "Done! Access the app at:"
echo "  Frontend:  http://$DOMAIN"
echo "  API:       http://api.$DOMAIN"
echo "  Assets:    http://assets.$DOMAIN"
echo "  Minio UI:  http://minio.$DOMAIN"
echo "  Traefik:   http://$DOMAIN:8080"
echo ""
echo "For other devices on the network, they can access via:"
echo "  http://$LOCAL_IP (if Traefik is configured for IP access)"
echo "  OR add these lines to their /etc/hosts file:"
for d in $DOMAINS; do
  echo "    $LOCAL_IP    $d"
done
