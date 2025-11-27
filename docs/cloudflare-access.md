# Cloudflare Access Setup (Google Login)

Protect your apps with Google authentication via Cloudflare Access.

## Overview

Cloudflare Access adds authentication in front of your apps without modifying your code.

```
User → Cloudflare (login) → Tunnel → Dokku → Your App
```

## Setup Steps

### 1. Go to Cloudflare Zero Trust

1. Open [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Click **Zero Trust** (left sidebar)
3. If first time, set up your team name (e.g., `yourname`)

### 2. Create Access Application

1. **Access** → **Applications** → **Add an application**
2. Select **Self-hosted**
3. Configure:
   - **Application name:** `My App`
   - **Session duration:** 24 hours (or your preference)
   - **Application domain:** `app.yourdomain.com`

### 3. Add Policy

1. **Policy name:** `Allow My Email`
2. **Action:** Allow
3. **Include:**
   - Selector: **Emails**
   - Value: `your@email.com`

Or for Google Workspace:
   - Selector: **Emails ending in**
   - Value: `@yourdomain.com`

### 4. Save

Click **Save** to create the application.

## Testing

1. Open `https://app.yourdomain.com` in incognito
2. You should see Cloudflare login page
3. Login with Google
4. You're redirected to your app

## Multiple Apps

Create separate Access Applications for each app you want to protect:

| App | Domain | Protection |
|-----|--------|------------|
| Admin panel | admin.yourdomain.com | ✅ Protected |
| Public site | www.yourdomain.com | ❌ Public |
| API | api.yourdomain.com | ❌ Public (use API keys) |

## Service Tokens (for APIs)

For automated access (CI/CD, bots):

1. **Access** → **Service Auth** → **Service Tokens**
2. Create token
3. Use in requests:

```bash
curl -H "CF-Access-Client-Id: xxx" \
     -H "CF-Access-Client-Secret: yyy" \
     https://app.yourdomain.com/api
```

## Bypass for Specific Paths

To allow public access to specific paths (e.g., webhooks):

1. Edit your Access Application
2. Add another policy with **Action: Bypass**
3. Add rule: **Path** contains `/webhook`

## Tips

- Use **Emails** selector for personal use
- Use **Email domain** for teams
- Set reasonable session duration (24h is good)
- Test in incognito to verify protection
