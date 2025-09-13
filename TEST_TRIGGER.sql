-- 🧪 Test Script für Supabase User Profile Trigger
-- Führe diese Befehle aus, um den Trigger zu testen

-- 1. Überprüfe die Installation
SELECT * FROM public.check_trigger_setup();

-- 2. Teste die Trigger-Funktion
SELECT public.test_user_creation();

-- 3. Überprüfe die user_profiles Tabelle
SELECT 
  id,
  first_name,
  last_name,
  username,
  created_at
FROM public.user_profiles 
ORDER BY created_at DESC 
LIMIT 5;

-- 4. Überprüfe auth.users Tabelle
SELECT 
  id,
  phone,
  raw_user_meta_data,
  created_at
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 5;

-- 5. Teste RLS Policies (optional - nur wenn du als authentifizierter User eingeloggt bist)
-- SELECT * FROM public.user_profiles WHERE id = auth.uid();

-- 6. Debugging: Zeige alle Trigger
SELECT 
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- 7. Debugging: Zeige alle Policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- 8. Debugging: Zeige alle Funktionen
SELECT 
  routine_name,
  routine_type,
  data_type,
  routine_definition
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';




