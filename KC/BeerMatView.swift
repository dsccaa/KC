import SwiftUI

struct BeerMatView: View {
    @State private var beerStains: [BeerStain] = []
    @State private var showingBeerCount = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Bierdeckel
            ZStack {
                // Bierdeckel Hintergrund (wie auf dem Bild - off-white/beige)
                Circle()
                    .fill(Color(red: 0.95, green: 0.94, blue: 0.90)) // Off-white/beige Farbe
                    .frame(width: 300, height: 300)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Striche auf dem Bierdeckel (wie im Bild)
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 2, height: 20)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .offset(y: -80) // Position der Striche
                }
                
                // Bierstiche (kleine Kreise)
                ForEach(beerStains) { stain in
                    Circle()
                        .fill(Color(red: 0.8, green: 0.6, blue: 0.2)) // Bierfarbe (golden/amber)
                        .frame(width: stain.size, height: stain.size)
                        .position(stain.position)
                        .opacity(stain.opacity)
                }
            }
            .onTapGesture {
                addBeerStain()
            }
            
            // Bieranzahl anzeigen
            if showingBeerCount {
                Text("\(beerStains.count) Kölsch")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Reset Button
            if !beerStains.isEmpty {
                Button("Bierdeckel zurücksetzen") {
                    resetBeerMat()
                }
                .font(.headline)
                .foregroundColor(.red)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                showingBeerCount = true
            }
        }
    }
    
    private func addBeerStain() {
        let newStain = BeerStain(
            position: CGPoint(
                x: CGFloat.random(in: 50...250), // Innerhalb des Bierdeckels
                y: CGFloat.random(in: 50...250)
            ),
            size: CGFloat.random(in: 15...25), // Verschiedene Größen
            opacity: Double.random(in: 0.7...1.0) // Verschiedene Transparenz
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            beerStains.append(newStain)
        }
        
        // Haptic Feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func resetBeerMat() {
        withAnimation(.easeInOut(duration: 0.5)) {
            beerStains.removeAll()
        }
    }
}

struct BeerStain: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BeerMatView()
    }
}
