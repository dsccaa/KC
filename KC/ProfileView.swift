//
//  ProfileView.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import SwiftUI
import SwiftData
import CoreImage.CIFilterBuiltins

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: LiveAuthManager
    @Query private var userProfiles: [UserProfile]
    @Query private var beerSessions: [BeerSession]
    @Query private var friendships: [Friendship]
    
    @State private var selectedTimeframe = "24 Stun..."
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    
    private let timeframes = ["24 Stun...", "1 Woche", "1 Monat", "1 Jahr", "Gesamt"]
    
    // Computed Properties
    private var currentUserProfile: UserProfile? {
        guard let currentUserId = authManager.currentUser?.id else { return nil }
        return userProfiles.first { $0.id == currentUserId }
    }
    
    // Computed Properties für Statistiken
    private var totalBeerSessions: Int {
        beerSessions.count
    }
    
    private var activeBeerSessions: Int {
        beerSessions.filter { $0.status == "active" }.count
    }
    
    private var completedBeerSessions: Int {
        beerSessions.filter { $0.status == "completed" }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        profileCard
                        statisticsCard
                        logoutButton
                    }
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bearbeiten") {
                        showingEditProfile = true
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .alert("Abmelden", isPresented: $showingLogoutAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Abmelden", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Möchtest du dich wirklich abmelden?")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environment(\.modelContext, modelContext)
                .environmentObject(authManager)
        }
    }
    
    private var profileHeader: some View {
        HStack {
            Spacer()
            Text("Profil")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var profileCard: some View {
        VStack(spacing: 20) {
            profileImage
            userInfo
            qrCodeSection
        }
        .padding(24)
        .background(profileCardBackground)
        .padding(.horizontal, 20)
    }
    
    private var profileImage: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.red.opacity(0.8), .red.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
            
            Image(systemName: "person.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
    }
    
    private var userInfo: some View {
        VStack(spacing: 8) {
            let profile = currentUserProfile
            
            Text("\(profile?.firstName ?? "Benutzer") \(profile?.lastName ?? "") 🍻")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let username = profile?.username, !username.isEmpty {
                Text("@\(username)")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
            
            Text("Mitglied seit \(profile?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "unbekannt")")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(authManager.currentUser?.email ?? "keine@email.de")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private var qrCodeSection: some View {
        VStack(spacing: 12) {
            Text("Mein QR-Code")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            QRCodeView(userUUID: authManager.currentUser?.id.uuidString ?? "")
                .frame(width: 120, height: 120)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            Text("Für Freunde zum Scannen")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 8)
    }
    
    private var profileCardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            statisticsHeader
            timeFrameSelector
            statisticsGrid
        }
        .padding(20)
        .background(statisticsBackground)
        .padding(.horizontal, 20)
    }
    
    private var statisticsHeader: some View {
        Text("STATISTIKEN")
            .font(.headline)
            .foregroundColor(.white)
            .padding(.bottom, 8)
    }
    
    private var timeFrameSelector: some View {
        HStack {
            Text("Zeitraum:")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Picker("Zeitraum", selection: $selectedTimeframe) {
                ForEach(timeframes, id: \.self) { timeframe in
                    Text(timeframe).tag(timeframe)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(.yellow)
        }
        .padding(.bottom, 16)
    }
    
    private var statisticsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatisticCard(
                title: "Beer Sessions",
                value: "\(totalBeerSessions)",
                icon: "beer.fill",
                color: .yellow
            )
            
            StatisticCard(
                title: "Aktive Sessions",
                value: "\(activeBeerSessions)",
                icon: "play.circle.fill",
                color: .green
            )
            
            StatisticCard(
                title: "Abgeschlossen",
                value: "\(completedBeerSessions)",
                icon: "checkmark.circle.fill",
                color: .blue
            )
            
            StatisticCard(
                title: "Freunde",
                value: "\(friendships.count)",
                icon: "person.2.fill",
                color: .purple
            )
        }
    }
    
    private var statisticsBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Abmelden")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    private func loadUserData() {
        // TODO: User-Daten laden
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct QRCodeView: View {
    let userUUID: String
    
    var body: some View {
        if let qrCodeImage = generateQRCode(from: userUUID) {
            Image(uiImage: qrCodeImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text("QR-Code Fehler")
                        .font(.caption)
                        .foregroundColor(.gray)
                )
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        return nil
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: LiveAuthManager
    @Query private var userProfiles: [UserProfile]
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var currentUserProfile: UserProfile? {
        guard let currentUserId = authManager.currentUser?.id else { return nil }
        return userProfiles.first { $0.id == currentUserId }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Text("Profil bearbeiten")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Edit Form
                        VStack(spacing: 20) {
                            // Vorname
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Vorname")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Vorname eingeben", text: $firstName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Nachname
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nachname")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Nachname eingeben", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Benutzername
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Benutzername")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("Benutzername eingeben", text: $username)
                                    .textFieldStyle(CustomTextFieldStyle())
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
                        
                        // Save Button
                        Button(action: saveProfile) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Wird gespeichert..." : "Speichern")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || firstName.isEmpty)
                        .opacity(isLoading || firstName.isEmpty ? 0.6 : 1.0)
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
        .onAppear {
            loadCurrentProfile()
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadCurrentProfile() {
        if let profile = currentUserProfile {
            firstName = profile.firstName
            lastName = profile.lastName ?? ""
            username = profile.username ?? ""
        } else {
            // Fallback für aktuellen Benutzer
            firstName = authManager.currentUser?.email?.components(separatedBy: "@").first ?? ""
        }
    }
    
    private func saveProfile() {
        guard !firstName.isEmpty else {
            errorMessage = "Vorname ist erforderlich"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                if let existingProfile = currentUserProfile {
                    // Aktualisiere bestehendes Profil
                    existingProfile.firstName = firstName
                    existingProfile.lastName = lastName.isEmpty ? nil : lastName
                    existingProfile.username = username.isEmpty ? nil : username
                    existingProfile.updatedAt = Date()
                    
                    try modelContext.save()
                    
                    // Synchronisiere mit Supabase
                    await syncWithSupabase(profile: existingProfile)
                } else {
                    // Erstelle neues Profil
                    let newProfile = UserProfile(
                        id: authManager.currentUser?.id ?? UUID(),
                        firstName: firstName,
                        lastName: lastName.isEmpty ? nil : lastName,
                        username: username.isEmpty ? nil : username
                    )
                    
                    modelContext.insert(newProfile)
                    try modelContext.save()
                    
                    // Synchronisiere mit Supabase
                    await syncWithSupabase(profile: newProfile)
                }
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    private func syncWithSupabase(profile: UserProfile) async {
        // Hier würde die Supabase-Synchronisation implementiert werden
        // Für jetzt speichern wir nur lokal
        print("🔄 Profil synchronisiert: \(profile.firstName) \(profile.lastName ?? "")")
    }
}


#Preview {
    ProfileView()
        .environmentObject(LiveAuthManager())
}