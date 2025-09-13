# 🚀 Supabase Live Integration - Vollständige Anleitung

## 📋 **Übersicht**

Diese Anleitung führt dich durch die vollständige Integration von Supabase in die KC-App, um ausschließlich Live-Daten zu verwenden.

## 🔧 **Schritt 1: Supabase SDK installieren**

### **1.1 Xcode Package Manager:**
1. **Xcode öffnen** → KC-Projekt
2. **File** → **Add Package Dependencies**
3. **URL eingeben:** `https://github.com/supabase/supabase-swift`
4. **Add Package** klicken
5. **Supabase** auswählen → **Add Package**

### **1.2 Module auswählen:**
- ✅ **Supabase**
- ✅ **Auth**
- ✅ **Realtime**
- ✅ **PostgREST**

## 🏗️ **Schritt 2: Supabase Projekt erstellen**

### **2.1 Neues Projekt:**
1. Gehe zu [supabase.com](https://supabase.com)
2. **"Start your project"** klicken
3. **"New Project"** erstellen
4. **Projekt-Name:** `kc-beer-app`
5. **Region:** `Central Europe (Frankfurt)`
6. **Database Password:** Sicheres Passwort wählen

### **2.2 API Keys kopieren:**
1. **Settings** → **API**
2. **Project URL** kopieren
3. **anon public** Key kopieren

## 📊 **Schritt 3: Datenbank-Schema erstellen**

### **3.1 SQL Editor öffnen:**
1. **SQL Editor** in Supabase Dashboard
2. **New Query** erstellen

### **3.2 Tabellen erstellen:**

```sql
-- User Profiles Tabelle
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT NOT NULL,
    last_name TEXT,
    username TEXT UNIQUE NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Kölsch Locations Tabelle
CREATE TABLE koelsch_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    price_range TEXT,
    phone TEXT,
    website TEXT,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Beer Sessions Tabelle
CREATE TABLE beer_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id),
    location_id UUID REFERENCES koelsch_locations(id),
    duration TEXT NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ends_at TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'active',
    message TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    beer_count INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Friendships Tabelle
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id),
    friend_id UUID NOT NULL REFERENCES user_profiles(id),
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, friend_id)
);

-- RLS (Row Level Security) aktivieren
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE koelsch_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE beer_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

-- RLS Policies erstellen
CREATE POLICY "Users can view all profiles" ON user_profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Everyone can view locations" ON koelsch_locations FOR SELECT USING (true);

CREATE POLICY "Users can view all beer sessions" ON beer_sessions FOR SELECT USING (true);
CREATE POLICY "Users can create beer sessions" ON beer_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own beer sessions" ON beer_sessions FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own friendships" ON friendships FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);
CREATE POLICY "Users can create friendships" ON friendships FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own friendships" ON friendships FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = friend_id);
```

### **3.3 Test-Daten einfügen:**

```sql
-- Test Kölsch Locations
INSERT INTO koelsch_locations (name, address, latitude, longitude, price_range, phone, website, tags) VALUES
('Früh am Dom', 'Am Hof 12-14, 50667 Köln', 50.9413, 6.9583, '€€', '+49 221 2613215', 'https://www.frueh.de', ARRAY['traditional', 'tourist']),
('Gaffel am Dom', 'Bahnhofsvorplatz 1, 50667 Köln', 50.9426, 6.9581, '€€', '+49 221 2577692', 'https://www.gaffel.de', ARRAY['traditional', 'central']),
('Päffgen', 'Friesenstraße 64-66, 50670 Köln', 50.9375, 6.9603, '€€', '+49 221 135461', 'https://www.paeffgen.de', ARRAY['traditional', 'local']),
('Sion', 'Unter Taschenmacher 5-7, 50667 Köln', 50.9367, 6.9589, '€€', '+49 221 2578540', 'https://www.sion.de', ARRAY['traditional', 'historic']),
('Brauhaus zur Malzmühle', 'Heumarkt 6, 50667 Köln', 50.9361, 6.9583, '€€', '+49 221 210117', 'https://www.malzmuehle.de', ARRAY['traditional', 'historic']);
```

## 🔐 **Schritt 4: Authentication konfigurieren**

### **4.1 Phone Auth aktivieren:**
1. **Authentication** → **Providers**
2. **Phone** aktivieren
3. **Enable phone confirmations** aktivieren
4. **Enable phone change confirmations** aktivieren

### **4.2 SMS Provider konfigurieren:**
1. **Authentication** → **Providers** → **Phone**
2. **SMS Provider:** Twilio (empfohlen)
3. **Twilio Account SID** eingeben
4. **Twilio Auth Token** eingeben
5. **Twilio Phone Number** eingeben

## 📱 **Schritt 5: App konfigurieren**

### **5.1 SupabaseConfig.swift aktualisieren:**

```swift
struct SupabaseConfig {
    // Deine echten Supabase-Credentials
    static let supabaseURL = "https://dein-projekt-id.supabase.co"
    static let supabaseKey = "dein-anon-key-hier"
    
    // Rest bleibt gleich...
}
```

### **5.2 RealAuthManager.swift aktualisieren:**

```swift
import Foundation
import Supabase

class RealAuthManager: ObservableObject {
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
        supabaseKey: SupabaseConfig.supabaseKey
    )
    
    // Echte Supabase-Integration implementieren...
}
```

## 🧪 **Schritt 6: Testen**

### **6.1 App starten:**
1. **⌘+R** in Xcode
2. **Login-Seite** testen
3. **Telefonnummer** eingeben
4. **SMS-Code** eingeben

### **6.2 Datenbank prüfen:**
1. **Supabase Dashboard** → **Table Editor**
2. **user_profiles** Tabelle prüfen
3. **beer_sessions** Tabelle prüfen
4. **friendships** Tabelle prüfen

## ✅ **Erwartete Ergebnisse**

Nach der Integration:
- ✅ **Echte SMS** werden versendet
- ✅ **Echte Daten** werden in Supabase gespeichert
- ✅ **Live-Updates** über Realtime
- ✅ **Keine Mock-Daten** mehr

## 🚨 **Häufige Probleme**

### **Problem 1: SDK nicht gefunden**
**Lösung:** Supabase SDK über Xcode Package Manager installieren

### **Problem 2: SMS nicht versendet**
**Lösung:** Twilio konfigurieren oder Test-Modus verwenden

### **Problem 3: RLS-Fehler**
**Lösung:** RLS-Policies korrekt konfigurieren

## 📞 **Support**

Bei Problemen:
1. **Supabase Docs:** [supabase.com/docs](https://supabase.com/docs)
2. **Discord:** [discord.supabase.com](https://discord.supabase.com)
3. **GitHub:** [github.com/supabase/supabase](https://github.com/supabase/supabase)

---

**🎉 Nach dieser Anleitung hast du eine vollständig funktionierende App mit echten Supabase-Daten!**

