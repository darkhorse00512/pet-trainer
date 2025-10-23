-- Create language_support table with RLS enabled
CREATE TABLE public.language_support (
  id BIGSERIAL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  language TEXT NOT NULL DEFAULT 'de',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.language_support ENABLE ROW LEVEL SECURITY;

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

-- Create trigger to update updated_at
CREATE TRIGGER update_language_support_updated_at
BEFORE UPDATE ON public.language_support
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Add index for email lookups
CREATE INDEX idx_language_support_email ON public.language_support(email);

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