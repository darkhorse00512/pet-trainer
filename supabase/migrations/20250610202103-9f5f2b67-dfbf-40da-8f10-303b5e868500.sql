
-- Erstelle Admin-Rollen Enum
CREATE TYPE public.admin_role AS ENUM ('admin', 'support');

-- Admin-Users Tabelle
CREATE TABLE public.admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role admin_role NOT NULL DEFAULT 'support',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id),
  last_login TIMESTAMPTZ,
  UNIQUE(user_id)
);

-- User-Notizen für Support
CREATE TABLE public.user_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  admin_id UUID REFERENCES auth.users(id),
  note TEXT NOT NULL,
  is_internal BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Admin-Aktivitätslog
CREATE TABLE public.admin_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  target_user_id UUID REFERENCES auth.users(id),
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- System-Benachrichtigungen
CREATE TABLE public.system_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL, -- 'email', 'system', 'webhook_error'
  title TEXT NOT NULL,
  message TEXT,
  user_id UUID REFERENCES auth.users(id),
  admin_id UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'unread', -- 'unread', 'read', 'resolved'
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Policies für Admin-Tabellen
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_activity_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_notifications ENABLE ROW LEVEL SECURITY;

-- Admin-Check Funktion
CREATE OR REPLACE FUNCTION public.is_admin(_user_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_users
    WHERE user_id = _user_id
      AND is_active = true
      AND role IN ('admin', 'support')
  )
$$;

-- Admin-Rolle Check Funktion
CREATE OR REPLACE FUNCTION public.has_admin_role(_user_id UUID, _role admin_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_users
    WHERE user_id = _user_id
      AND is_active = true
      AND role = _role
  )
$$;

-- RLS Policies
CREATE POLICY "Admins can manage admin_users" ON public.admin_users
FOR ALL USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage user_notes" ON public.user_notes
FOR ALL USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can view activity_log" ON public.admin_activity_log
FOR SELECT USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can insert activity_log" ON public.admin_activity_log
FOR INSERT WITH CHECK (admin_id = auth.uid() AND public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage notifications" ON public.system_notifications
FOR ALL USING (public.is_admin(auth.uid()));

-- Erweitere subscribers Tabelle um Admin-relevante Felder
ALTER TABLE public.subscribers 
ADD COLUMN IF NOT EXISTS last_activity TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS country TEXT,
ADD COLUMN IF NOT EXISTS is_manually_activated BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- Erweitere invoices Tabelle
ALTER TABLE public.invoices
ADD COLUMN IF NOT EXISTS payment_method TEXT,
ADD COLUMN IF NOT EXISTS stripe_payment_intent_id TEXT;

-- Index für bessere Performance
CREATE INDEX IF NOT EXISTS idx_subscribers_email ON public.subscribers(email);
CREATE INDEX IF NOT EXISTS idx_subscribers_status ON public.subscribers(subscription_status);
CREATE INDEX IF NOT EXISTS idx_invoices_user_created ON public.invoices(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_admin_activity_log_created ON public.admin_activity_log(created_at);
