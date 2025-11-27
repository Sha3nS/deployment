# VPS Deployment Scripts

Task-based setup for a secure VPS with **Dokku** + **Cloudflare Tunnel**.

Deploy apps with `git push`. Simple, stable, Heroku-like experience.

## Why Dokku?

| Feature | Dokku |
|---------|-------|
| Deploy | `git push dokku main` |
| Stability | 12+ years, rock solid |
| SSL | Automatic (Cloudflare or Let's Encrypt) |
| Databases | `dokku postgres:create db` |
| Env vars | `dokku config:set app KEY=value` |
| Logs | `dokku logs app` |
| Static IP | ✅ For Binance API whitelist |

## Tasks

| Task | Command | Description |
|------|---------|-------------|
| 1 | `task 1-secure` | Secure server (SSH, firewall, fail2ban) |
| 2 | `task 2-docker` | Install Docker |
| 3 | `task 3-dokku` | Install Dokku |
| 4 | `task 4-tunnel` | Setup Cloudflare Tunnel |

## Prerequisites

- Fresh VPS (Ubuntu 22.04 or 24.04)
- Domain pointed to Cloudflare
- Cloudflare account (free)

## Quick Start

```bash
# SSH into your VPS
ssh ubuntu@YOUR_VPS_IP

# Clone and run
git clone https://github.com/YOUR_USERNAME/deployment.git
cd deployment
sudo ./setup.sh
```

Your SSH key is included in `keys/authorized_keys` - it gets installed automatically.

## Usage

```bash
sudo task --list       # Show all tasks
sudo task status       # Check progress
sudo task all          # Run all remaining tasks
sudo task 1-secure     # Run specific task
sudo task reset        # Start over
```

**Tasks are skipped if already complete.** If something fails, fix it and run `task all` again.

## Deploy Your First App

After setup is complete:

### 1. Create app on server

```bash
dokku apps:create myapp
dokku domains:add myapp myapp.yourdomain.com
```

### 2. Add Cloudflare Tunnel route

In Cloudflare Dashboard → Zero Trust → Tunnels → Your tunnel:
- Add hostname: `myapp.yourdomain.com` → `http://localhost:80`

### 3. Deploy from local machine

```bash
cd your-project
git remote add dokku dokku@YOUR_VPS_IP:myapp
git push dokku main
```

Done! Your app is live at `https://myapp.yourdomain.com`

## For Python Workers (No Web)

For background scripts like your TG bot:

```bash
# Create Procfile in your repo
echo "worker: python3 main.py config/config.json" > Procfile

# After deploy, scale
dokku ps:scale myapp web=0 worker=1
```

## Environment Variables

```bash
# Set env vars
dokku config:set myapp API_KEY=xxx TG_TOKEN=yyy

# View env vars
dokku config:show myapp
```

## Databases

```bash
# Create Postgres database
dokku postgres:create mydb

# Link to app
dokku postgres:link mydb myapp

# DATABASE_URL is automatically set
```

## Useful Commands

```bash
# Apps
dokku apps:list                    # List all apps
dokku apps:destroy myapp           # Delete app

# Deployment
dokku ps:report                    # Status of all apps
dokku ps:restart myapp             # Restart app
dokku ps:scale myapp web=2         # Scale to 2 instances

# Logs
dokku logs myapp                   # View logs
dokku logs myapp --tail            # Follow logs

# Domains
dokku domains:report myapp         # Show app domains
dokku domains:add myapp new.com    # Add domain
```

## File Structure

```
deployment/
├── Taskfile.yaml               # Task definitions
├── setup.sh                    # Bootstrap script
├── keys/
│   └── authorized_keys         # Your SSH public key
├── scripts/
│   ├── 01-secure-server.sh     # SSH hardening, firewall
│   ├── 02-install-docker.sh    # Docker installation
│   ├── 03-install-dokku.sh     # Dokku installation
│   └── 04-setup-cloudflare-tunnel.sh
└── docs/
    ├── cloudflare-access.md    # Google Login setup
    └── troubleshooting.md
```

## Lightsail Firewall

If using AWS Lightsail, open these ports:

| Port | Purpose |
|------|---------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |

## Security Features

- ✅ SSH key-only authentication
- ✅ Root login with key only (for Dokku)
- ✅ UFW firewall enabled
- ✅ Fail2ban blocks brute force
- ✅ Automatic security updates
- ✅ Cloudflare Tunnel (no exposed ports)
- ✅ Static IP for API whitelisting

## Static IP for Binance

Your VPS has a static outbound IP. Use it for Binance API whitelist:

```bash
sudo task show-ip
```

## Troubleshooting

### Deploy fails with "Permission denied"

```bash
# Check your SSH key is added to Dokku
dokku ssh-keys:list

# Add your key
cat ~/.ssh/id_ed25519.pub | ssh ubuntu@YOUR_VPS "sudo dokku ssh-keys:add admin"
```

### App not accessible

```bash
# Check app is running
dokku ps:report myapp

# Check logs
dokku logs myapp

# Check Cloudflare Tunnel route exists
```

### Out of memory during build

```bash
# Add swap
sudo task add-swap
```

## Supported VPS Providers

| Provider | Tested | Notes |
|----------|--------|-------|
| AWS Lightsail | ✅ | Recommended for Singapore |
| Vultr | ✅ | Good alternative |
| Hetzner | ✅ | Best value (US/EU) |
| DigitalOcean | ✅ | Works well |

## License

MIT
