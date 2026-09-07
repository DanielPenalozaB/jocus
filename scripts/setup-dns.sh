#!/bin/bash
# Sets up local DNS so all devices on the network can resolve *.jocus.local
# Requires: Homebrew
# Usage: ./scripts/setup-dns.sh

set -e

LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")

if [ -z "$LOCAL_IP" ]; then
  echo "Error: Could not detect local IP. Are you connected to WiFi?"
  exit 1
fi

echo "Your local IP: $LOCAL_IP"
echo ""

# Install dnsmasq
if ! command -v dnsmasq &> /dev/null; then
  echo "Installing dnsmasq..."
  brew install dnsmasq
else
  echo "✓ dnsmasq already installed"
fi

# Configure dnsmasq
DNSMASQ_CONF="$(brew --prefix)/etc/dnsmasq.conf"

echo "Configuring dnsmasq..."
cat > "$DNSMASQ_CONF" << EOF
# Jocus - resolve *.jocus.local to this machine
address=/jocus.local/$LOCAL_IP

# Forward everything else to upstream DNS
server=8.8.8.8
server=8.8.4.4

# Listen on all interfaces (so other devices can use this as DNS)
listen-address=0.0.0.0

# Don't read /etc/resolv.conf
no-resolv
EOF

echo "✓ Config written to $DNSMASQ_CONF"

# Start dnsmasq service
echo "Starting dnsmasq..."
sudo brew services restart dnsmasq

echo ""
echo "✓ DNS server running on $LOCAL_IP:53"
echo ""
echo "Verify it works:"
echo "  dig @$LOCAL_IP jocus.local +short"
echo ""
echo "To use on other devices, set DNS to: $LOCAL_IP"
echo ""
echo "  Android: Settings → Wi-Fi → long-press network → Modify → Advanced"
echo "           → IP settings: Static → DNS 1: $LOCAL_IP"
echo ""
echo "  iOS:     Settings → Wi-Fi → tap (i) on network → Configure DNS"
echo "           → Manual → add $LOCAL_IP as the only server"
echo ""
echo "  Router:  Set $LOCAL_IP as the DNS server — all devices get it automatically"
echo ""
