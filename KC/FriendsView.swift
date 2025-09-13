//
//  FriendsView.swift
//  KC
//
//  Created by Dominik Schmidt on 06.09.25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct FriendsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: LiveAuthManager
    @StateObject private var dataManager = LiveDataManager.shared
    @Query private var friendships: [Friendship]
    @Query private var userProfiles: [UserProfile]
    @Query private var beerSessions: [BeerSession]
    
    @State private var showingAddFriend = false
    @State private var activeSessions: [BeerSession] = []
    
    // Computed Property für offene Freundschaftsanfragen
    private var pendingFriendRequests: [FriendRequestData] {
        guard let currentUserId = authManager.currentUser?.id else { return [] }
        
        return friendships.compactMap { friendship in
            // Nur Freundschaften, die noch nicht bestätigt sind (status != "accepted")
            guard friendship.status != "accepted" else { return nil }
            
            // Bestimme, wer die Anfrage gestellt hat (nicht der aktuelle User)
            let requesterId = friendship.userId == currentUserId ? friendship.friendId : friendship.userId
            
            // Finde das Benutzerprofil des Anfragenden
            guard let profile = userProfiles.first(where: { $0.id == requesterId }) else { return nil }
            
            // Erstelle den Namen
            let name = profile.lastName != nil ? "\(profile.firstName) \(profile.lastName!)" : profile.firstName
            
            return FriendRequestData(
                id: friendship.id,
                name: name,
                requesterId: requesterId,
                createdAt: friendship.createdAt
            )
        }.sorted { $0.createdAt > $1.createdAt } // Neueste zuerst
    }
    
    // Computed Property für bestätigte Freunde
    private var confirmedFriends: [FriendData] {
        guard let currentUserId = authManager.currentUser?.id else { return [] }
        
        return friendships.compactMap { friendship in
            // Nur bestätigte Freundschaften
            guard friendship.status == "accepted" else { return nil }
            
            // Bestimme die Freund-ID (entweder userId oder friendId, je nachdem wer der aktuelle User ist)
            let friendId = friendship.userId == currentUserId ? friendship.friendId : friendship.userId
            
            // Finde das Benutzerprofil des Freundes
            guard let profile = userProfiles.first(where: { $0.id == friendId }) else { return nil }
            
            // Prüfe, ob der Freund eine aktive Bier-Session hat
            let isDrinking = activeSessions.contains { $0.userId == friendId && $0.status == "active" }
            
            // Bestimme die letzte Aktivität
            let lastActivity = friendship.updatedAt
            
            // Formatiere das Datum
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "de_DE")
            let lastActivityString = formatter.string(from: lastActivity)
            
            // Bestimme die Anzahl der Bier-Emojis basierend auf der Session-Dauer
            let beerEmojis = isDrinking ? 2 : 0
            
            // Erstelle den Namen
            let name = profile.lastName != nil ? "\(profile.firstName) \(profile.lastName!)" : profile.firstName
            
            return FriendData(
                name: name,
                isDrinking: isDrinking,
                lastActivity: lastActivityString,
                beerEmojis: beerEmojis
            )
        }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Freunde")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showingAddFriend = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.red)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Freunde-Liste mit zwei Bereichen
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Bereich 1: Offene Freundschaftsanfragen
                            if !pendingFriendRequests.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Offene Freundschaftsanfragen")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                        
                                        Text("\(pendingFriendRequests.count)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.red)
                                            .cornerRadius(12)
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    ForEach(pendingFriendRequests, id: \.id) { request in
                                        FriendRequestRowView(request: request) {
                                            // Akzeptiere Freundschaftsanfrage
                                            acceptFriendRequest(request)
                                        } onDecline: {
                                            // Lehne Freundschaftsanfrage ab
                                            declineFriendRequest(request)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                            
                            // Bereich 2: Meine Freunde
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Meine Freunde")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(confirmedFriends.count)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal, 20)
                                
                                if confirmedFriends.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "person.2.slash")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        
                                        Text("Noch keine Freunde")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        
                                        Text("Füge Freunde über den Einladungscode hinzu")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.vertical, 40)
                                } else {
                                    ForEach(confirmedFriends, id: \.name) { friend in
                                        FriendRowView(friend: friend)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView()
        }
        .onAppear {
            setupDataManager()
        }
    }
    
    private func setupDataManager() {
        dataManager.setModelContext(modelContext)
        
        // Lade Freundschaften von Supabase
        if let currentUserId = authManager.currentUser?.id {
            Task {
                await dataManager.loadFriendships(for: currentUserId)
                
                // Lade aktive Bier-Sessions für alle Freunde
                let friendIds = friendships.compactMap { friendship in
                    let friendId = friendship.userId == currentUserId ? friendship.friendId : friendship.userId
                    return friendId
                }
                
                let sessions = await dataManager.loadActiveBeerSessions(for: friendIds)
                
                await MainActor.run {
                    self.activeSessions = sessions
                }
            }
        }
    }
    
    // Funktion zum Akzeptieren einer Freundschaftsanfrage
    private func acceptFriendRequest(_ request: FriendRequestData) {
        guard let friendship = friendships.first(where: { $0.id == request.id }) else { return }
        
        // Aktualisiere den Status der Freundschaft
        friendship.status = "accepted"
        friendship.updatedAt = Date()
        
        // Speichere die Änderungen
        do {
            try modelContext.save()
            print("✅ Freundschaftsanfrage von \(request.name) akzeptiert")
        } catch {
            print("❌ Fehler beim Akzeptieren der Freundschaftsanfrage: \(error)")
        }
    }
    
    // Funktion zum Ablehnen einer Freundschaftsanfrage
    private func declineFriendRequest(_ request: FriendRequestData) {
        guard let friendship = friendships.first(where: { $0.id == request.id }) else { return }
        
        // Lösche die Freundschaftsanfrage
        modelContext.delete(friendship)
        
        // Speichere die Änderungen
        do {
            try modelContext.save()
            print("❌ Freundschaftsanfrage von \(request.name) abgelehnt")
        } catch {
            print("❌ Fehler beim Ablehnen der Freundschaftsanfrage: \(error)")
        }
    }
}

struct FriendData {
    let name: String
    let isDrinking: Bool
    let lastActivity: String
    let beerEmojis: Int
}

struct FriendRequestData {
    let id: UUID
    let name: String
    let requesterId: UUID
    let createdAt: Date
}

struct FriendRowView: View {
    let friend: FriendData
    
    var body: some View {
        HStack(spacing: 15) {
            // Bierglas-Icon
            BeerGlassIconView(isFull: friend.isDrinking)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(friend.name)
                        .font(.body)
                        .foregroundColor(.white)
                    
                    if friend.beerEmojis > 0 {
                        ForEach(0..<friend.beerEmojis, id: \.self) { _ in
                            Text("🍻")
                                .font(.caption)
                        }
                    }
                }
                
                Text(friend.lastActivity)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}

struct FriendRequestRowView: View {
    let request: FriendRequestData
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Profil-Icon
            Image(systemName: "person.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(request.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Möchte dein Freund werden")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("vor \(timeAgoString(from: request.createdAt))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Akzeptieren Button
            Button(action: onAccept) {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            
            // Ablehnen Button
            Button(action: onDecline) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "\(Int(timeInterval))s"
        } else if timeInterval < 3600 {
            return "\(Int(timeInterval / 60))m"
        } else if timeInterval < 86400 {
            return "\(Int(timeInterval / 3600))h"
        } else {
            return "\(Int(timeInterval / 86400))d"
        }
    }
}

struct BeerGlassIconView: View {
    let isFull: Bool
    
    var body: some View {
        ZStack {
            // Glas-Form (vereinfacht für Icon)
            Path { path in
                // Glas-Becher
                path.move(to: CGPoint(x: 5, y: 5))
                path.addLine(to: CGPoint(x: 25, y: 5))
                path.addLine(to: CGPoint(x: 27, y: 25))
                path.addLine(to: CGPoint(x: 3, y: 25))
                path.closeSubpath()
                
                // Stiel
                path.move(to: CGPoint(x: 12, y: 25))
                path.addLine(to: CGPoint(x: 12, y: 28))
                path.addLine(to: CGPoint(x: 18, y: 28))
                path.addLine(to: CGPoint(x: 18, y: 25))
                path.closeSubpath()
                
                // Fuß
                path.move(to: CGPoint(x: 10, y: 28))
                path.addLine(to: CGPoint(x: 20, y: 28))
                path.addLine(to: CGPoint(x: 20, y: 30))
                path.addLine(to: CGPoint(x: 10, y: 30))
                path.closeSubpath()
            }
            .stroke(Color.white, lineWidth: 1.5)
            .fill(Color.clear)
            
            // Bier (wenn voll)
            if isFull {
                Path { path in
                    path.move(to: CGPoint(x: 5, y: 5))
                    path.addLine(to: CGPoint(x: 25, y: 5))
                    path.addLine(to: CGPoint(x: 27, y: 25))
                    path.addLine(to: CGPoint(x: 3, y: 25))
                    path.closeSubpath()
                }
                .fill(Color.orange.opacity(0.8))
                
                // Schaum
                Path { path in
                    path.move(to: CGPoint(x: 5, y: 5))
                    path.addLine(to: CGPoint(x: 25, y: 5))
                    path.addLine(to: CGPoint(x: 23, y: 2))
                    path.addLine(to: CGPoint(x: 7, y: 2))
                    path.closeSubpath()
                }
                .fill(Color.white.opacity(0.9))
            }
        }
    }
}

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: LiveAuthManager
    @StateObject private var dataManager = LiveDataManager.shared
    @State private var invitationCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingQRScanner = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Freund hinzufügen")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Einladungscode eingeben")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Code eingeben...", text: $invitationCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    
                    Button("Freund hinzufügen") {
                        addFriend()
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(invitationCode.isEmpty || isLoading ? Color.gray.opacity(0.2) : Color.red.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .disabled(invitationCode.isEmpty || isLoading)
                    
                    // QR-Code-Scanner Option
                    Button(action: { showingQRScanner = true }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title2)
                            Text("QR-Code scannen")
                                .font(.headline)
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button("Schließen") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
                }
            }
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingQRScanner) {
            QRCodeScannerView { qrCode in
                // QR-Code wurde gescannt
                invitationCode = qrCode
                showingQRScanner = false
                addFriendByQRCode()
            }
        }
    }
    
    private func addFriendByQRCode() {
        guard let currentUserId = authManager.currentUser?.id else { 
            errorMessage = "Benutzer nicht angemeldet"
            showingError = true
            return 
        }
        
        guard !invitationCode.isEmpty else {
            errorMessage = "Kein QR-Code gescannt"
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let foundUser = try await dataManager.addFriendByQRCode(qrCode: invitationCode, currentUserId: currentUserId)
                
                await MainActor.run {
                    isLoading = false
                    if let user = foundUser {
                        print("✅ Freundschaftsanfrage erfolgreich gesendet an: \(user.firstName)")
                    }
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func addFriend() {
        guard let currentUserId = authManager.currentUser?.id else { return }
        
        isLoading = true
        
        // Simuliere Freund-ID aus Einladungscode
        let friendId = UUID() // In echter App: Code zu UUID konvertieren
        
        Task {
            await dataManager.createFriendship(userId: currentUserId, friendId: friendId)
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

// MARK: - QR Code Scanner

struct QRCodeScannerView: UIViewControllerRepresentable {
    let onQRCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onQRCodeScanned = onQRCodeScanned
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

class QRScannerViewController: UIViewController {
    var onQRCodeScanned: ((String) -> Void)?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Overlay mit Scan-Bereich
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        // Scan-Bereich (Quadrat in der Mitte)
        let scanAreaSize: CGFloat = 250
        let scanAreaView = UIView()
        scanAreaView.backgroundColor = .clear
        scanAreaView.layer.borderColor = UIColor.red.cgColor
        scanAreaView.layer.borderWidth = 2
        scanAreaView.layer.cornerRadius = 12
        scanAreaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanAreaView)
        
        // Anweisungstext
        let instructionLabel = UILabel()
        instructionLabel.text = "QR-Code in den Rahmen halten"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        // Schließen-Button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Schließen", for: .normal)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            // Overlay
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Scan-Bereich
            scanAreaView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanAreaView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanAreaView.widthAnchor.constraint(equalToConstant: scanAreaSize),
            scanAreaView.heightAnchor.constraint(equalToConstant: scanAreaSize),
            
            // Anweisungstext
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: scanAreaView.bottomAnchor, constant: 30),
            
            // Schließen-Button
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
        
        // Mask für den Scan-Bereich
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: view.bounds)
        let scanRect = CGRect(
            x: (view.bounds.width - scanAreaSize) / 2,
            y: (view.bounds.height - scanAreaSize) / 2,
            width: scanAreaSize,
            height: scanAreaSize
        )
        path.append(UIBezierPath(rect: scanRect).reversing())
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onQRCodeScanned?(stringValue)
        }
    }
}

#Preview {
    FriendsView()
        .modelContainer(for: [Friendship.self, UserProfile.self], inMemory: true)
}
