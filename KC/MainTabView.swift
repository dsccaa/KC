import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Karte Tab
            MapView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "map.fill" : "map")
                    Text("Karte")
                }
                .tag(1)
            
            // Events Tab
            EventsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "calendar.badge.plus" : "calendar")
                    Text("Events")
                }
                .tag(2)
            
            // Freunde Tab
            FriendsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.2.fill" : "person.2")
                    Text("Freunde")
                }
                .tag(3)
            
            // Profil Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                    Text("Profil")
                }
                .tag(4)
        }
        .accentColor(.yellow) // Aktueller Tab in gelb
        .onAppear {
            // Tab Bar Hintergrundfarbe auf rot setzen
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.red
            
            // Icons in weiß
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            // Aktueller Tab in gelb
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.yellow
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.yellow]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(LiveAuthManager())
}
