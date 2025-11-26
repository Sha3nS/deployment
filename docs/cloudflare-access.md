# Cloudflare Access Setup Guide (Google Login)

This guide shows you how to add Google OAuth login to your Coolify dashboard using Cloudflare Access (free).

## Prerequisites

- Cloudflare account (free)
- Domain added to Cloudflare
- Cloudflare Tunnel configured (see `04-setup-cloudflare-tunnel.sh`)

## Step 1: Access Cloudflare Zero Trust

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com)
2. If first time, create a team name (e.g., "myteam")
3. Select **Free plan** (up to 50 users)

## Step 2: Add Google as Identity Provider

### 2.1 Create Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (or select existing)
3. Go to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth client ID**
5. Configure consent screen if prompted:
   - User Type: External
   - App name: "Coolify Access"
   - User support email: your email
   - Developer contact: your email
6. Create OAuth client ID:
   - Application type: **Web application**
   - Name: "Cloudflare Access"
   - Authorized redirect URIs: (get from Cloudflare in next step)

### 2.2 Configure in Cloudflare

1. In Zero Trust Dashboard, go to **Settings** → **Authentication**
2. Click **Add new** under Login methods
3. Select **Google**
4. Copy the **Redirect URL** shown
5. Go back to Google Cloud Console and add this URL to "Authorized redirect URIs"
6. Copy your **Client ID** and **Client Secret** from Google
7. Paste them into Cloudflare
8. Click **Save**

## Step 3: Create Access Application

1. Go to **Access** → **Applications**
2. Click **Add an application**
3. Select **Self-hosted**

### Application Configuration

| Field | Value |
|-------|-------|
| Application name | Coolify Dashboard |
| Session duration | 24 hours |
| Application domain | `coolify.yourdomain.com` |

### Add Policy

1. Policy name: "Authorized Users"
2. Action: **Allow**
3. Configure rules:

**Include (who can access):**
- Selector: **Emails**
- Value: `your.email@gmail.com`

Or for multiple users:
- Selector: **Emails ending in**
- Value: `@yourcompany.com`

4. Click **Save**

## Step 4: Test Access

1. Open an incognito/private browser window
2. Go to `https://coolify.yourdomain.com`
3. You should see Cloudflare Access login page
4. Click "Sign in with Google"
5. Login with your authorized email
6. You should now see Coolify login page

## Step 5: Configure Additional Applications (Optional)

You can protect other services the same way:

| Application | Domain | Service URL |
|-------------|--------|-------------|
| Coolify | coolify.yourdomain.com | localhost:8000 |
| Portainer | portainer.yourdomain.com | localhost:9000 |
| Your App | app.yourdomain.com | localhost:3000 |

## Security Best Practices

### Restrict by Email
```
Include:
  Emails: user1@gmail.com, user2@gmail.com
```

### Restrict by Email Domain
```
Include:
  Emails ending in: @yourcompany.com
```

### Require Specific Country
```
Include:
  Emails: your.email@gmail.com
Require:
  Country: Singapore, United States
```

### Add Additional Authentication
You can require multiple factors:
- Google login AND
- One-time PIN to email AND
- Hardware key (Yubikey)

## Troubleshooting

### "Access Denied" Error
- Check your email is in the policy's Include rules
- Make sure Google is enabled as a login method
- Check the application domain matches exactly

### Can't See Google Login Option
- Verify Google is added in Settings → Authentication
- Check Client ID and Secret are correct
- Ensure redirect URI in Google matches Cloudflare's

### Tunnel Not Working
- Check tunnel status: `sudo systemctl status cloudflared`
- View logs: `sudo journalctl -u cloudflared -f`
- Verify public hostname is configured in Cloudflare dashboard

## Cost

| Feature | Free Tier |
|---------|-----------|
| Users | Up to 50 |
| Applications | Unlimited |
| Tunnels | Unlimited |
| Google OAuth | ✅ Included |
| Email OTP | ✅ Included |

You're unlikely to exceed the free tier for personal use.

## Quick Reference

```bash
# Check tunnel status
sudo systemctl status cloudflared

# View tunnel logs
sudo journalctl -u cloudflared -f

# Restart tunnel
sudo systemctl restart cloudflared

# Remove direct port access (after tunnel works)
sudo ufw delete allow 8000
```

