#!/bin/bash
#
# Bootstrap script - installs Task and shows instructions
#
# Usage: 
#   git clone ... && cd deployment && sudo ./setup.sh
#

set -e

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install Task if not present
if ! command -v task &> /dev/null; then
    echo "Installing Task (taskfile.dev)..."
    sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
fi

# Check we're in the right directory
if [ ! -f "Taskfile.yaml" ]; then
    echo "Error: Taskfile.yaml not found."
    echo "Please run this from the deployment directory."
    exit 1
fi

echo ""
echo "========================================"
echo "  VPS Deployment Setup"
echo "========================================"
echo ""
echo "Task runner installed. Run the setup with:"
echo ""
echo "  sudo task all          # Run all tasks"
echo ""
echo "Or run individual tasks:"
echo ""
echo "  sudo task 1-secure     # Secure server"
echo "  sudo task 2-docker     # Install Docker"
echo "  sudo task 3-dokku      # Install Dokku"
echo "  sudo task 4-tunnel     # Setup Cloudflare Tunnel"
echo ""
echo "Other commands:"
echo ""
echo "  sudo task status       # Check progress"
echo "  sudo task --list       # Show all tasks"
echo "  sudo task show-ip      # Show IP for Binance whitelist"
echo ""
