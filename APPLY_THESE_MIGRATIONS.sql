-- ============================================
-- MANUAL SUPPORT SYSTEM - DATABASE SETUP
-- Run this in Supabase SQL Editor
-- ============================================

-- Step 1: Create manual_support_messages table
CREATE TABLE IF NOT EXISTS public.manual_support_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_email TEXT NOT NULL,
  user_name TEXT,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'in_progress', 'completed')),
  priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  admin_response TEXT,
  admin_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  admin_responded_at TIMESTAMPTZ,
  viewed_by_user BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_manual_support_user_id ON public.manual_support_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_manual_support_status ON public.manual_support_messages(status);
CREATE INDEX IF NOT EXISTS idx_manual_support_created_at ON public.manual_support_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_manual_support_user_email ON public.manual_support_messages(user_email);
CREATE INDEX IF NOT EXISTS idx_manual_support_viewed ON public.manual_support_messages(viewed_by_user);

-- Step 3: Enable RLS
ALTER TABLE public.manual_support_messages ENABLE ROW LEVEL SECURITY;

-- Step 4: Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own manual support messages" ON public.manual_support_messages;
DROP POLICY IF EXISTS "Users can create their own manual support messages" ON public.manual_support_messages;
DROP POLICY IF EXISTS "Admins can view all manual support messages" ON public.manual_support_messages;
DROP POLICY IF EXISTS "Admins can update manual support messages" ON public.manual_support_messages;
DROP POLICY IF EXISTS "Users can update viewed status on their own messages" ON public.manual_support_messages;

-- Step 5: Create RLS policies
-- Policy: Users can view their own messages
CREATE POLICY "Users can view their own manual support messages"
  ON public.manual_support_messages
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Users can create their own messages
CREATE POLICY "Users can create their own manual support messages"
  ON public.manual_support_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: Admins can view all messages
CREATE POLICY "Admins can view all manual support messages"
  ON public.manual_support_messages
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE admin_users.user_id = auth.uid()
      AND admin_users.is_active = true
    )
  );

-- Policy: Admins can update messages (for responses)
CREATE POLICY "Admins can update manual support messages"
  ON public.manual_support_messages
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.admin_users
      WHERE admin_users.user_id = auth.uid()
      AND admin_users.is_active = true
    )
  );

-- Policy: Users can update viewed status on their own messages
CREATE POLICY "Users can update viewed status on their own messages"
  ON public.manual_support_messages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Step 6: Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_manual_support_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS trigger_update_manual_support_messages_updated_at ON public.manual_support_messages;
CREATE TRIGGER trigger_update_manual_support_messages_updated_at
  BEFORE UPDATE ON public.manual_support_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_manual_support_messages_updated_at();

-- Step 8: Add comments for documentation
COMMENT ON TABLE public.manual_support_messages IS 'Manual support messages from users requiring admin response';
COMMENT ON COLUMN public.manual_support_messages.status IS 'Status: active (new), in_progress (admin working), completed (admin responded)';
COMMENT ON COLUMN public.manual_support_messages.priority IS 'Priority level: low, normal, high, urgent';
COMMENT ON COLUMN public.manual_support_messages.viewed_by_user IS 'Whether user has viewed the admin response';

-- ============================================
-- SETUP COMPLETE
-- ============================================
-- The manual support system is now ready to use!
-- Users can access it at: /manual-support
-- Admins can manage it at: /admin/support
-- ============================================

-- ============================================
-- DEVICE BINDINGS - AUTOMATIC LOGIN SYSTEM
-- Run this in Supabase SQL Editor
-- ============================================

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

-- ============================================
-- DEVICE BINDINGS SETUP COMPLETE
-- ============================================

