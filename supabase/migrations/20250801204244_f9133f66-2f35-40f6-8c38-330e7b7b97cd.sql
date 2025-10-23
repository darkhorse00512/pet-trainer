-- Create function to get language support for a user
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