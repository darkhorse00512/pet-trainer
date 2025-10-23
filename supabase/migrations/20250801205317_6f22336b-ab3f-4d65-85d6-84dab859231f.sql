-- Create the language_support table
CREATE TABLE IF NOT EXISTS public.language_support (
  id BIGSERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  language TEXT NOT NULL DEFAULT 'de',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.language_support ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Language support is publicly readable" 
ON public.language_support 
FOR SELECT 
USING (true);

CREATE POLICY "Service can manage language support" 
ON public.language_support 
FOR ALL 
USING (true);

-- Create or replace the upsert function
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
  INSERT INTO public.language_support (email, language, updated_at)
  VALUES (user_email, user_language, NOW())
  ON CONFLICT (email)
  DO UPDATE SET 
    language = EXCLUDED.language,
    updated_at = NOW();
END;
$$;

-- Create or replace the get function
CREATE OR REPLACE FUNCTION public.get_language_support(user_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  user_language TEXT;
BEGIN
  SELECT language INTO user_language
  FROM public.language_support
  WHERE email = user_email;
  
  -- Return the language or default to 'de'
  RETURN COALESCE(user_language, 'de');
END;
$$;