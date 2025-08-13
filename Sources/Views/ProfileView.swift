import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingEditProfile = false
    @State private var showingNatalChart = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userManager.currentUser {
                        // Заголовок профиля
                        ProfileHeaderView(user: user)
                        
                        // Астрологическая информация
                        AstrologySection(user: user) {
                            showingNatalChart = true
                        }
                        
                        // Основная информация
                        ProfileInfoSection(user: user)
                        
                        // Настройки и кнопки
                        SettingsSection()
                        
                    } else {
                        Text("Профиль не загружен")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Редактировать") {
                    showingEditProfile = true
                }
            )
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingNatalChart) {
            if let user = userManager.currentUser, let chart = user.natalChart {
                NatalChartView(chart: chart)
            }
        }
    }
}

struct ProfileHeaderView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // Главное фото
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text("📸")
                    .font(.system(size: 60))
            }
            
            // Имя и возраст
            VStack(spacing: 4) {
                HStack {
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if user.verificationStatus != .unverified {
                        Image(systemName: user.verificationStatus.icon)
                            .foregroundColor(user.verificationStatus.color)
                    }
                }
                
                Text("\(user.age) лет")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.secondary)
                    Text("\(user.location.city), \(user.location.country)")
                        .foregroundColor(.secondary)
                }
            }
            
            // Био
            if !user.bio.isEmpty {
                Text(user.bio)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

struct AstrologySection: View {
    let user: UserProfile
    let onShowChart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Астрологический профиль")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Карта", action: onShowChart)
                    .font(.subheadline)
                    .foregroundColor(.purple)
            }
            
            if let chart = user.natalChart {
                // Основная тройка
                HStack(spacing: 20) {
                    if let sun = chart.position(of: .sun) {
                        AstroSignCard(title: "Солнце", sign: sun.sign, house: sun.house)
                    }
                    
                    if let moon = chart.position(of: .moon) {
                        AstroSignCard(title: "Луна", sign: moon.sign, house: moon.house)
                    }
                    
                    AstroSignCard(title: "Асцендент", sign: chart.ascendant, house: .first)
                }
                
                // Дополнительные планеты
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach([Planet.venus, Planet.mars, Planet.mercury, Planet.jupiter], id: \.self) { planet in
                        if let position = chart.position(of: planet) {
                            SmallAstroCard(planet: planet, position: position)
                        }
                    }
                }
                
                // Элементный баланс
                ElementBalanceView(chart: chart)
                
            } else {
                Text("Натальная карта загружается...")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct AstroSignCard: View {
    let title: String
    let sign: ZodiacSign
    let house: House
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            
            Text(sign.emoji)
                .font(.title)
            
            Text(sign.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(house.name)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct SmallAstroCard: View {
    let planet: Planet
    let position: PlanetPosition
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(planet.emoji)
                    .font(.title3)
                if position.retrograde {
                    Text("R")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Text(position.sign.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
}

struct ElementBalanceView: View {
    let chart: NatalChart
    
    var elementDistribution: [Element: Double] {
        var distribution: [Element: Double] = [:]
        
        for planet in chart.planets {
            let element = planet.sign.element
            let importance = planet.planet.importance
            distribution[element, default: 0.0] += importance
        }
        
        let total = distribution.values.reduce(0, +)
        if total > 0 {
            for element in Element.allCases {
                distribution[element] = (distribution[element] ?? 0.0) / total
            }
        }
        
        return distribution
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Баланс элементов")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                ForEach(Element.allCases, id: \.self) { element in
                    VStack(spacing: 4) {
                        Text(elementEmoji(element))
                            .font(.title3)
                        
                        Text("\(Int((elementDistribution[element] ?? 0.0) * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(element.color))
                        
                        Text(element.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func elementEmoji(_ element: Element) -> String {
        switch element {
        case .fire: return "🔥"
        case .earth: return "🌍"
        case .air: return "💨"
        case .water: return "💧"
        }
    }
}

struct ProfileInfoSection: View {
    let user: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                InfoRow(icon: "calendar", title: "Дата рождения", value: dateString(user.birthData.date))
                InfoRow(icon: "clock", title: "Время рождения", value: timeString(user.birthData.date))
                InfoRow(icon: "location", title: "Место рождения", value: "\(user.location.city)")
                InfoRow(icon: "heart", title: "Статус", value: user.verificationStatus.rawValue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct SettingsSection: View {
    var body: some View {
        VStack(spacing: 16) {
            SettingsButton(title: "Настройки поиска", icon: "slider.horizontal.3") {
                // Открыть настройки поиска
            }
            
            SettingsButton(title: "Уведомления", icon: "bell") {
                // Открыть настройки уведомлений
            }
            
            SettingsButton(title: "Конфиденциальность", icon: "lock") {
                // Открыть настройки конфиденциальности
            }
            
            SettingsButton(title: "Помощь", icon: "questionmark.circle") {
                // Открыть помощь
            }
        }
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Заглушка для редактирования профиля
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Редактирование профиля")
                    .font(.title)
                Text("В разработке...")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}