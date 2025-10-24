-- Add viewed_by_user column to track if user has seen the admin response
ALTER TABLE public.manual_support_messages
ADD COLUMN IF NOT EXISTS viewed_by_user BOOLEAN DEFAULT false;

-- Add index for faster queries on viewed status
CREATE INDEX IF NOT EXISTS idx_manual_support_viewed ON public.manual_support_messages(viewed_by_user);

-- Policy: Users can update viewed status on their own messages
CREATE POLICY "Users can update viewed status on their own messages"
  ON public.manual_support_messages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Add comment
COMMENT ON COLUMN public.manual_support_messages.viewed_by_user IS 'Whether user has viewed the admin response';

