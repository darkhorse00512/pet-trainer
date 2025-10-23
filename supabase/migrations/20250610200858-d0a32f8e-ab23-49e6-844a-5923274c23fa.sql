
-- Erweitere die subscribers Tabelle um zusätzliche Felder für besseres Subscription-Management
ALTER TABLE public.subscribers 
ADD COLUMN IF NOT EXISTS trial_start TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS trial_used BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'inactive',
ADD COLUMN IF NOT EXISTS current_period_start TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS current_period_end TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS cancel_at_period_end BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS billing_cycle TEXT DEFAULT 'monthly';

-- Tabelle für Webhook-Events (für Produktionsumgebung)
CREATE TABLE IF NOT EXISTS public.stripe_webhooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stripe_event_id TEXT UNIQUE NOT NULL,
  event_type TEXT NOT NULL,
  processed BOOLEAN DEFAULT false,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  processed_at TIMESTAMPTZ
);

-- Tabelle für Rechnungen/Invoices
CREATE TABLE IF NOT EXISTS public.invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  stripe_invoice_id TEXT UNIQUE,
  invoice_number TEXT,
  amount_total INTEGER,
  currency TEXT DEFAULT 'eur',
  status TEXT,
  invoice_pdf TEXT,
  hosted_invoice_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  due_date TIMESTAMPTZ,
  paid_at TIMESTAMPTZ
);

-- RLS Policies für neue Tabellen
ALTER TABLE public.stripe_webhooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

-- Webhook-Tabelle ist nur für Service-Role zugänglich
CREATE POLICY "service_role_only" ON public.stripe_webhooks FOR ALL USING (false);

-- Invoices: Nutzer können nur ihre eigenen Rechnungen sehen
CREATE POLICY "users_own_invoices" ON public.invoices
FOR SELECT USING (auth.uid() = user_id);

-- Service role kann Invoices für alle Nutzer erstellen/updaten
CREATE POLICY "service_role_invoices" ON public.invoices
FOR ALL USING (true);
