#!/bin/bash
#
# Script 2: Install Docker
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Installing Docker...${NC}"

if command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker already installed!${NC}"
    docker --version
    exit 0
fi

# Install Docker using official script
curl -fsSL https://get.docker.com | sh

# Add current user to docker group
if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
    echo -e "${GREEN}Added $SUDO_USER to docker group${NC}"
fi

# Verify installation
docker --version
docker compose version

echo -e "${GREEN}✓ Docker installed!${NC}"

