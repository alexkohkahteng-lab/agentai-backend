# AgentAI — Free Deployment Guide

Total cost: **$0/month**
Time needed: **~15 minutes**

## Stack

| Service | What | Free Tier |
|---------|------|-----------|
| **Supabase** | Database (PostgreSQL) | 500MB, 50K rows, unlimited API |
| **Render** | Backend API hosting | 750 hours/month, auto-sleep |
| **Vercel** | Frontend hosting | 100GB bandwidth |

---

## Step 1: Set Up Supabase (Database)

1. Go to **https://supabase.com** → Sign up (use GitHub)
2. Click **"New project"**
3. Fill in:
   - Name: `agentai`
   - Database password: (save this somewhere)
   - Region: **Singapore** (closest to you)
4. Wait ~2 minutes for project to spin up

### Get your credentials

5. Go to **Settings** → **API** (left sidebar)
6. Copy these two values:
   - **Project URL** → looks like `https://xxxxx.supabase.co`
   - **service_role key** (under "Project API keys") → starts with `eyJhbGci...`

   ⚠️ Use the **service_role** key (secret), NOT the anon key

### Create database tables

7. Go to **SQL Editor** (left sidebar)
8. Click **"New query"**
9. Paste the ENTIRE contents of `supabase-migration.sql`
10. Click **"Run"** (or Ctrl+Enter)
11. You should see "Success. No rows returned" — that means all tables are created

---

## Step 2: Deploy Backend to Render

### Push code to GitHub first

1. Create a new GitHub repo: `agentai-backend`
2. Push this code:

```bash
cd agentai-deploy
git init
git add .
git commit -m "AgentAI backend"
git remote add origin https://github.com/YOUR_USERNAME/agentai-backend.git
git push -u origin main
```

### Deploy on Render

3. Go to **https://render.com** → Sign up (use GitHub)
4. Click **"New +"** → **"Web Service"**
5. Connect your GitHub → select `agentai-backend` repo
6. Settings:
   - Name: `agentai-backend`
   - Runtime: **Node**
   - Build Command: `npm install`
   - Start Command: `node src/server.js`
   - Plan: **Free**
7. Click **"Advanced"** → **"Add Environment Variable"**:

   | Key | Value |
   |-----|-------|
   | `SUPABASE_URL` | `https://xxxxx.supabase.co` (from Step 1) |
   | `SUPABASE_SERVICE_KEY` | `eyJhbGci...` (from Step 1) |
   | `ENCRYPTION_KEY` | Any random string 32+ chars (e.g. `myagentai-secret-key-2026-sg!!!!!`) |

8. Click **"Create Web Service"**
9. Wait 2-3 minutes for deploy
10. You'll get a URL like: `https://agentai-backend-xxxx.onrender.com`

### Verify it works

11. Open: `https://agentai-backend-xxxx.onrender.com/health`
12. You should see: `{"status":"ok","service":"AgentAI"}`

---

## Step 3: Deploy Frontend to Vercel (Optional)

If you want the React dashboard hosted:

1. Go to **https://vercel.com** → Sign up
2. Import your frontend repo
3. Set framework: **Vite** or **Create React App**
4. Add environment variable:
   - `VITE_API_URL` = `https://agentai-backend-xxxx.onrender.com`
5. Deploy

Or just run the frontend locally and point API calls to your Render URL.

---

## Step 4: Connect Your Meta API Keys

1. Open your AgentAI dashboard
2. Go to **Integrations** → click **Meta**
3. Enter your credentials (App ID, tokens, etc.)
4. Click **"Test Connection"**
5. Click **"Save Credentials"**

The backend stores these encrypted in Supabase — no .env files needed.

---

## Step 5: Set Up Meta Webhook (for real-time leads)

Once your Render backend is live:

1. Go to developers.facebook.com → Your App → Webhooks
2. Callback URL: `https://agentai-backend-xxxx.onrender.com/webhook/meta`
3. Verify Token: whatever you entered in AgentAI Integrations
4. Subscribe to: `leadgen`

---

## API Endpoints

Your backend is at: `https://agentai-backend-xxxx.onrender.com`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/api/dashboard` | Dashboard KPIs |
| GET | `/api/leads` | List leads |
| POST | `/api/leads` | Add lead |
| PATCH | `/api/leads/:id` | Update lead |
| GET | `/api/campaigns` | List campaigns |
| GET | `/api/settings` | All platforms status |
| GET | `/api/settings/:platform` | Get platform settings |
| POST | `/api/settings/:platform` | Save credentials |
| POST | `/api/settings/:platform/test` | Test connection |
| POST | `/api/sync/meta/leads` | Sync Meta leads |
| POST | `/api/sync/meta/campaigns` | Sync campaigns |
| POST | `/api/sync/meta/all` | Full sync |

---

## Free Tier Limits

| Service | Limit | Enough for |
|---------|-------|------------|
| Supabase | 500MB DB, 50K rows | ~10,000 leads + campaigns |
| Supabase | 2GB bandwidth | ~100K API calls/day |
| Render | 750 hrs/month, sleeps after 15min idle | Always-on during business hours |
| Vercel | 100GB bandwidth | Unlimited for dashboard |

### Note on Render free tier
Render free services sleep after 15 minutes of no traffic. First request after sleep takes ~30 seconds to wake up. For production, upgrade to $7/month for always-on.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Render deploy fails | Check build logs, make sure Node version ≥ 18 |
| "Missing SUPABASE_URL" | Add environment variables in Render dashboard |
| Supabase migration error | Make sure you ran the FULL SQL file |
| Webhook verification fails | Check ENCRYPTION_KEY is set, verify token matches |
| API returns empty data | Run sync first: POST `/api/sync/meta/all` |
| Render sleeps too often | Upgrade to $7/month or use UptimeRobot for free pings |
