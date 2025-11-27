#!/bin/bash
#
# Task 4: Setup Cloudflare Tunnel
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Setting up Cloudflare Tunnel...${NC}"

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo -e "${BLUE}Installing cloudflared...${NC}"
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list
    apt update
    apt install -y cloudflared
fi

echo -e "${GREEN}✓ cloudflared installed!${NC}"
echo ""

# Check if tunnel is already configured
if systemctl is-active --quiet cloudflared 2>/dev/null; then
    echo -e "${GREEN}Cloudflare Tunnel is already running!${NC}"
    systemctl status cloudflared --no-pager
    exit 0
fi

echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Get Your Tunnel Token${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "1. Go to: https://one.dash.cloudflare.com"
echo "2. Navigate to: Networks → Tunnels → Create a tunnel"
echo "3. Choose 'Cloudflared' as connector"
echo "4. Name it (e.g., 'dokku-tunnel')"
echo "5. Copy the token (starts with 'eyJ...')"
echo ""

read -p "Do you have your tunnel token ready? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    read -p "Paste your tunnel token: " TUNNEL_TOKEN
    
    if [[ -z "$TUNNEL_TOKEN" ]]; then
        echo -e "${RED}No token provided. Run this script again when you have your token.${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${BLUE}Installing tunnel service...${NC}"
    cloudflared service install "$TUNNEL_TOKEN"
    
    echo ""
    echo -e "${GREEN}✓ Cloudflare Tunnel service installed!${NC}"
    echo ""
    systemctl status cloudflared --no-pager
    echo ""
    echo -e "${YELLOW}Next steps - Add hostnames in Cloudflare Dashboard:${NC}"
    echo ""
    echo "  Subdomain              Service"
    echo "  ─────────────────────  ─────────────────────"
    echo "  app.yourdomain.com     http://localhost:80"
    echo "  api.yourdomain.com     http://localhost:80"
    echo ""
    echo "All domains point to localhost:80 - Dokku routes by hostname."
    echo ""
else
    echo ""
    echo -e "${YELLOW}No problem! Run this script again when you have your token.${NC}"
    echo ""
    echo "Or install manually:"
    echo -e "  ${GREEN}sudo cloudflared service install YOUR_TOKEN${NC}"
fi

echo ""
echo -e "${BLUE}Cloudflare Tunnel provides:${NC}"
echo "  ✓ No open ports needed (can close 80/443 in firewall)"
echo "  ✓ DDoS protection"
echo "  ✓ Free SSL certificates"
echo "  ✓ Hides your server IP"
echo "  ✓ Cloudflare Access for authentication"
