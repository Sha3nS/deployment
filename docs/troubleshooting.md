# Troubleshooting Guide

Common issues and solutions for VPS deployment.

## SSH Issues

### Can't connect via SSH

**Symptoms:**
- Connection refused
- Connection timed out
- Permission denied

**Solutions:**

1. **Check IP address is correct**
   ```bash
   ping YOUR_VPS_IP
   ```

2. **Check SSH key**
   ```bash
   # List your keys
   ls -la ~/.ssh/
   
   # Test with verbose mode
   ssh -v ubuntu@YOUR_VPS_IP
   ```

3. **Check firewall allows SSH**
   ```bash
   # On VPS (via console)
   sudo ufw status
   sudo ufw allow ssh
   ```

4. **Check SSH service is running**
   ```bash
   # On VPS (via console)
   sudo systemctl status sshd
   sudo systemctl start sshd
   ```

### Locked out after SSH hardening

If you disabled password auth without SSH key:

1. Use VPS provider's console/VNC access
2. Edit SSH config:
   ```bash
   sudo nano /etc/ssh/sshd_config.d/99-security.conf
   # Change: PasswordAuthentication yes
   sudo systemctl restart sshd
   ```
3. Add your SSH key properly
4. Re-disable password auth

---

## Docker Issues

### Docker command not found

```bash
# Reinstall Docker
curl -fsSL https://get.docker.com | sudo sh
```

### Permission denied when running docker

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again, or run:
newgrp docker
```

### Docker daemon not running

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

---

## Coolify Issues

### Can't access Coolify web UI

1. **Check Coolify is running**
   ```bash
   docker ps | grep coolify
   ```

2. **Check port 8000 is open**
   ```bash
   sudo ufw status
   sudo ufw allow 8000
   ```

3. **Check Coolify logs**
   ```bash
   docker logs coolify -f
   ```

4. **Restart Coolify**
   ```bash
   cd /data/coolify/source
   docker compose down
   docker compose up -d
   ```

### Coolify build fails

1. **Check disk space**
   ```bash
   df -h
   ```

2. **Check memory**
   ```bash
   free -h
   ```

3. **Clear Docker cache**
   ```bash
   docker system prune -a
   ```

---

## Cloudflare Tunnel Issues

### Tunnel not connecting

1. **Check cloudflared service**
   ```bash
   sudo systemctl status cloudflared
   ```

2. **View logs**
   ```bash
   sudo journalctl -u cloudflared -f
   ```

3. **Verify token is correct**
   ```bash
   # Reinstall with correct token
   sudo cloudflared service uninstall
   sudo cloudflared service install YOUR_CORRECT_TOKEN
   ```

### "Bad Gateway" error

- Check the service URL is correct in Cloudflare dashboard
- For Coolify: `http://localhost:8000` (not https)
- Ensure the local service is running

### DNS not resolving

1. Check DNS records in Cloudflare dashboard
2. Wait for propagation (up to 5 minutes)
3. Clear local DNS cache:
   ```bash
   # Mac
   sudo dscacheutil -flushcache
   
   # Linux
   sudo systemd-resolve --flush-caches
   ```

---

## Firewall Issues

### Can't access any services

```bash
# Check UFW status
sudo ufw status

# If locked out, disable temporarily
sudo ufw disable

# Re-enable with correct rules
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
```

### Reset firewall to defaults

```bash
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable
```

---

## Performance Issues

### High CPU usage

```bash
# Check what's using CPU
htop
# or
top

# Check Docker containers
docker stats
```

### High memory usage

```bash
# Check memory
free -h

# Check per-process
ps aux --sort=-%mem | head

# Clear Docker unused resources
docker system prune -a
```

### Disk full

```bash
# Check disk usage
df -h

# Find large files
du -sh /* | sort -h

# Clean Docker
docker system prune -a --volumes

# Clean apt cache
sudo apt clean
```

---

## Useful Commands

### System Information
```bash
# OS version
cat /etc/os-release

# Uptime
uptime

# Memory
free -h

# Disk
df -h

# CPU
nproc
lscpu
```

### Service Management
```bash
# Check service status
sudo systemctl status SERVICE_NAME

# Start/stop/restart
sudo systemctl start SERVICE_NAME
sudo systemctl stop SERVICE_NAME
sudo systemctl restart SERVICE_NAME

# View logs
sudo journalctl -u SERVICE_NAME -f
```

### Docker Commands
```bash
# List containers
docker ps -a

# View logs
docker logs CONTAINER_NAME -f

# Enter container
docker exec -it CONTAINER_NAME bash

# Restart container
docker restart CONTAINER_NAME

# Clean up
docker system prune -a
```

### Network Diagnostics
```bash
# Check open ports
sudo netstat -tlnp
# or
sudo ss -tlnp

# Check firewall
sudo ufw status verbose

# Test connectivity
curl -I https://google.com
ping 8.8.8.8
```

---

## Getting Help

If you're still stuck:

1. **Check logs first** - Most issues are explained in logs
2. **Search the error message** - Usually someone else had the same issue
3. **Coolify Discord** - https://discord.gg/coolify
4. **Cloudflare Community** - https://community.cloudflare.com

