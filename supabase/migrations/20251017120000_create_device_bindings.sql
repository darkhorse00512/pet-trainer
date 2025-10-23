-- Create device_bindings table for automatic login on trusted devices
CREATE TABLE IF NOT EXISTS public.device_bindings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email TEXT NOT NULL,
  device_fingerprint TEXT NOT NULL,
  device_name TEXT,
  last_used_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),
  is_active BOOLEAN DEFAULT true,
  
  -- Device metadata
  user_agent TEXT,
  ip_address TEXT,
  
  UNIQUE(user_email, device_fingerprint)
);

-- Enable RLS
ALTER TABLE public.device_bindings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own device bindings" 
  ON public.device_bindings FOR SELECT 
  USING (auth.jwt() ->> 'email' = user_email);

CREATE POLICY "Users can insert own device bindings" 
  ON public.device_bindings FOR INSERT 
  WITH CHECK (auth.jwt() ->> 'email' = user_email);

CREATE POLICY "Users can update own device bindings" 
  ON public.device_bindings FOR UPDATE 
  USING (auth.jwt() ->> 'email' = user_email);

CREATE POLICY "Users can delete own device bindings" 
  ON public.device_bindings FOR DELETE 
  USING (auth.jwt() ->> 'email' = user_email);

-- Indexes for performance
CREATE INDEX idx_device_bindings_user_email ON public.device_bindings(user_email);
CREATE INDEX idx_device_bindings_fingerprint ON public.device_bindings(device_fingerprint);
CREATE INDEX idx_device_bindings_active ON public.device_bindings(is_active) WHERE is_active = true;
CREATE INDEX idx_device_bindings_expires_at ON public.device_bindings(expires_at);

-- Function to clean up expired device bindings
CREATE OR REPLACE FUNCTION public.cleanup_expired_device_bindings()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM public.device_bindings
  WHERE expires_at < NOW() OR is_active = false;
END;
$$;

-- Comments for documentation
COMMENT ON TABLE public.device_bindings IS 'Stores device fingerprints for automatic login on trusted devices';
COMMENT ON COLUMN public.device_bindings.device_fingerprint IS 'Unique hash of device characteristics';
COMMENT ON COLUMN public.device_bindings.expires_at IS 'When this device binding expires (default 30 days)';
COMMENT ON COLUMN public.device_bindings.is_active IS 'Whether this device binding is still active';

