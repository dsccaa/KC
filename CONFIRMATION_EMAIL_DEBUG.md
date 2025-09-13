# 🔍 Bestätigungs-E-Mails debuggen

## 🚨 **Problem:**
- ✅ "Passwort vergessen" E-Mails funktionieren
- ❌ Bestätigungs-E-Mails werden nicht gesendet
- ✅ SMTP ist korrekt konfiguriert

## 🔧 **Lösungsschritte:**

### **1. Supabase Dashboard prüfen**

Gehe zu: https://supabase.com/dashboard/project/nrkjjukeracgbpvwbjam

**Authentication → Settings:**
- ✅ **Enable email confirmations** = `ON`
- ✅ **Enable email signup** = `ON`
- ✅ **SMTP Settings** = Konfiguriert

### **2. E-Mail-Templates prüfen**

**Authentication → Email Templates:**
1. Klicke auf **"Confirm signup"**
2. Prüfe, ob das Template existiert
3. Falls leer oder fehlt, erstelle es:

```html
<h2>Willkommen bei 11Kölsch! 🍺</h2>
<p>Hallo!</p>
<p>Bitte bestätige deine E-Mail-Adresse, indem du auf den folgenden Link klickst:</p>
<p><a href="{{ .ConfirmationURL }}" style="background: #ff4444; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px;">E-Mail bestätigen</a></p>
<p>Falls der Link nicht funktioniert, kopiere diesen Code: <strong>{{ .Token }}</strong></p>
<p>Viel Spaß beim Kölsch trinken! 🍺</p>
<p>Dein 11Kölsch Team</p>
```

### **3. Mögliche Ursachen:**

#### **A) E-Mail-Template fehlt oder ist leer**
- **Lösung**: Template in Supabase Dashboard erstellen

#### **B) E-Mail-Bestätigung deaktiviert**
- **Lösung**: In Authentication → Settings aktivieren

#### **C) Rate Limiting**
- **Lösung**: Prüfe Rate Limits in Authentication → Settings

#### **D) Spam-Filter**
- **Lösung**: Prüfe Spam-Ordner, füge Absender zu Kontakten hinzu

### **4. Testen:**

1. **Registriere einen neuen User**
2. **Prüfe E-Mail-Posteingang**
3. **Prüfe Spam-Ordner**
4. **Prüfe Supabase-Logs** (Authentication → Logs)

### **5. Debugging:**

**Supabase-Logs prüfen:**
1. Gehe zu **Authentication → Logs**
2. Suche nach "signup" Events
3. Prüfe, ob E-Mails versendet werden

**Browser-Konsole prüfen:**
1. Öffne Developer Tools
2. Prüfe Network-Tab für API-Calls
3. Prüfe Console für Fehlermeldungen

## 🚀 **Schnelle Lösung:**

Falls das Problem weiterhin besteht:

1. **E-Mail-Template manuell erstellen** in Supabase Dashboard
2. **Rate Limits prüfen** und ggf. erhöhen
3. **Andere E-Mail-Adresse testen** (Gmail, Outlook, etc.)
4. **Supabase-Support kontaktieren** falls nötig

## 📧 **Template-Variablen:**

- `{{ .ConfirmationURL }}` - Bestätigungs-Link
- `{{ .Token }}` - Bestätigungs-Code
- `{{ .Email }}` - E-Mail-Adresse des Users
- `{{ .SiteURL }}` - Website-URL

**Das E-Mail-Template ist wahrscheinlich das Problem!**
