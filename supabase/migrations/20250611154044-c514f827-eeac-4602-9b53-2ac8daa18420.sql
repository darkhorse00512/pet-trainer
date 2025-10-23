
-- Admin-Benutzer hinzufügen - Ersetzen Sie die E-Mail-Adresse mit Ihrer eigenen!
INSERT INTO public.admin_users (user_id, email, role, is_active)
SELECT id, email, 'admin', true
FROM auth.users 
WHERE email = 'ow@cooper-ads.com'
ON CONFLICT (user_id) DO UPDATE SET
  role = 'admin',
  is_active = true;
