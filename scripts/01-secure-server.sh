#!/bin/bash
#
# Task 1: Secure Server
# - Install SSH key from repo
# - SSH hardening
# - Firewall setup
# - Fail2ban
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[1/6] Updating system...${NC}"
apt update && apt upgrade -y

echo -e "${BLUE}[2/6] Installing security packages...${NC}"
apt install -y ufw fail2ban unattended-upgrades

echo -e "${BLUE}[3/6] Installing SSH key...${NC}"
# Find the target user (whoever ran sudo, or root)
TARGET_USER="${SUDO_USER:-root}"
TARGET_HOME=$(eval echo ~$TARGET_USER)

mkdir -p "$TARGET_HOME/.ssh"
chmod 700 "$TARGET_HOME/.ssh"

# Copy authorized_keys from repo
if [ -f "$REPO_DIR/keys/authorized_keys" ]; then
    cat "$REPO_DIR/keys/authorized_keys" >> "$TARGET_HOME/.ssh/authorized_keys"
    # Remove duplicates
    sort -u "$TARGET_HOME/.ssh/authorized_keys" -o "$TARGET_HOME/.ssh/authorized_keys"
    chmod 600 "$TARGET_HOME/.ssh/authorized_keys"
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.ssh"
    echo -e "${GREEN}✓ SSH key installed for $TARGET_USER${NC}"
else
    echo -e "${YELLOW}⚠ No keys/authorized_keys found in repo${NC}"
fi

# Also install for root (needed for Dokku)
if [ "$TARGET_USER" != "root" ] && [ -f "$REPO_DIR/keys/authorized_keys" ]; then
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    cat "$REPO_DIR/keys/authorized_keys" >> /root/.ssh/authorized_keys
    sort -u /root/.ssh/authorized_keys -o /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo -e "${GREEN}✓ SSH key also installed for root (Dokku needs this)${NC}"
fi

echo -e "${BLUE}[4/6] Configuring SSH...${NC}"
cat > /etc/ssh/sshd_config.d/99-security.conf << 'EOF'
# Allow root login with SSH key only (needed for Dokku git push)
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
X11Forwarding no
LoginGraceTime 30
MaxAuthTries 3
EOF
systemctl restart ssh

echo -e "${BLUE}[5/6] Configuring firewall...${NC}"
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp    # HTTP (Dokku/nginx)
ufw allow 443/tcp   # HTTPS
ufw --force enable

echo -e "${BLUE}[6/6] Configuring fail2ban...${NC}"
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
maxretry = 3
bantime = 24h
EOF
systemctl enable fail2ban
systemctl restart fail2ban

echo -e "${GREEN}✓ Server secured!${NC}"
