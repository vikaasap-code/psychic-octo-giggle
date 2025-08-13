import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AstroMatchViewModel
    @State private var isEditing = false
    @State private var editedProfile: UserProfile?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let currentUser = viewModel.currentUser {
                        // Заголовок профиля
                        profileHeader(user: currentUser)
                        
                        // Астрологическая информация
                        astroInfoSection(user: currentUser)
                        
                        // Личная информация
                        personalInfoSection(user: currentUser)
                        
                        // Настройки поиска
                        searchSettingsSection(user: currentUser)
                        
                        // Интересы
                        interestsSection(user: currentUser)
                    } else {
                        loadingView
                    }
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Сохранить" : "Изменить") {
                        if isEditing {
                            saveProfile()
                        } else {
                            startEditing()
                        }
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
    
    // MARK: - Profile Header
    
    private func profileHeader(user: UserProfile) -> some View {
        VStack(spacing: 20) {
            // Аватар
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Text(user.natalChart.sunSign.emoji)
                    .font(.system(size: 60))
            }
            
            VStack(spacing: 8) {
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(user.age) лет")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(user.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Знак зодиака
            HStack(spacing: 12) {
                Text(user.natalChart.sunSign.emoji)
                    .font(.title2)
                
                Text(user.natalChart.sunSign.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(user.natalChart.sunSign.element.emoji)
                    .font(.title2)
                
                Text(user.natalChart.sunSign.element.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.purple.opacity(0.1))
            )
        }
    }
    
    // MARK: - Astro Info Section
    
    private func astroInfoSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Астрологическая карта")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                AstroInfoRow(
                    title: "☀️ Солнце",
                    value: user.natalChart.sunSign.rawValue,
                    subtitle: "Основной знак"
                )
                
                AstroInfoRow(
                    title: "🌙 Луна",
                    value: user.natalChart.moonSign.rawValue,
                    subtitle: "Эмоциональная природа"
                )
                
                AstroInfoRow(
                    title: "⬆️ Восходящий",
                    value: user.natalChart.risingSign.rawValue,
                    subtitle: "Внешний образ"
                )
                
                AstroInfoRow(
                    title: "📍 Место рождения",
                    value: user.natalChart.birthPlace,
                    subtitle: "Координаты: \(String(format: "%.4f", user.natalChart.latitude)), \(String(format: "%.4f", user.natalChart.longitude))"
                )
                
                AstroInfoRow(
                    title: "🕐 Время рождения",
                    value: formatTime(user.natalChart.birthTime),
                    subtitle: "Точность важна для расчета"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.05))
            )
        }
    }
    
    // MARK: - Personal Info Section
    
    private func personalInfoSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Личная информация")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if isEditing {
                    TextField("Имя", text: Binding(
                        get: { editedProfile?.name ?? user.name },
                        set: { editedProfile?.name = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Text("Возраст:")
                        Spacer()
                        TextField("Возраст", value: Binding(
                            get: { editedProfile?.age ?? user.age },
                            set: { editedProfile?.age = $0 }
                        ), format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    }
                    
                    Picker("Пол", selection: Binding(
                        get: { editedProfile?.gender ?? user.gender },
                        set: { editedProfile?.gender = $0 }
                    )) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } else {
                    InfoRow(title: "Имя", value: user.name)
                    InfoRow(title: "Возраст", value: "\(user.age) лет")
                    InfoRow(title: "Пол", value: user.gender.rawValue)
                }
                
                if isEditing {
                    TextField("О себе", text: Binding(
                        get: { editedProfile?.bio ?? user.bio },
                        set: { editedProfile?.bio = $0 }
                    ), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                } else {
                    InfoRow(title: "О себе", value: user.bio)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.05))
            )
        }
    }
    
    // MARK: - Search Settings Section
    
    private func searchSettingsSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Настройки поиска")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if isEditing {
                    Picker("Ищу", selection: Binding(
                        get: { editedProfile?.lookingFor ?? user.lookingFor },
                        set: { editedProfile?.lookingFor = $0 }
                    )) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        Text("Возрастной диапазон:")
                        Spacer()
                        Text("\(Int(editedProfile?.ageRange.lowerBound ?? user.ageRange.lowerBound)) - \(Int(editedProfile?.ageRange.upperBound ?? user.ageRange.upperBound))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    RangeSlider(
                        range: Binding(
                            get: { editedProfile?.ageRange ?? user.ageRange },
                            set: { editedProfile?.ageRange = $0 }
                        ),
                        bounds: 18...70
                    )
                } else {
                    InfoRow(title: "Ищу", value: user.lookingFor.rawValue)
                    InfoRow(title: "Возрастной диапазон", value: "\(user.ageRange.lowerBound) - \(user.ageRange.upperBound) лет")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.orange.opacity(0.05))
            )
        }
    }
    
    // MARK: - Interests Section
    
    private func interestsSection(user: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Интересы")
                .font(.headline)
                .fontWeight(.semibold)
            
            if isEditing {
                // В реальном приложении здесь был бы более сложный редактор интересов
                Text("Редактирование интересов будет доступно в следующей версии")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(user.interests, id: \.self) { interest in
                        Text(interest)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(15)
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Загрузка профиля...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func startEditing() {
        editedProfile = viewModel.currentUser
        isEditing = true
    }
    
    private func saveProfile() {
        if let edited = editedProfile {
            // В реальном приложении здесь был бы API вызов для сохранения
            print("Сохранение профиля: \(edited.name)")
        }
        isEditing = false
        editedProfile = nil
    }
}

// MARK: - Supporting Views

struct AstroInfoRow: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct RangeSlider: View {
    @Binding var range: ClosedRange<Int>
    let bounds: ClosedRange<Int>
    
    var body: some View {
        VStack {
            HStack {
                Text("\(range.lowerBound)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(range.upperBound)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Упрощенный слайдер - в реальном приложении нужен более сложный
            Text("Слайдер возрастного диапазона")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AstroMatchViewModel())
}