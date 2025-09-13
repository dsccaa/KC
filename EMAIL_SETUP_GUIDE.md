# 📧 E-Mail-Konfiguration für Supabase

## 🚀 Übersicht

Die E-Mail-Bestätigung ist jetzt in deinem Code integriert, aber du musst noch die SMTP-Konfiguration in Supabase einrichten, damit E-Mails tatsächlich versendet werden.

## 🔧 SMTP-Konfiguration in Supabase

### Option 1: SendGrid (Empfohlen)

1. **SendGrid Account erstellen**
   - Gehe zu [sendgrid.com](https://sendgrid.com)
   - Erstelle einen kostenlosen Account (100 E-Mails/Tag kostenlos)

2. **API Key erstellen**
   - Gehe zu Settings → API Keys
   - Erstelle einen neuen API Key mit "Full Access"
   - Kopiere den API Key

3. **In Supabase Dashboard konfigurieren**
   - Gehe zu deinem Supabase Dashboard
   - Navigiere zu Authentication → Settings
   - Scrolle zu "SMTP Settings"
   - Aktiviere "Enable custom SMTP"
   - Fülle die Felder aus:
     ```
     Host: smtp.sendgrid.net
     Port: 587
     Username: apikey
     Password: [DEIN_SENDGRID_API_KEY]
     Sender email: admin@11koelsch.de
     Sender name: 11Kölsch
     ```

### Option 2: Gmail SMTP

1. **App-Passwort erstellen**
   - Gehe zu deinem Google Account
   - Security → 2-Step Verification → App passwords
   - Erstelle ein App-Passwort für "Mail"

2. **In Supabase Dashboard konfigurieren**
   ```
   Host: smtp.gmail.com
   Port: 587
   Username: [DEINE_GMAIL_ADRESSE]
   Password: [DEIN_APP_PASSWORT]
   Sender email: [DEINE_GMAIL_ADRESSE]
   Sender name: 11Kölsch
   ```

### Option 3: Andere SMTP-Provider

- **Mailgun**: smtp.mailgun.org:587
- **Amazon SES**: email-smtp.us-east-1.amazonaws.com:587
- **Postmark**: smtp.postmarkapp.com:587

## 🧪 E-Mail-Templates anpassen

Du kannst die E-Mail-Templates in Supabase anpassen:

1. Gehe zu Authentication → Email Templates
2. Wähle "Confirm signup"
3. Passe das Template nach deinen Wünschen an

### Beispiel-Template:
```html
<h2>Willkommen bei 11Kölsch!</h2>
<p>Bitte bestätige deine E-Mail-Adresse, indem du auf den folgenden Link klickst:</p>
<p><a href="{{ .ConfirmationURL }}">E-Mail bestätigen</a></p>
<p>Falls der Link nicht funktioniert, kopiere diesen Code: {{ .Token }}</p>
<p>Viel Spaß beim Bier trinken! 🍺</p>
```

## 🔍 Troubleshooting

### E-Mails werden nicht versendet
1. **SMTP-Konfiguration prüfen**
   - Stelle sicher, dass alle SMTP-Einstellungen korrekt sind
   - Teste die Verbindung im Supabase Dashboard

2. **Spam-Ordner prüfen**
   - E-Mails landen oft im Spam-Ordner
   - Füge admin@11koelsch.de zu deinen Kontakten hinzu

3. **Rate Limits prüfen**
   - SendGrid: 100 E-Mails/Tag (kostenlos)
   - Gmail: 500 E-Mails/Tag

### E-Mail-Bestätigung funktioniert nicht
1. **Token-Format prüfen**
   - Der Token sollte 6 Zeichen lang sein
   - Nur Zahlen und Buchstaben

2. **App-Logs prüfen**
   - Schaue in die Xcode-Konsole für Fehlermeldungen
   - Prüfe die Supabase-Logs

## 📱 App-Integration

Die App ist bereits für E-Mail-Bestätigung konfiguriert:

1. **Registrierung**: Zeigt Bestätigungsnachricht
2. **E-Mail-Bestätigung**: Neue View für Code-Eingabe
3. **Automatische Weiterleitung**: Nach Bestätigung zur App

## 🚀 Nächste Schritte

1. **SMTP konfigurieren** (siehe oben)
2. **E-Mail-Templates anpassen**
3. **Testen** mit einer echten E-Mail-Adresse
4. **Production** bereit!

## 📞 Support

Bei Problemen:
1. Prüfe die Supabase-Logs
2. Teste die SMTP-Verbindung
3. Kontaktiere den Support deines E-Mail-Providers
