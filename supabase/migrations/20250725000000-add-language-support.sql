-- Add language support to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'de' CHECK (language IN ('de', 'en'));

-- Create email templates table for multi-language support
CREATE TABLE IF NOT EXISTS public.email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_key TEXT NOT NULL,
  language TEXT NOT NULL DEFAULT 'de',
  subject TEXT NOT NULL,
  html_content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(template_key, language)
);

-- Insert German email templates
INSERT INTO public.email_templates (template_key, language, subject, html_content) VALUES
-- Welcome Email
('welcome', 'de', '🎉 Willkommen bei TierTrainer24, {{name}}!', 
'<div style="background: #22c55e; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🐾 Willkommen bei TierTrainer24!</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hallo {{name}}, schön dass du da bist!</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <h2 style="margin: 0 0 15px 0; color: #333;">🎯 Dein {{planName}}-Paket ist aktiv</h2>
  <p>Deine kostenlose Testphase läuft {{trialEndDate}} ab. Du kannst jederzeit kündigen.</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #22c55e; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🚀 Zum Dashboard
    </a>
  </div>
</div>'),

-- Checkout Confirmation
('checkout-confirmation', 'de', '✅ Bestellung bestätigt - TierTrainer24 {{planName}}',
'<div style="background: #22c55e; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🎉 Bestellung erfolgreich!</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Vielen Dank für dein Vertrauen, {{name}}!</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <h2 style="margin: 0 0 15px 0; color: #333;">📋 Bestelldetails</h2>
  <ul style="margin: 0; padding-left: 20px;">
    <li><strong>Paket:</strong> {{planName}}</li>
    <li><strong>Preis:</strong> €{{amount}}/{{interval}}</li>
    <li><strong>Testphase:</strong> Läuft {{trialEndDate}} ab</li>
  </ul>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #22c55e; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🚀 Training starten
    </a>
  </div>
</div>'),

-- Magic Link
('magic-link', 'de', '🔗 Anmeldelink - TierTrainer24',
'<div style="background: #3b82f6; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🔗 Anmeldelink</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hallo {{name}}, hier ist dein sicherer Anmeldelink</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Klicke auf den Button unten, um dich sicher anzumelden:</p>
  <div style="margin: 20px 0;">
    <a href="{{magicLink}}" style="background: #3b82f6; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🔐 Anmelden
    </a>
  </div>
  <p style="font-size: 14px; color: #666;">Dieser Link ist 60 Minuten gültig.</p>
</div>'),

-- Password Reset
('password-reset', 'de', '🔐 Passwort zurücksetzen - TierTrainer24',
'<div style="background: #ef4444; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🔐 Passwort zurücksetzen</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hallo {{name}}, du hast eine Passwort-Reset-Anfrage gestellt</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Klicke auf den Button unten, um dein Passwort zurückzusetzen:</p>
  <div style="margin: 20px 0;">
    <a href="{{confirmationLink}}" style="background: #ef4444; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🔐 Passwort zurücksetzen
    </a>
  </div>
  <p style="font-size: 14px; color: #666;">Dieser Link ist 1 Stunde gültig.</p>
</div>'),

-- Trial Reminder
('trial-reminder', 'de', '⏰ Testphase läuft ab - TierTrainer24',
'<div style="background: #f59e0b; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">⏰ Testphase läuft ab</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hallo {{name}}, deine Testphase endet bald</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Deine kostenlose Testphase läuft {{trialEndDate}} ab. Verliere nicht den Zugang zu deinen Trainingsplänen!</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #f59e0b; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      💳 Jetzt upgraden
    </a>
  </div>
</div>'),

-- Subscription Cancelled
('subscription-cancelled', 'de', '📅 Kündigung bestätigt - TierTrainer24',
'<div style="background: #6b7280; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">📅 Kündigung bestätigt</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hallo {{name}}, deine Kündigung wurde bestätigt</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Deine Kündigung wurde erfolgreich verarbeitet. Dein Zugang bleibt bis zum Ende der aktuellen Abrechnungsperiode aktiv.</p>
  <p><strong>Zugang bis:</strong> {{trialEndDate}}</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #6b7280; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🔄 Reaktivieren
    </a>
  </div>
</div>'),

-- Payment Failed
('payment-failed', 'de', '❌ Zahlung fehlgeschlagen - TierTrainer24',
'<div style="background: #ef4444; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">❌ Zahlung fehlgeschlagen</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hallo {{name}}, es gab ein Problem mit deiner Zahlung</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Deine letzte Zahlung konnte nicht verarbeitet werden. Bitte überprüfe deine Zahlungsinformationen.</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #ef4444; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      💳 Zahlung aktualisieren
    </a>
  </div>
</div>');

-- Insert English email templates
INSERT INTO public.email_templates (template_key, language, subject, html_content) VALUES
-- Welcome Email
('welcome', 'en', '🎉 Welcome to TierTrainer24, {{name}}!', 
'<div style="background: #22c55e; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🐾 Welcome to TierTrainer24!</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hello {{name}}, great to have you here!</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <h2 style="margin: 0 0 15px 0; color: #333;">🎯 Your {{planName}} package is active</h2>
  <p>Your free trial expires {{trialEndDate}}. You can cancel anytime.</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #22c55e; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🚀 Go to Dashboard
    </a>
  </div>
</div>'),

-- Checkout Confirmation
('checkout-confirmation', 'en', '✅ Order confirmed - TierTrainer24 {{planName}}',
'<div style="background: #22c55e; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🎉 Order successful!</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Thank you for your trust, {{name}}!</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <h2 style="margin: 0 0 15px 0; color: #333;">📋 Order Details</h2>
  <ul style="margin: 0; padding-left: 20px;">
    <li><strong>Package:</strong> {{planName}}</li>
    <li><strong>Price:</strong> €{{amount}}/{{interval}}</li>
    <li><strong>Trial:</strong> Expires {{trialEndDate}}</li>
  </ul>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #22c55e; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🚀 Start Training
    </a>
  </div>
</div>'),

-- Magic Link
('magic-link', 'en', '🔗 Login Link - TierTrainer24',
'<div style="background: #3b82f6; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🔗 Login Link</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hello {{name}}, here is your secure login link</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Click the button below to securely log in:</p>
  <div style="margin: 20px 0;">
    <a href="{{magicLink}}" style="background: #3b82f6; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🔐 Login
    </a>
  </div>
  <p style="font-size: 14px; color: #666;">This link is valid for 60 minutes.</p>
</div>'),

-- Password Reset
('password-reset', 'en', '🔐 Reset Password - TierTrainer24',
'<div style="background: #ef4444; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">🔐 Reset Password</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hello {{name}}, you requested a password reset</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Click the button below to reset your password:</p>
  <div style="margin: 20px 0;">
    <a href="{{confirmationLink}}" style="background: #ef4444; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🔐 Reset Password
    </a>
  </div>
  <p style="font-size: 14px; color: #666;">This link is valid for 1 hour.</p>
</div>'),

-- Trial Reminder
('trial-reminder', 'en', '⏰ Trial Expiring - TierTrainer24',
'<div style="background: #f59e0b; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">⏰ Trial Expiring</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hello {{name}}, your trial is ending soon</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Your free trial expires {{trialEndDate}}. Don''t lose access to your training plans!</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #f59e0b; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      💳 Upgrade Now
    </a>
  </div>
</div>'),

-- Subscription Cancelled
('subscription-cancelled', 'en', '📅 Cancellation Confirmed - TierTrainer24',
'<div style="background: #6b7280; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">📅 Cancellation Confirmed</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hello {{name}}, your cancellation has been confirmed</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Your cancellation has been successfully processed. Your access remains active until the end of the current billing period.</p>
  <p><strong>Access until:</strong> {{trialEndDate}}</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #6b7280; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      🔄 Reactivate
    </a>
  </div>
</div>'),

-- Payment Failed
('payment-failed', 'en', '❌ Payment Failed - TierTrainer24',
'<div style="background: #ef4444; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px;">
  <h1 style="margin: 0; font-size: 24px;">❌ Payment Failed</h1>
  <p style="margin: 10px 0 0 0; font-size: 16px;">Hello {{name}}, there was an issue with your payment</p>
</div>
<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
  <p>Your last payment could not be processed. Please check your payment information.</p>
  <div style="margin: 20px 0;">
    <a href="{{dashboardUrl}}" style="background: #ef4444; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">
      💳 Update Payment
    </a>
  </div>
</div>');

-- Create function to get user language preference
CREATE OR REPLACE FUNCTION public.get_user_language(user_email TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  user_language TEXT;
BEGIN
  SELECT language INTO user_language
  FROM public.profiles
  WHERE email = user_email;
  
  RETURN COALESCE(user_language, 'de');
END;
$function$;

-- Create function to get email template
CREATE OR REPLACE FUNCTION public.get_email_template(template_key TEXT, user_email TEXT)
RETURNS TABLE(subject TEXT, html_content TEXT)
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  user_language TEXT;
BEGIN
  -- Get user language preference
  SELECT public.get_user_language(user_email) INTO user_language;
  
  -- Return template in user's language, fallback to German
  RETURN QUERY
  SELECT et.subject, et.html_content
  FROM public.email_templates et
  WHERE et.template_key = $1 
    AND et.language = user_language
  UNION ALL
  SELECT et.subject, et.html_content
  FROM public.email_templates et
  WHERE et.template_key = $1 
    AND et.language = 'de'
  LIMIT 1;
END;
$function$;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_email_templates_key_lang ON public.email_templates(template_key, language);
CREATE INDEX IF NOT EXISTS idx_profiles_language ON public.profiles(language);

-- Enable RLS on email_templates
ALTER TABLE public.email_templates ENABLE ROW LEVEL SECURITY;

-- RLS policies for email_templates (read-only for authenticated users)
CREATE POLICY "Users can read email templates" ON public.email_templates
  FOR SELECT USING (true); 