-- Create manual_support_messages table for manual support workflow
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
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_manual_support_user_id ON public.manual_support_messages(user_id);
CREATE INDEX idx_manual_support_status ON public.manual_support_messages(status);
CREATE INDEX idx_manual_support_created_at ON public.manual_support_messages(created_at DESC);
CREATE INDEX idx_manual_support_user_email ON public.manual_support_messages(user_email);

-- Enable RLS
ALTER TABLE public.manual_support_messages ENABLE ROW LEVEL SECURITY;

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

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_manual_support_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER trigger_update_manual_support_messages_updated_at
  BEFORE UPDATE ON public.manual_support_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_manual_support_messages_updated_at();

-- Add comments for documentation
COMMENT ON TABLE public.manual_support_messages IS 'Manual support messages from users requiring admin response';
COMMENT ON COLUMN public.manual_support_messages.status IS 'Status: active (new), in_progress (admin working), completed (admin responded)';
COMMENT ON COLUMN public.manual_support_messages.priority IS 'Priority level: low, normal, high, urgent';

