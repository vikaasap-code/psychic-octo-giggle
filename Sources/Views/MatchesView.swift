import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if userManager.matches.isEmpty {
                        EmptyMatchesView()
                    } else {
                        ForEach(userManager.matches.filter { $0.isMatched }) { match in
                            MatchCardView(match: match)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Ваши матчи")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MatchCardView: View {
    let match: Match
    @EnvironmentObject var userManager: UserManager
    @State private var showingCompatibilityDetail = false
    
    var otherUser: UserProfile {
        return match.user2 // Предполагаем, что текущий пользователь - user1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок карточки
            HStack {
                // Аватар пользователя
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text("👤")
                        .font(.system(size: 30))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(otherUser.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if let sunSign = otherUser.sunSign {
                            Text(sunSign.emoji)
                                .font(.title3)
                        }
                    }
                    
                    Text("\(otherUser.age) лет • \(otherUser.location.city)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Матч от \(formattedDate(match.matchedAt))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Рейтинг совместимости
                VStack {
                    Text("\(Int(match.compatibilityScore * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(match.compatibilityResult.compatibilityLevel.color))
                    
                    Text(match.compatibilityResult.compatibilityLevel.emoji)
                        .font(.title)
                }
            }
            .padding()
            
            // Краткая информация о совместимости
            VStack(spacing: 12) {
                HStack {
                    CompatibilityMiniScore(
                        title: "Элементы",
                        score: match.compatibilityResult.elementCompatibility,
                        icon: "🌟"
                    )
                    
                    Spacer()
                    
                    CompatibilityMiniScore(
                        title: "Эмоции",
                        score: match.compatibilityResult.sunMoonCompatibility,
                        icon: "❤️"
                    )
                    
                    Spacer()
                    
                    CompatibilityMiniScore(
                        title: "Общение",
                        score: match.compatibilityResult.communicationCompatibility,
                        icon: "💭"
                    )
                }
                
                // Кнопки действий
                HStack(spacing: 16) {
                    Button(action: { showingCompatibilityDetail = true }) {
                        HStack {
                            Image(systemName: "star.circle")
                            Text("Подробнее")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.purple, lineWidth: 1)
                        )
                    }
                    
                    NavigationLink(destination: ChatView(match: match)) {
                        HStack {
                            Image(systemName: "message.circle")
                            Text("Написать")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.purple)
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .sheet(isPresented: $showingCompatibilityDetail) {
            CompatibilityDetailView(compatibility: match.compatibilityResult)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct CompatibilityMiniScore: View {
    let title: String
    let score: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title3)
            
            Text("\(Int(score * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(scoreColor)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var scoreColor: Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .orange
        default: return .red
        }
    }
}

struct EmptyMatchesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🌟")
                .font(.system(size: 80))
            
            Text("Пока нет матчей")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Продолжайте искать совместимые души в разделе \"Поиск\"")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Звезды приготовили для вас особенные встречи ✨")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.top, 100)
    }
}