# 🔧 E-Mail-Bestätigung reparieren

## 🚨 **Sofortige Lösung (Aktuell implementiert)**

Die E-Mail-Bestätigung ist **temporär deaktiviert**, damit die Registrierung funktioniert. User können sich jetzt direkt registrieren und anmelden.

## 📧 **E-Mail-Bestätigung aktivieren (Optional)**

Falls du E-Mail-Bestätigung aktivieren möchtest, folge diesen Schritten:

### **1. Supabase Dashboard öffnen**
- Gehe zu: https://supabase.com/dashboard/project/nrkjjukeracgbpvwbjam
- Navigiere zu **Authentication** → **Settings**

### **2. E-Mail-Einstellungen aktivieren**
- ✅ **Enable email confirmations** = `ON`
- ✅ **Enable email signup** = `ON`

### **3. SMTP konfigurieren (WICHTIG!)**

**Option A: Gmail SMTP (Einfach)**
1. Gehe zu **Authentication** → **Settings** → **SMTP Settings**
2. Aktiviere **"Enable custom SMTP"**
3. Fülle die Felder aus:
   ```
   Host: smtp.gmail.com
   Port: 587
   Username: [DEINE_GMAIL_ADRESSE]
   Password: [DEIN_APP_PASSWORT]
   Sender email: [DEINE_GMAIL_ADRESSE]
   Sender name: 11Kölsch
   ```

**Gmail App-Passwort erstellen:**
1. Gehe zu: https://myaccount.google.com/security
2. Aktiviere "2-Step Verification" (falls nicht aktiviert)
3. Gehe zu "App passwords"
4. Erstelle ein neues App-Passwort für "Mail"
5. Kopiere das 16-stellige Passwort

**Option B: SendGrid SMTP (Professionell)**
1. Erstelle einen kostenlosen SendGrid Account
2. Erstelle einen API Key
3. Konfiguriere in Supabase:
   ```
   Host: smtp.sendgrid.net
   Port: 587
   Username: apikey
   Password: [DEIN_SENDGRID_API_KEY]
   Sender email: admin@11koelsch.de
   Sender name: 11Kölsch
   ```

### **4. Code anpassen (falls E-Mail-Bestätigung aktiviert)**

Falls du E-Mail-Bestätigung aktivierst, musst du den Code anpassen:

**LiveAuthManager.swift:**
```swift
// Ändere zurück zu:
completion(true, "Bitte bestätige deine E-Mail-Adresse. Wir haben dir eine Bestätigungs-E-Mail gesendet.")
```

**RegistrationView.swift:**
```swift
// Ändere zurück zu:
confirmationMessage = error ?? "Bitte bestätige deine E-Mail-Adresse. Wir haben dir eine Bestätigungs-E-Mail gesendet."
showingEmailConfirmation = true
```

## ✅ **Aktueller Status**

- ✅ **Registrierung funktioniert** ohne E-Mail-Bestätigung
- ✅ **User können sich anmelden** direkt nach Registrierung
- ✅ **User Profile wird automatisch erstellt** durch Trigger
- ⚠️ **E-Mail-Bestätigung deaktiviert** (kann später aktiviert werden)

## 🧪 **Testen**

1. Registriere einen neuen User in der iOS App
2. User sollte sich direkt anmelden können
3. User Profile sollte automatisch erstellt werden

## 📱 **Für die Website**

Falls du eine Website hast, stelle sicher, dass:
1. **E-Mail-Bestätigung deaktiviert** ist in Supabase
2. **Registrierung funktioniert** ohne E-Mail-Bestätigung
3. **User können sich anmelden** direkt nach Registrierung

**Die Registrierung sollte jetzt sowohl in der iOS App als auch auf der Website funktionieren!**
