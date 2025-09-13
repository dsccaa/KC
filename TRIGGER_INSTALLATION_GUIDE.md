# 🚀 Supabase User Profile Trigger - Installation & Test

## 📋 Übersicht
Diese Anleitung führt dich durch die Installation und den Test des automatischen User Profile Triggers für dein Supabase-Projekt.

## 🎯 Ziel
- Automatische Erstellung von User Profiles bei der Registrierung
- Synchronisation zwischen `auth.users` und `user_profiles`
- Sichere RLS Policies für Datenzugriff

## 📝 Schritt 1: Trigger installieren

### 1.1 Supabase Dashboard öffnen
1. Gehe zu: https://supabase.com/dashboard/project/nrkjjukeracgbpvwbjam
2. Klicke auf **"SQL Editor"** im linken Menü
3. Klicke auf **"New query"**

### 1.2 SQL-Code ausführen
1. Öffne die Datei `SUPABASE_TRIGGER_FINAL.sql`
2. Kopiere den **gesamten Inhalt**
3. Füge ihn in den SQL Editor ein
4. Klicke auf **"Run"** um die Funktionen und Trigger zu erstellen

### 1.3 Erfolg bestätigen
Du solltest eine Nachricht sehen:
```
✅ Function created successfully
✅ Trigger created successfully
✅ Policies created successfully
```

## 🧪 Schritt 2: Trigger testen

### 2.1 Test-Script ausführen
1. Öffne die Datei `TEST_TRIGGER.sql`
2. Kopiere den Inhalt
3. Füge ihn in den SQL Editor ein
4. Klicke auf **"Run"**

### 2.2 Erwartete Ergebnisse

#### Setup-Überprüfung:
```
check_name          | status   | details
--------------------|----------|------------------
Function exists     | ✅ OK    | handle_new_user function
Trigger exists      | ✅ OK    | on_auth_user_created trigger
RLS Policies        | ✅ OK    | Row Level Security policies
Table exists        | ✅ OK    | user_profiles table
```

#### Test-Ergebnis:
```
✅ User Profile wurde erfolgreich erstellt für User ID: [UUID]
📋 Profile Details: Vorname=Test, Username=testuser
🧹 Test-Benutzer wurde gelöscht
```

## 🔍 Schritt 3: Manuelle Überprüfung

### 3.1 Tabellen überprüfen
```sql
-- Überprüfe user_profiles Tabelle
SELECT * FROM public.user_profiles ORDER BY created_at DESC LIMIT 5;

-- Überprüfe auth.users Tabelle
SELECT id, phone, raw_user_meta_data FROM auth.users ORDER BY created_at DESC LIMIT 5;
```

### 3.2 Trigger-Status überprüfen
```sql
-- Zeige alle Trigger
SELECT trigger_name, event_manipulation, action_statement 
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Zeige alle Policies
SELECT policyname, cmd, permissive 
FROM pg_policies 
WHERE tablename = 'user_profiles';
```

## 🎉 Schritt 4: App testen

### 4.1 Registrierung testen
1. Öffne deine App
2. Registriere einen neuen Benutzer
3. Überprüfe in Supabase, ob ein User Profile erstellt wurde

### 4.2 Datenbank überprüfen
```sql
-- Überprüfe die neuesten User Profiles
SELECT 
  id,
  first_name,
  username,
  created_at
FROM public.user_profiles 
ORDER BY created_at DESC 
LIMIT 3;
```

## 🐛 Troubleshooting

### Problem: Trigger funktioniert nicht
```sql
-- Prüfe ob Trigger existiert
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Prüfe ob Funktion existiert
SELECT * FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';
```

### Problem: RLS blockiert Zugriff
```sql
-- Prüfe Policies
SELECT * FROM pg_policies 
WHERE tablename = 'user_profiles';

-- Teste RLS (als authentifizierter User)
SELECT * FROM public.user_profiles WHERE id = auth.uid();
```

### Problem: Tabelle existiert nicht
```sql
-- Prüfe ob user_profiles Tabelle existiert
SELECT * FROM information_schema.tables 
WHERE table_name = 'user_profiles' AND table_schema = 'public';
```

## ✅ Erfolgreiche Installation

Nach der Installation solltest du:
- ✅ Automatische User Profile Erstellung haben
- ✅ RLS Policies aktiviert haben
- ✅ Test-Funktion erfolgreich ausgeführt haben
- ✅ App ohne manuelle Profile-Erstellung verwenden können

## 🎯 Nächste Schritte

1. **Teste die Registrierung** in deiner App
2. **Überprüfe die Datenbank** - neue User sollten automatisch Profile haben
3. **Entferne manuelle Profile-Erstellung** aus deinem Code (falls vorhanden)
4. **Genieße die automatische Synchronisation!** 🍻

## 📞 Support

Falls du Probleme hast:
1. Überprüfe die SQL-Fehler in der Supabase-Konsole
2. Führe die Troubleshooting-Befehle aus
3. Überprüfe die Logs in deiner App

## 🎉 Fertig!

Dein Supabase User Profile Trigger ist jetzt eingerichtet und getestet! 🚀




