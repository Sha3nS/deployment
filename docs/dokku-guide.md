# Dokku Maintenance Guide

Quick reference for managing apps on Dokku.

## Table of Contents

- [App Management](#app-management)
- [Deploying Apps](#deploying-apps)
- [Domains & Routing](#domains--routing)
- [Port Configuration](#port-configuration)
- [Environment Variables](#environment-variables)
- [Logs & Monitoring](#logs--monitoring)
- [Databases](#databases)
- [Scaling & Process Management](#scaling--process-management)
- [SSL Certificates](#ssl-certificates)
- [Cloudflare Tunnel Integration](#cloudflare-tunnel-integration)
- [Maintenance & Cleanup](#maintenance--cleanup)

---

## App Management

### Create a new app

```bash
sudo dokku apps:create myapp
```

### List all apps

```bash
sudo dokku apps:list
```

### Delete an app

```bash
sudo dokku apps:destroy myapp
# Type app name to confirm
```

### Rename an app

```bash
sudo dokku apps:rename old-name new-name
```

---

## Deploying Apps

### From your local machine

```bash
# Add remote (one time)
git remote add dokku dokku@YOUR_VPS_IP:myapp

# Deploy
git push dokku main

# Or deploy a different branch
git push dokku mybranch:main
```

### Rebuild without pushing

```bash
sudo dokku ps:rebuild myapp
```

### Rollback to previous version

```bash
sudo dokku ps:rollback myapp
```

---

## Domains & Routing

### Set global domain

```bash
sudo dokku domains:set-global yourdomain.com
```

### Add domain to app

```bash
sudo dokku domains:add myapp myapp.kmeow.trade
```

### List app domains

```bash
sudo dokku domains:report myapp
```

### Remove domain

```bash
sudo dokku domains:remove myapp old-domain.com
```

### Clear all domains

```bash
sudo dokku domains:clear myapp
```

---

## Port Configuration

### View current ports

```bash
sudo dokku ports:list myapp
```

### Set port mapping

```bash
# Format: sudo dokku ports:set APP SCHEME:HOST_PORT:CONTAINER_PORT
sudo dokku ports:set myapp http:80:8000
sudo dokku ports:set myapp http:80:3000
sudo dokku ports:set myapp http:80:5000
```

### Add additional port

```bash
sudo dokku ports:add myapp http:8080:8080
```

### Remove port mapping

```bash
sudo dokku ports:remove myapp http:8080:8080
```

### Common port mappings

| App Type | Command |
|----------|---------|
| Python (Flask/FastAPI) | `ports:set myapp http:80:8000` |
| Node.js | `ports:set myapp http:80:3000` |
| Go | `ports:set myapp http:80:8080` |
| Ruby | `ports:set myapp http:80:3000` |

---

## Environment Variables

### Set environment variable

```bash
sudo dokku config:set myapp KEY=value
sudo dokku config:set myapp API_KEY=xxx DATABASE_URL=postgres://...
```

### Set without restart

```bash
sudo dokku config:set --no-restart myapp KEY=value
```

### View all variables

```bash
sudo dokku config:show myapp
```

### Remove variable

```bash
sudo dokku config:unset myapp KEY
```

### Export to file

```bash
sudo dokku config:export myapp > myapp.env
```

---

## Logs & Monitoring

### View logs

```bash
sudo dokku logs myapp
```

### Follow logs (tail)

```bash
sudo dokku logs myapp --tail
```

### View specific number of lines

```bash
sudo dokku logs myapp -n 100
```

### View nginx access logs

```bash
sudo tail -f /var/log/nginx/myapp-access.log
```

### View nginx error logs

```bash
sudo tail -f /var/log/nginx/myapp-error.log
```

### Check app status

```bash
sudo dokku ps:report myapp
```

### Check all apps status

```bash
sudo dokku ps:report
```

---

## Databases

### PostgreSQL

```bash
# Install plugin (one time)
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git

# Create database
sudo dokku postgres:create mydb

# Link to app (sets DATABASE_URL automatically)
sudo dokku postgres:link mydb myapp

# Unlink
sudo dokku postgres:unlink mydb myapp

# List databases
sudo dokku postgres:list

# Database info
sudo dokku postgres:info mydb

# Connect to database
sudo dokku postgres:connect mydb

# Export database
sudo dokku postgres:export mydb > backup.sql

# Import database
sudo dokku postgres:import mydb < backup.sql

# Destroy database
sudo dokku postgres:destroy mydb
```

### Redis

```bash
# Install plugin (one time)
sudo dokku plugin:install https://github.com/dokku/dokku-redis.git

# Create Redis instance
sudo dokku redis:create myredis

# Link to app (sets REDIS_URL automatically)
sudo dokku redis:link myredis myapp

# List instances
sudo dokku redis:list

# Destroy
sudo dokku redis:destroy myredis
```

---

## Scaling & Process Management

### View processes

```bash
sudo dokku ps:report myapp
```

### Restart app

```bash
sudo dokku ps:restart myapp
```

### Stop app

```bash
sudo dokku ps:stop myapp
```

### Start app

```bash
sudo dokku ps:start myapp
```

### Scale processes

```bash
# Scale web to 2 instances
sudo dokku ps:scale myapp web=2

# Run worker process
sudo dokku ps:scale myapp worker=1

# Multiple process types
sudo dokku ps:scale myapp web=2 worker=1
```

### For background workers (no web)

Create `Procfile` in your repo:
```
worker: python main.py
```

Then:
```bash
sudo dokku ps:scale myapp web=0 worker=1
```

---

## SSL Certificates

### Using Let's Encrypt (if not using Cloudflare)

```bash
# Install plugin
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# Set email
sudo dokku letsencrypt:set myapp email your@email.com

# Enable SSL
sudo dokku letsencrypt:enable myapp

# Auto-renew
sudo dokku letsencrypt:cron-job --add
```

### Using Cloudflare (recommended)

SSL is handled by Cloudflare - no certificate needed on server.

---

## Cloudflare Tunnel Integration

### Add new app to tunnel

1. Create app in Dokku:
   ```bash
   sudo dokku apps:create newapp
   sudo dokku domains:add newapp newapp.yourdomain.com
   sudo dokku ports:set newapp http:80:YOUR_APP_PORT
   ```

2. Add route in Cloudflare Dashboard:
   - Zero Trust → Tunnels → Your tunnel → Public Hostname
   - Add: `newapp.yourdomain.com` → `http://YOUR_DOKKU_INTERNAL_IP:80`

3. Deploy your app:
   ```bash
   git remote add dokku dokku@YOUR_DOKKU_PUBLIC_IP:newapp
   git push dokku main
   ```

### Multiple apps on same port

Dokku's nginx routes by hostname, so all apps can use port 80:

| Hostname | Service | App |
|----------|---------|-----|
| app1.yourdomain.com | http://YOUR_DOKKU_INTERNAL_IP:80 | app1 |
| app2.yourdomain.com | http://YOUR_DOKKU_INTERNAL_IP:80 | app2 |
| api.yourdomain.com | http://YOUR_DOKKU_INTERNAL_IP:80 | api |

---

## Maintenance & Cleanup

### Clean up old images

```bash
sudo dokku cleanup
```

### Docker system prune

```bash
sudo docker system prune -a -f
```

### Check disk space

```bash
df -h
```

### Check memory

```bash
free -h
```

### View Docker containers

```bash
docker ps -a
```

### Rebuild nginx config

```bash
sudo dokku nginx:build-config myapp
```

### Restart nginx

```bash
sudo systemctl reload nginx
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Create app | `dokku apps:create myapp` |
| Deploy | `git push dokku main` |
| Add domain | `dokku domains:add myapp domain.com` |
| Set port | `dokku ports:set myapp http:80:PORT` |
| Set env var | `dokku config:set myapp KEY=value` |
| View logs | `dokku logs myapp --tail` |
| Restart | `dokku ps:restart myapp` |
| Scale | `dokku ps:scale myapp web=2` |
| Create DB | `dokku postgres:create mydb` |
| Link DB | `dokku postgres:link mydb myapp` |
| Status | `dokku ps:report myapp` |
| Delete app | `dokku apps:destroy myapp` |

---

## Your Setup Reference

| Component | Value |
|-----------|-------|
| Deployment VPS (Dokku) | `YOUR_DOKKU_PUBLIC_IP` |
| Deployment VPS Internal | `YOUR_DOKKU_INTERNAL_IP` |
| Tunnel VPS | `YOUR_TUNNEL_PUBLIC_IP` |
| Global Domain | `yourdomain.com` |
| Static IP (Binance) | `YOUR_DOKKU_PUBLIC_IP` |

### New App Checklist

- [ ] `sudo dokku apps:create appname`
- [ ] `sudo dokku domains:add appname appname.yourdomain.com`
- [ ] Add Cloudflare Tunnel route: `appname.yourdomain.com` → `http://YOUR_DOKKU_INTERNAL_IP:80`
- [ ] On local: `git remote add dokku dokku@YOUR_DOKKU_PUBLIC_IP:appname`
- [ ] `git push dokku main`
- [ ] `sudo dokku ports:set appname http:80:APP_PORT` (if needed)
- [ ] `sudo dokku config:set appname KEY=value` (env vars)

