import SwiftUI

struct PartnerDetailView: View {
    let partner: CompatiblePartner
    @Environment(\.dismiss) private var dismiss
    @State private var showingChat = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок профиля
                    profileHeader
                    
                    // Основная информация
                    basicInfoSection
                    
                    // Астрологические детали
                    astrologicalSection
                    
                    // Анализ совместимости
                    compatibilitySection
                    
                    // Рекомендации
                    recommendationsSection
                    
                    // Кнопки действий
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatView(partner: partner)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 15) {
            // Аватар
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(String(partner.user.name.prefix(1)))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Имя и возраст
            VStack(spacing: 5) {
                Text(partner.user.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(partner.user.age) лет")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Балл совместимости
            VStack(spacing: 5) {
                Text("\(Int(partner.matchScore))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                
                Text("Совместимость")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("О себе")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !partner.user.bio.isEmpty {
                Text(partner.user.bio)
                    .font(.body)
                    .foregroundColor(.primary)
            } else {
                Text("Информация не указана")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            // Интересы
            if !partner.user.interests.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Интересы")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(partner.user.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.caption)
                                .foregroundColor(.purple)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.purple.opacity(0.1))
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var astrologicalSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Астрологическая карта")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                AstroCard(
                    icon: "sun.max.fill",
                    title: "Солнечный знак",
                    value: partner.user.zodiacSign.rawValue,
                    element: partner.user.zodiacSign.element.rawValue,
                    quality: partner.user.zodiacSign.quality.rawValue
                )
                
                if let moonSign = partner.user.moonSign {
                    AstroCard(
                        icon: "moon.fill",
                        title: "Лунный знак",
                        value: moonSign.rawValue,
                        element: moonSign.element.rawValue,
                        quality: moonSign.quality.rawValue
                    )
                }
                
                if let risingSign = partner.user.risingSign {
                    AstroCard(
                        icon: "arrow.up.circle.fill",
                        title: "Восходящий знак",
                        value: risingSign.rawValue,
                        element: risingSign.element.rawValue,
                        quality: risingSign.quality.rawValue
                    )
                }
                
                AstroCard(
                    icon: "location.fill",
                    title: "Место рождения",
                    value: "\(partner.user.birthLocation.city), \(partner.user.birthLocation.country)",
                    element: "",
                    quality: ""
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var compatibilitySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Анализ совместимости")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                CompatibilityRow(
                    title: "Солнечный знак",
                    score: partner.compatibility.sunSignCompatibility.score,
                    description: partner.compatibility.sunSignCompatibility.description,
                    harmony: partner.compatibility.sunSignCompatibility.harmony
                )
                
                if partner.compatibility.moonSignCompatibility.score > 0 {
                    CompatibilityRow(
                        title: "Лунный знак",
                        score: partner.compatibility.moonSignCompatibility.score,
                        description: partner.compatibility.moonSignCompatibility.description,
                        harmony: partner.compatibility.moonSignCompatibility.harmony
                    )
                }
                
                if partner.compatibility.risingSignCompatibility.score > 0 {
                    CompatibilityRow(
                        title: "Восходящий знак",
                        score: partner.compatibility.risingSignCompatibility.score,
                        description: partner.compatibility.risingSignCompatibility.description,
                        harmony: partner.compatibility.risingSignCompatibility.harmony
                    )
                }
                
                CompatibilityRow(
                    title: "Стихии",
                    score: partner.compatibility.elementCompatibility.score,
                    description: partner.compatibility.elementCompatibility.description,
                    harmony: getHarmonyLevel(for: partner.compatibility.elementCompatibility.score)
                )
                
                CompatibilityRow(
                    title: "Качества",
                    score: partner.compatibility.qualityCompatibility.score,
                    description: partner.compatibility.qualityCompatibility.description,
                    harmony: getHarmonyLevel(for: partner.compatibility.qualityCompatibility.score)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Рекомендации")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !partner.compatibility.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(partner.compatibility.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Text(recommendation)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
            } else {
                Text("Рекомендации будут доступны после полного анализа")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: { showingChat = true }) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("Начать чат")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(25)
            }
            
            Button(action: { dismiss() }) {
                HStack {
                    Image(systemName: "heart.fill")
                    Text("Лайкнуть")
                }
                .font(.headline)
                .foregroundColor(.purple)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.purple, lineWidth: 2)
                )
            }
        }
    }
    
    private func getHarmonyLevel(for score: Double) -> SignCompatibility.HarmonyLevel {
        switch score {
        case 80...100: return .excellent
        case 60..<80: return .good
        case 40..<60: return .neutral
        case 20..<40: return .challenging
        default: return .difficult
        }
    }
}

// MARK: - Supporting Views

struct AstroCard: View {
    let icon: String
    let title: String
    let value: String
    let element: String
    let quality: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            if !element.isEmpty {
                Text(element)
                    .font(.caption2)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
            
            if !quality.isEmpty {
                Text(quality)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct CompatibilityRow: View {
    let title: String
    let score: Double
    let description: String
    let harmony: SignCompatibility.HarmonyLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(score))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(harmony.rawValue)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(harmonyColor)
                    )
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
    
    private var harmonyColor: Color {
        switch harmony {
        case .excellent: return .green
        case .good: return .blue
        case .neutral: return .orange
        case .challenging: return .red
        case .difficult: return .purple
        }
    }
}

// MARK: - Placeholder Views

struct ChatView: View {
    let partner: CompatiblePartner
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Чат с \(partner.user.name)")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Text("Функция чата будет добавлена в следующей версии")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Чат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let mockPartner = CompatiblePartner(
        user: User(
            name: "Анна",
            age: 23,
            bio: "Ищу интересного собеседника",
            birthDate: Date(),
            birthTime: Date(),
            birthLocation: Location(city: "Москва", country: "Россия", latitude: 55.7558, longitude: 37.6176),
            zodiacSign: .taurus,
            risingSign: .gemini,
            moonSign: .pisces,
            interests: ["Искусство", "Природа", "Йога"],
            lookingFor: .men
        ),
        compatibility: Compatibility(user1Id: "1", user2Id: "2"),
        matchScore: 85.0
    )
    
    return PartnerDetailView(partner: mockPartner)
}