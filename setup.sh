#!/bin/bash
#
# Bootstrap script - installs Task and runs setup
#
# Usage: curl -fsSL .../setup.sh | sudo bash
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

# Clone repo if running via curl pipe
if [ ! -f "Taskfile.yaml" ]; then
    echo "Cloning deployment repo..."
    git clone https://github.com/YOUR_USERNAME/deployment.git /tmp/deployment
    cd /tmp/deployment
fi

echo ""
echo "Run tasks with:"
echo "  sudo task --list       # Show all tasks"
echo "  sudo task status       # Check progress"
echo "  sudo task all          # Run all tasks"
echo "  sudo task 1-secure     # Run specific task"
echo ""

# Run all tasks
exec task all
