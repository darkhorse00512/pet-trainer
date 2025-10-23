-- Add RLS policies and function for language_support table (table already exists)

-- Enable RLS if not already enabled
ALTER TABLE public.language_support ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Language support is publicly readable" ON public.language_support;
DROP POLICY IF EXISTS "Service can manage language support" ON public.language_support;

-- Allow public access for language support (for email functions)
CREATE POLICY "Language support is publicly readable" 
ON public.language_support 
FOR SELECT 
USING (true);

-- Allow service role to manage language support
CREATE POLICY "Service can manage language support" 
ON public.language_support 
FOR ALL 
USING (true);

-- Create function to upsert language support
CREATE OR REPLACE FUNCTION public.upsert_language_support(
  user_email TEXT,
  user_language TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.language_support (email, language)
  VALUES (user_email, user_language)
  ON CONFLICT (email)
  DO UPDATE SET 
    language = EXCLUDED.language,
    updated_at = NOW();
END;
$$;