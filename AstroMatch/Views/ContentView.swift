import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AstroMatchViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // Главный экран - Поиск совпадений
            MatchView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Поиск")
                }
                .tag(0)
            
            // Экран совпадений
            MatchesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Совпадения")
                }
                .tag(1)
            
            // Профиль пользователя
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(2)
            
            // Астрологический анализ
            AstroAnalysisView()
                .tabItem {
                    Image(systemName: "moon.stars.fill")
                    Text("Анализ")
                }
                .tag(3)
        }
        .accentColor(.purple)
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}