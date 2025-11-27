#!/bin/bash
#
# Task 3: Install Dokku
# - Install Dokku
# - Configure global domain
# - Install useful plugins
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Installing Dokku...${NC}"

# Check if Dokku is already installed
if command -v dokku &> /dev/null; then
    echo -e "${GREEN}Dokku already installed!${NC}"
    dokku version
    exit 0
fi

echo -e "${BLUE}[1/4] Downloading Dokku...${NC}"
wget -NP . https://dokku.com/install/v0.34.8/bootstrap.sh

echo -e "${BLUE}[2/4] Installing Dokku (this takes ~5 minutes)...${NC}"
DOKKU_TAG=v0.34.8 bash bootstrap.sh

# Clean up
rm -f bootstrap.sh

echo -e "${BLUE}[3/4] Installing SSH key for Dokku deployments...${NC}"
# Add SSH key from repo to Dokku
if [ -f "$REPO_DIR/keys/authorized_keys" ]; then
    # Get the first key from authorized_keys
    KEY=$(head -1 "$REPO_DIR/keys/authorized_keys")
    if [ -n "$KEY" ]; then
        echo "$KEY" | dokku ssh-keys:add admin || true
        echo -e "${GREEN}✓ SSH key added to Dokku${NC}"
    fi
else
    echo -e "${YELLOW}⚠ No keys/authorized_keys found. Add key manually:${NC}"
    echo "  cat ~/.ssh/id_ed25519.pub | dokku ssh-keys:add admin"
fi

echo -e "${BLUE}[4/4] Installing Dokku plugins...${NC}"

# Let's Encrypt for SSL (optional - you use Cloudflare)
echo -e "${BLUE}  - Installing Let's Encrypt plugin...${NC}"
dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git || true

# Postgres
echo -e "${BLUE}  - Installing Postgres plugin...${NC}"
dokku plugin:install https://github.com/dokku/dokku-postgres.git || true

# Redis
echo -e "${BLUE}  - Installing Redis plugin...${NC}"
dokku plugin:install https://github.com/dokku/dokku-redis.git || true

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Dokku Installed Successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Set your global domain:"
echo -e "   ${GREEN}dokku domains:set-global yourdomain.com${NC}"
echo ""
echo "2. Create your first app:"
echo -e "   ${GREEN}dokku apps:create myapp${NC}"
echo ""
echo "3. Deploy from your local machine:"
echo -e "   ${GREEN}git remote add dokku dokku@YOUR_VPS_IP:myapp${NC}"
echo -e "   ${GREEN}git push dokku main${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  dokku apps:list              # List all apps"
echo "  dokku logs myapp             # View app logs"
echo "  dokku config:set myapp K=V   # Set env vars"
echo "  dokku ps:report              # Show all app status"
echo ""

