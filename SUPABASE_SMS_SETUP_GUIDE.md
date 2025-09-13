# 📱 Supabase SMS Setup Guide

## Problem: SMS wird nicht versendet

Wenn die SMS nicht versendet wird, liegt das meist an der Supabase-Konfiguration. Hier ist die Lösung:

## 🔧 Schritt 1: Supabase Dashboard öffnen

1. Gehe zu [https://supabase.com](https://supabase.com)
2. Logge dich ein
3. Öffne dein Projekt "11koelsch" (nrkjjukeracgbpvwbjam)

## 📱 Schritt 2: SMS Provider konfigurieren

### Option A: Twilio (Empfohlen)

1. **Gehe zu Authentication > Providers**
2. **Aktiviere Phone Provider**
3. **Konfiguriere Twilio:**
   - **Twilio Account SID**: Deine Twilio Account SID
   - **Twilio Auth Token**: Dein Twilio Auth Token
   - **Twilio Phone Number**: Deine Twilio Telefonnummer (z.B. +1234567890)

### Option B: MessageBird

1. **Gehe zu Authentication > Providers**
2. **Aktiviere Phone Provider**
3. **Konfiguriere MessageBird:**
   - **MessageBird API Key**: Dein MessageBird API Key
   - **MessageBird Originator**: Dein MessageBird Originator

## 🔑 Schritt 3: SMS Template konfigurieren

1. **Gehe zu Authentication > Templates**
2. **Wähle "SMS"**
3. **Konfiguriere das Template:**
   ```
   Dein 11 Kölsch Code: {{ .Code }}
   
   Dieser Code ist 10 Minuten gültig.
   ```

## 🌍 Schritt 4: Telefonnummer-Format prüfen

Die App formatiert automatisch Telefonnummern im E.164 Format:
- `01712345678` → `+491712345678`
- `+491712345678` → `+491712345678` (bleibt unverändert)

## 🧪 Schritt 5: Test durchführen

1. **Öffne die App**
2. **Gib eine deutsche Telefonnummer ein** (z.B. `01712345678`)
3. **Klicke auf "SMS senden"**
4. **Prüfe die Console-Logs** für Debug-Informationen

## 🔍 Debug-Informationen

Die App zeigt jetzt detaillierte Debug-Informationen:

```
📱 LiveSupabaseService: SMS OTP senden an 01712345678
📱 LiveSupabaseService: Formatierte Telefonnummer: +491712345678
✅ LiveSupabaseService: SMS OTP erfolgreich gesendet
📱 LiveSupabaseService: Response: [Response Details]
```

## ❌ Häufige Fehler

### 1. "Invalid phone number format"
- **Lösung**: Telefonnummer muss im E.164 Format sein
- **Beispiel**: `+491712345678` statt `01712345678`

### 2. "SMS provider not configured"
- **Lösung**: SMS Provider in Supabase Dashboard konfigurieren
- **Siehe**: Schritt 2 oben

### 3. "Insufficient credits"
- **Lösung**: Twilio/MessageBird Account aufladen
- **Prüfe**: Billing in deinem SMS Provider Account

## 🆘 Support

Wenn das Problem weiterhin besteht:

1. **Prüfe die Supabase Logs** im Dashboard
2. **Prüfe die Twilio/MessageBird Logs**
3. **Kontaktiere den Support** mit den Debug-Logs

## 📋 Checkliste

- [ ] SMS Provider in Supabase konfiguriert
- [ ] SMS Template erstellt
- [ ] Telefonnummer im E.164 Format
- [ ] SMS Provider Account hat Credits
- [ ] App zeigt Debug-Logs
- [ ] SMS wird versendet

## 🎯 Nächste Schritte

Nach der Konfiguration:
1. **Teste die SMS-Funktionalität**
2. **Prüfe die OTP-Verifizierung**
3. **Teste die Registrierung**
4. **Teste den Login**

---

**Wichtig**: SMS-Kosten können anfallen. Prüfe die Preise deines SMS Providers.




