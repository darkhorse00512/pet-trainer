-- Create table for storing signup verification codes
CREATE TABLE IF NOT EXISTS signup_verification_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  code TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '1 hour'),
  used BOOLEAN DEFAULT FALSE,
  used_at TIMESTAMP WITH TIME ZONE,
  created_at_utc TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_signup_verification_codes_email_code 
ON signup_verification_codes(email, code) 
WHERE used = FALSE;

-- Create index for cleanup of expired codes
CREATE INDEX IF NOT EXISTS idx_signup_verification_codes_expires_at 
ON signup_verification_codes(expires_at);

-- Enable RLS (Row Level Security)
ALTER TABLE signup_verification_codes ENABLE ROW LEVEL SECURITY;

-- Create policy to allow service role to manage verification codes
CREATE POLICY "Service role can manage verification codes" ON signup_verification_codes
FOR ALL USING (auth.role() = 'service_role');

-- Create policy to allow users to read their own verification codes (for debugging)
CREATE POLICY "Users can read their own verification codes" ON signup_verification_codes
FOR SELECT USING (auth.email() = email);
