-- Events Table für 11Kölsch App
-- Erstellt am: 13.09.2025

-- Events Tabelle erstellen
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    is_public BOOLEAN DEFAULT true,
    max_attendees INTEGER,
    attendee_count INTEGER DEFAULT 0,
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes für bessere Performance
CREATE INDEX IF NOT EXISTS idx_events_start_date ON events(start_date);
CREATE INDEX IF NOT EXISTS idx_events_created_by ON events(created_by);
CREATE INDEX IF NOT EXISTS idx_events_is_public ON events(is_public);
CREATE INDEX IF NOT EXISTS idx_events_location ON events(location);

-- Event Attendees Tabelle für Teilnehmer
CREATE TABLE IF NOT EXISTS event_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'attending' CHECK (status IN ('attending', 'maybe', 'declined')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

-- Indexes für Event Attendees
CREATE INDEX IF NOT EXISTS idx_event_attendees_event_id ON event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_user_id ON event_attendees(user_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_status ON event_attendees(status);

-- RLS (Row Level Security) Policies
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;

-- Events Policies
-- Alle können öffentliche Events sehen
CREATE POLICY "Public events are viewable by everyone" ON events
    FOR SELECT USING (is_public = true);

-- Benutzer können ihre eigenen Events sehen
CREATE POLICY "Users can view their own events" ON events
    FOR SELECT USING (auth.uid() = created_by);

-- Benutzer können Events erstellen
CREATE POLICY "Users can create events" ON events
    FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Benutzer können ihre eigenen Events bearbeiten
CREATE POLICY "Users can update their own events" ON events
    FOR UPDATE USING (auth.uid() = created_by);

-- Benutzer können ihre eigenen Events löschen
CREATE POLICY "Users can delete their own events" ON events
    FOR DELETE USING (auth.uid() = created_by);

-- Event Attendees Policies
-- Benutzer können Teilnehmer von Events sehen, an denen sie teilnehmen
CREATE POLICY "Users can view attendees of their events" ON event_attendees
    FOR SELECT USING (
        auth.uid() = user_id OR 
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = event_attendees.event_id 
            AND events.created_by = auth.uid()
        )
    );

-- Benutzer können sich für Events anmelden
CREATE POLICY "Users can join events" ON event_attendees
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Benutzer können ihre Teilnahme an Events bearbeiten
CREATE POLICY "Users can update their own attendance" ON event_attendees
    FOR UPDATE USING (auth.uid() = user_id);

-- Benutzer können ihre Teilnahme an Events stornieren
CREATE POLICY "Users can delete their own attendance" ON event_attendees
    FOR DELETE USING (auth.uid() = user_id);

-- Function to update attendee_count when attendees change
CREATE OR REPLACE FUNCTION update_event_attendee_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE events 
        SET attendee_count = (
            SELECT COUNT(*) 
            FROM event_attendees 
            WHERE event_id = NEW.event_id 
            AND status = 'attending'
        )
        WHERE id = NEW.event_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE events 
        SET attendee_count = (
            SELECT COUNT(*) 
            FROM event_attendees 
            WHERE event_id = OLD.event_id 
            AND status = 'attending'
        )
        WHERE id = OLD.event_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update attendee_count
CREATE TRIGGER trigger_update_event_attendee_count
    AFTER INSERT OR UPDATE OR DELETE ON event_attendees
    FOR EACH ROW EXECUTE FUNCTION update_event_attendee_count();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER trigger_update_events_updated_at
    BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Beispiel Events einfügen (optional)
INSERT INTO events (title, description, location, start_date, end_date, is_public, created_by) VALUES
('Kölsch Runde im Brauhaus', 'Gemütliche Runde Kölsch trinken', 'Brauhaus Sion', NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day' + INTERVAL '3 hours', true, auth.uid()),
('Biergarten Event', 'Sonniger Nachmittag im Biergarten', 'Biergarten am Rhein', NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days' + INTERVAL '4 hours', true, auth.uid()),
('Private Kölsch Tasting', 'Private Verkostung verschiedener Kölsch Sorten', 'Zuhause', NOW() + INTERVAL '1 week', NOW() + INTERVAL '1 week' + INTERVAL '2 hours', false, auth.uid())
ON CONFLICT DO NOTHING;


