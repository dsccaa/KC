//
//  EventsView.swift
//  KC
//
//  Created by Dominik Schmidt on 13.09.25.
//

import SwiftUI
import SwiftData

struct EventsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: LiveAuthManager
    @Query private var beerSessions: [BeerSession]
    @Query private var events: [Event]
    
    @State private var selectedTimeframe = "Alle"
    @State private var showingCreateEvent = false
    
    private let timeframes = ["Alle", "Heute", "Diese Woche", "Diesen Monat", "Zukünftig"]
    
    // Computed Properties
    private var currentUserSessions: [BeerSession] {
        guard let currentUserId = authManager.currentUser?.id else { return [] }
        return beerSessions.filter { $0.userId == currentUserId }
    }
    
    private var filteredEvents: [Event] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeframe {
        case "Heute":
            return events.filter { calendar.isDateInToday($0.startDate) }
        case "Diese Woche":
            return events.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .weekOfYear) }
        case "Diesen Monat":
            return events.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .month) }
        case "Zukünftig":
            return events.filter { $0.startDate > now }
        default:
            return events
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        timeframeSelector
                        currentSessionsView
                        plannedEventsView
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView()
                .environment(\.modelContext, modelContext)
                .environmentObject(authManager)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Events")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
            Button(action: { showingCreateEvent = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var timeframeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(timeframes, id: \.self) { timeframe in
                    Button(action: { selectedTimeframe = timeframe }) {
                        Text(timeframe)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeframe == timeframe ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTimeframe == timeframe ? Color.yellow : Color.gray.opacity(0.3))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var currentSessionsView: some View {
        Group {
            if !currentUserSessions.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Aktuelle Beer Sessions")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    ForEach(currentUserSessions.filter { $0.status == "active" }) { session in
                        BeerSessionCard(session: session)
                    }
                }
            }
        }
    }
    
    private var plannedEventsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Geplante Events")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if filteredEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Keine Events gefunden")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Erstelle dein erstes Event!")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(filteredEvents) { event in
                    EventCard(event: event)
                }
            }
        }
    }
}

// MARK: - Beer Session Card

struct BeerSessionCard: View {
    let session: BeerSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Beer Session")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Gestartet: \(session.startedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(session.beerCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Text("Kölsch")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if let location = session.location {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(event.eventDescription ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.startDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text(event.startDate.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if let location = event.location {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                Text("\(event.attendeeCount) Teilnehmer")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if event.isPublic {
                    Image(systemName: "globe")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("Öffentlich")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Privat")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Create Event View

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: LiveAuthManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // 1 Stunde später
    @State private var isPublic = true
    @State private var maxAttendees = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Text("Event erstellen")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Event Form
                        VStack(spacing: 20) {
                            // Titel
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Titel")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Event-Titel eingeben", text: $title)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Beschreibung
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Beschreibung")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Event-Beschreibung eingeben", text: $description, axis: .vertical)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                            
                            // Ort
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ort")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Event-Ort eingeben", text: $location)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Start Datum
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                DatePicker("Start Datum", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .colorScheme(.dark)
                            }
                            
                            // End Datum
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ende")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                DatePicker("End Datum", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .colorScheme(.dark)
                            }
                            
                            // Max Teilnehmer
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Max. Teilnehmer")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Anzahl (optional)", text: $maxAttendees)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            // Öffentlich/Privat
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sichtbarkeit")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Button(action: { isPublic = true }) {
                                        HStack {
                                            Image(systemName: isPublic ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(isPublic ? .green : .gray)
                                            Text("Öffentlich")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { isPublic = false }) {
                                        HStack {
                                            Image(systemName: !isPublic ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(!isPublic ? .green : .gray)
                                            Text("Privat")
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // Create Button
                        Button(action: createEvent) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Wird erstellt..." : "Event erstellen")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || title.isEmpty)
                        .opacity(isLoading || title.isEmpty ? 0.6 : 1.0)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createEvent() {
        guard !title.isEmpty else {
            errorMessage = "Titel ist erforderlich"
            showingError = true
            return
        }
        
        guard startDate < endDate else {
            errorMessage = "Ende muss nach dem Start liegen"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let newEvent = Event(
                    title: title,
                    eventDescription: description.isEmpty ? nil : description,
                    location: location.isEmpty ? nil : location,
                    startDate: startDate,
                    endDate: endDate,
                    isPublic: isPublic,
                    maxAttendees: maxAttendees.isEmpty ? nil : Int(maxAttendees),
                    createdBy: authManager.currentUser?.id ?? UUID()
                )
                
                modelContext.insert(newEvent)
                try modelContext.save()
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Fehler beim Erstellen: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    EventsView()
        .environmentObject(LiveAuthManager())
}
