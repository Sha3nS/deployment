#!/bin/bash
#
# Script 3: Install Coolify
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Installing Coolify...${NC}"

# Install Coolify
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

echo -e "${GREEN}✓ Coolify installed!${NC}"
echo ""
echo "Access Coolify at: http://$SERVER_IP:8000"
echo ""
echo "Next steps:"
echo "1. Create your admin account"
echo "2. Enable 2FA in your profile"
echo "3. Setup Cloudflare Tunnel for secure access"

