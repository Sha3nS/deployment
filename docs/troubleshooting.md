# Troubleshooting Guide

Common issues and solutions for Dokku deployments.

## SSH Issues

### "Permission denied (publickey)"

Your SSH key isn't recognized.

```bash
# Check your key is added to Dokku
dokku ssh-keys:list

# Add your key
cat ~/.ssh/id_ed25519.pub | dokku ssh-keys:add admin
```

### Can't SSH to server

```bash
# Try with verbose output
ssh -v ubuntu@YOUR_IP

# If port 22 is blocked, try from mobile network
# Or use Lightsail browser console
```

## Deployment Issues

### "No matching app"

```bash
# Check app exists
dokku apps:list

# Create if missing
dokku apps:create myapp
```

### Build fails with OOM

```bash
# Add swap space
sudo task add-swap

# Check memory
free -h
```

### "Could not detect buildpack"

Dokku couldn't determine how to build your app.

**For Python:**
```bash
# Ensure requirements.txt exists in repo root
echo "flask==3.0.0" > requirements.txt
```

**For Node.js:**
```bash
# Ensure package.json exists in repo root
```

**Manual buildpack:**
```bash
dokku config:set myapp BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-python
```

### Push rejected

```bash
# Check remote is correct
git remote -v

# Should show:
# dokku    dokku@YOUR_IP:myapp (push)

# Fix if wrong:
git remote remove dokku
git remote add dokku dokku@YOUR_IP:myapp
```

## Runtime Issues

### App not responding

```bash
# Check if running
dokku ps:report myapp

# View logs
dokku logs myapp --tail

# Restart
dokku ps:restart myapp
```

### Wrong port

Dokku expects your app to listen on `PORT` environment variable.

```python
# Python
port = int(os.environ.get('PORT', 5000))
app.run(host='0.0.0.0', port=port)
```

```javascript
// Node.js
const port = process.env.PORT || 3000;
app.listen(port);
```

### Environment variables not set

```bash
# Check current config
dokku config:show myapp

# Set variables
dokku config:set myapp KEY=value

# App auto-restarts after config change
```

## Domain Issues

### "Bad gateway" or "502"

```bash
# Check app is running
dokku ps:report myapp

# Check domain is configured
dokku domains:report myapp

# Check Cloudflare Tunnel points to localhost:80
```

### Domain not working

```bash
# Add domain to app
dokku domains:add myapp app.yourdomain.com

# Verify
dokku domains:report myapp
```

## Database Issues

### Can't connect to database

```bash
# Check database exists
dokku postgres:list

# Check it's linked
dokku postgres:info mydb

# Re-link if needed
dokku postgres:link mydb myapp
```

### DATABASE_URL not set

```bash
# Link creates it automatically
dokku postgres:link mydb myapp

# Verify
dokku config:show myapp | grep DATABASE
```

## Cloudflare Tunnel Issues

### Tunnel offline

```bash
# Check status
sudo systemctl status cloudflared

# View logs
sudo journalctl -u cloudflared -f

# Restart
sudo systemctl restart cloudflared
```

### "Connection refused"

Cloudflare can reach your server, but the app isn't responding.

```bash
# Test locally
curl -I http://localhost:80

# Check Dokku proxy
dokku nginx:report myapp
```

## Docker Issues

### "Permission denied" for docker

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply without logout
newgrp docker
```

### Disk space full

```bash
# Check disk
df -h

# Clean Docker
docker system prune -a -f
docker volume prune -f

# Clean Dokku
dokku cleanup
```

## Quick Diagnostics

Run these commands to diagnose issues:

```bash
# System status
free -h                    # Memory
df -h                      # Disk space
sudo task show-ports       # Listening ports

# Dokku status
dokku apps:list            # All apps
dokku ps:report            # All processes
dokku logs myapp           # App logs

# Network
curl -I http://localhost:80    # Local HTTP
sudo systemctl status cloudflared  # Tunnel
```
