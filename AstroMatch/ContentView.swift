import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedTab = 0
    
    var body: some View {
        if userManager.isAuthenticated {
            TabView(selection: $selectedTab) {
                // Главный экран - поиск совместимых партнеров
                MatchmakingView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Поиск")
                    }
                    .tag(0)
                
                // Анализ совместимости
                CompatibilityView()
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Совместимость")
                    }
                    .tag(1)
                
                // Профиль пользователя
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Профиль")
                    }
                    .tag(2)
                
                // Чат
                ChatListView()
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("Чаты")
                    }
                    .tag(3)
            }
            .accentColor(.purple)
        } else {
            // Экран входа/регистрации
            AuthenticationView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
        .environmentObject(AstrologyService())
}