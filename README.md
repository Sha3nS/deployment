# VPS Deployment Scripts

Task-based setup for a secure VPS with Coolify + Cloudflare Access (Google Login).

Uses [Task](https://taskfile.dev/) - tracks progress and resumes from where you left off.

## Tasks

| Task | Command | Description |
|------|---------|-------------|
| 1 | `task 1-secure` | Secure server (SSH, firewall, fail2ban) |
| 2 | `task 2-docker` | Install Docker |
| 3 | `task 3-coolify` | Install Coolify |
| 4 | `task 4-tunnel` | Setup Cloudflare Tunnel |

## Prerequisites

- Fresh VPS (Ubuntu 22.04 or 24.04)
- Domain pointed to Cloudflare
- Cloudflare account (free)

## Quick Start

```bash
# SSH into your VPS (first time with password or provider console)
ssh ubuntu@YOUR_VPS_IP

# Clone and run
git clone https://github.com/YOUR_USERNAME/deployment.git
cd deployment
sudo ./setup.sh    # Installs Task, runs all tasks
```

Your SSH key is included in `keys/authorized_keys` - it gets installed automatically.

## Usage

```bash
sudo task --list       # Show all tasks
sudo task status       # Check progress
sudo task all          # Run all remaining tasks
sudo task 1-secure     # Run specific task
sudo task reset        # Start over
sudo task lockdown     # Close port 8000 after tunnel works
```

**Tasks are skipped if already complete.** If something fails, fix it and run `task all` again.

## After Automated Setup

1. **Configure Cloudflare Tunnel hostname** in dashboard
2. **Setup Cloudflare Access** - see `docs/cloudflare-access.md`  
3. **Lock down**: `sudo task lockdown`

## File Structure

```
deployment/
├── Taskfile.yaml               # Task definitions (taskfile.dev)
├── setup.sh                    # Bootstrap script (installs Task, runs all)
├── keys/
│   └── authorized_keys         # Your SSH public key (auto-installed)
├── scripts/
│   ├── 01-secure-server.sh     # SSH key + hardening, firewall, fail2ban
│   ├── 02-install-docker.sh    # Docker installation
│   ├── 03-install-coolify.sh   # Coolify installation
│   └── 04-setup-cloudflare-tunnel.sh  # Cloudflare Tunnel
└── docs/
    ├── cloudflare-access.md    # Google Login setup guide
    └── troubleshooting.md      # Common issues
```

## Security Features

- ✅ SSH key-only authentication (no passwords)
- ✅ Root login disabled
- ✅ UFW firewall enabled
- ✅ Fail2ban blocks brute force
- ✅ Automatic security updates
- ✅ No open ports (Cloudflare Tunnel)
- ✅ Google OAuth via Cloudflare Access

## Supported VPS Providers

| Provider | Tested | Notes |
|----------|--------|-------|
| AWS Lightsail | ✅ | Recommended for Singapore |
| Vultr | ✅ | Good alternative |
| Hetzner | ✅ | Best value (US/EU) |
| DigitalOcean | ✅ | Works well |
| Linode | ✅ | Works well |

## After Setup

1. Access Coolify at `https://coolify.yourdomain.com`
2. Login with Google (via Cloudflare Access)
3. Connect your GitHub repo
4. Deploy your apps!

## License

MIT

