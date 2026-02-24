-- ============================================================
-- AgentAI — Supabase Database Setup
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Leads
CREATE TABLE IF NOT EXISTS leads (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  company TEXT,
  phone TEXT,
  email TEXT,
  source TEXT DEFAULT 'manual',
  source_id TEXT,
  status TEXT DEFAULT 'new',
  stage TEXT DEFAULT 'new_lead',
  score INTEGER DEFAULT 0,
  industry TEXT,
  estimated_value NUMERIC DEFAULT 0,
  meta_lead_id TEXT,
  meta_form_id TEXT,
  meta_ad_id TEXT,
  meta_campaign_id TEXT,
  raw_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Campaigns
CREATE TABLE IF NOT EXISTS campaigns (
  id BIGSERIAL PRIMARY KEY,
  meta_campaign_id TEXT UNIQUE,
  name TEXT NOT NULL,
  platform TEXT DEFAULT 'meta',
  status TEXT DEFAULT 'active',
  objective TEXT,
  budget_daily NUMERIC DEFAULT 0,
  budget_lifetime NUMERIC DEFAULT 0,
  spend NUMERIC DEFAULT 0,
  impressions INTEGER DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  leads_count INTEGER DEFAULT 0,
  cpl NUMERIC DEFAULT 0,
  ctr NUMERIC DEFAULT 0,
  cpm NUMERIC DEFAULT 0,
  start_date TEXT,
  end_date TEXT,
  raw_data JSONB,
  last_synced TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversations
CREATE TABLE IF NOT EXISTS conversations (
  id BIGSERIAL PRIMARY KEY,
  lead_id BIGINT REFERENCES leads(id),
  channel TEXT DEFAULT 'whatsapp',
  status TEXT DEFAULT 'active',
  last_message TEXT,
  last_message_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages
CREATE TABLE IF NOT EXISTS messages (
  id BIGSERIAL PRIMARY KEY,
  conversation_id BIGINT REFERENCES conversations(id),
  lead_id BIGINT REFERENCES leads(id),
  sender TEXT NOT NULL,
  message TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  channel TEXT DEFAULT 'whatsapp',
  meta_message_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lead Forms
CREATE TABLE IF NOT EXISTS lead_forms (
  id BIGSERIAL PRIMARY KEY,
  meta_form_id TEXT UNIQUE,
  meta_page_id TEXT,
  name TEXT,
  status TEXT,
  fields_config JSONB,
  leads_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Settings (API keys stored here, encrypted)
CREATE TABLE IF NOT EXISTS settings (
  id BIGSERIAL PRIMARY KEY,
  platform TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT,
  is_secret BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(platform, key)
);

-- Webhook Events Log
CREATE TABLE IF NOT EXISTS webhook_events (
  id BIGSERIAL PRIMARY KEY,
  source TEXT,
  event_type TEXT,
  payload JSONB,
  processed BOOLEAN DEFAULT FALSE,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sync Log
CREATE TABLE IF NOT EXISTS sync_log (
  id BIGSERIAL PRIMARY KEY,
  sync_type TEXT,
  status TEXT,
  records_synced INTEGER DEFAULT 0,
  error TEXT,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_leads_meta_lead_id ON leads(meta_lead_id);
CREATE INDEX IF NOT EXISTS idx_leads_source ON leads(source);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_stage ON leads(stage);
CREATE INDEX IF NOT EXISTS idx_campaigns_meta_id ON campaigns(meta_campaign_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_lead ON messages(lead_id);
CREATE INDEX IF NOT EXISTS idx_settings_platform ON settings(platform);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER leads_updated_at
  BEFORE UPDATE ON leads FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE OR REPLACE TRIGGER campaigns_updated_at
  BEFORE UPDATE ON campaigns FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE OR REPLACE TRIGGER settings_updated_at
  BEFORE UPDATE ON settings FOR EACH ROW EXECUTE FUNCTION update_updated_at();
