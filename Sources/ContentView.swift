import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoveryView()
                .tabItem {
                    Image(systemName: "heart.circle")
                    Text("Поиск")
                }
                .tag(0)
            
            MatchesView()
                .tabItem {
                    Image(systemName: "star.circle")
                    Text("Матчи")
                }
                .tag(1)
            
            ChatsView()
                .tabItem {
                    Image(systemName: "message.circle")
                    Text("Чаты")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Профиль")
                }
                .tag(3)
        }
        .environmentObject(userManager)
        .onAppear {
            setupSampleData()
        }
    }
    
    private func setupSampleData() {
        // Создаем тестового пользователя
        var sampleUser = UserProfile.sampleUsers[0]
        sampleUser.natalChart = AstrologyCalculator.generateNatalChart(from: sampleUser.birthData)
        userManager.login(user: sampleUser)
        
        // Создаем тестовых пользователей для поиска
        var discoveredUsers = Array(UserProfile.sampleUsers.dropFirst())
        for i in 0..<discoveredUsers.count {
            discoveredUsers[i].natalChart = AstrologyCalculator.generateNatalChart(from: discoveredUsers[i].birthData)
        }
        userManager.discoveredUsers = discoveredUsers
    }
}