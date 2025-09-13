import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: LiveAuthManager
    @StateObject private var dataManager = LiveDataManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("11Kölsch")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "person.2")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color.black)
                
                // Bierdeckel View
                Spacer()
                
                BeerMatView()
                
                Spacer()
                
                // Footer entfernt - keine Nutzungsbedingungen Links mehr
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(LiveAuthManager())
}
