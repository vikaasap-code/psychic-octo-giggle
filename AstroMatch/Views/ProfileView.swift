import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            if let currentUser = userManager.currentUser {
                ScrollView {
                    VStack(spacing: 20) {
                        // Заголовок профиля
                        profileHeader(currentUser)
                        
                        // Астрологическая информация
                        astrologicalInfoSection(currentUser)
                        
                        // Личная информация
                        personalInfoSection(currentUser)
                        
                        // Настройки и действия
                        actionsSection
                    }
                    .padding()
                }
                .navigationTitle("Профиль")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.purple)
                        }
                    }
                }
                .sheet(isPresented: $showingEditProfile) {
                    EditProfileView(user: currentUser)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                .alert("Удалить аккаунт", isPresented: $showingDeleteConfirmation) {
                    Button("Отмена", role: .cancel) { }
                    Button("Удалить", role: .destructive) {
                        deleteAccount()
                    }
                } message: {
                    Text("Это действие нельзя отменить. Все ваши данные будут удалены навсегда.")
                }
            } else {
                notAuthenticatedSection
            }
        }
    }
    
    private func profileHeader(_ user: User) -> some View {
        VStack(spacing: 20) {
            // Аватар
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Text(String(user.name.prefix(1)))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Имя и возраст
            VStack(spacing: 5) {
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(user.age) лет")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Статус онлайн
            HStack(spacing: 8) {
                Circle()
                    .fill(user.isOnline ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(user.isOnline ? "Онлайн" : "Офлайн")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    private func astrologicalInfoSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Астрологическая карта")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                AstroInfoCard(
                    icon: "sun.max.fill",
                    title: "Солнечный знак",
                    value: user.zodiacSign.rawValue,
                    element: user.zodiacSign.element.rawValue,
                    quality: user.zodiacSign.quality.rawValue
                )
                
                if let moonSign = user.moonSign {
                    AstroInfoCard(
                        icon: "moon.fill",
                        title: "Лунный знак",
                        value: moonSign.rawValue,
                        element: moonSign.element.rawValue,
                        quality: moonSign.quality.rawValue
                    )
                }
                
                if let risingSign = user.risingSign {
                    AstroInfoCard(
                        icon: "arrow.up.circle.fill",
                        title: "Восходящий знак",
                        value: risingSign.rawValue,
                        element: risingSign.element.rawValue,
                        quality: risingSign.quality.rawValue
                    )
                }
                
                AstroInfoCard(
                    icon: "location.fill",
                    title: "Место рождения",
                    value: "\(user.birthLocation.city), \(user.birthLocation.country)",
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
    
    private func personalInfoSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Личная информация")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "calendar",
                    title: "Дата рождения",
                    value: formatDate(user.birthDate)
                )
                
                InfoRow(
                    icon: "clock",
                    title: "Время рождения",
                    value: formatTime(user.birthTime)
                )
                
                InfoRow(
                    icon: "person.2.fill",
                    title: "Ищу",
                    value: user.lookingFor.rawValue
                )
                
                if !user.bio.isEmpty {
                    InfoRow(
                        icon: "text.quote",
                        title: "О себе",
                        value: user.bio
                    )
                }
            }
            
            // Интересы
            if !user.interests.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Интересы")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(user.interests, id: \.self) { interest in
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
    
    private var actionsSection: some View {
        VStack(spacing: 15) {
            Button(action: { showingEditProfile = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Редактировать профиль")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(25)
            }
            
            Button(action: { showingSettings = true }) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Настройки")
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
            
            Button(action: { userManager.signOut() }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Выйти")
                }
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.red, lineWidth: 2)
                )
            }
            
            Button(action: { showingDeleteConfirmation = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Удалить аккаунт")
                }
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.red, lineWidth: 2)
                )
            }
        }
    }
    
    private var notAuthenticatedSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Необходима авторизация")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Войдите в аккаунт, чтобы просмотреть профиль")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func deleteAccount() {
        Task {
            await userManager.deleteAccount()
        }
    }
}

// MARK: - Supporting Views

struct AstroInfoCard: View {
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

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Placeholder Views

struct EditProfileView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    
    @State private var name: String
    @State private var age: Int
    @State private var bio: String
    @State private var birthDate: Date
    @State private var birthTime: Date
    @State private var selectedZodiacSign: ZodiacSign
    @State private var selectedInterests: Set<String>
    @State private var lookingFor: LookingFor
    @State private var isLoading = false
    
    private let availableInterests = [
        "Астрология", "Путешествия", "Музыка", "Книги", "Спорт", "Искусство",
        "Природа", "Йога", "Наука", "Философия", "Танцы", "Приключения",
        "Кулинария", "Фотография", "Технологии", "Медитация"
    ]
    
    init(user: User) {
        self.user = user
        self._name = State(initialValue: user.name)
        self._age = State(initialValue: user.age)
        self._bio = State(initialValue: user.bio)
        self._birthDate = State(initialValue: user.birthDate)
        self._birthTime = State(initialValue: user.birthTime)
        self._selectedZodiacSign = State(initialValue: user.zodiacSign)
        self._selectedInterests = State(initialValue: Set(user.interests))
        self._lookingFor = State(initialValue: user.lookingFor)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $name)
                    
                    Stepper("Возраст: \(age)", value: $age, in: 18...80)
                    
                    TextField("О себе", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Астрологические данные") {
                    DatePicker("Дата рождения", selection: $birthDate, displayedComponents: .date)
                    
                    DatePicker("Время рождения", selection: $birthTime, displayedComponents: .hourAndMinute)
                    
                    Picker("Знак зодиака", selection: $selectedZodiacSign) {
                        ForEach(ZodiacSign.allCases, id: \.self) { sign in
                            Text(sign.rawValue).tag(sign)
                        }
                    }
                }
                
                Section("Предпочтения") {
                    Picker("Ищу", selection: $lookingFor) {
                        ForEach(LookingFor.allCases, id: \.self) { preference in
                            Text(preference.rawValue).tag(preference)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Интересы")
                            .font(.subheadline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(availableInterests, id: \.self) { interest in
                                InterestToggleButton(
                                    title: interest,
                                    isSelected: selectedInterests.contains(interest),
                                    action: {
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else {
                                            selectedInterests.insert(interest)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveProfile()
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        let updatedUser = User(
            id: user.id,
            name: name,
            age: age,
            bio: bio,
            profileImageURL: user.profileImageURL,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocation: user.birthLocation,
            zodiacSign: selectedZodiacSign,
            risingSign: user.risingSign,
            moonSign: user.moonSign,
            interests: Array(selectedInterests),
            lookingFor: lookingFor,
            isOnline: user.isOnline,
            lastSeen: user.lastSeen
        )
        
        Task {
            await userManager.updateProfile(updatedUser)
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

struct InterestToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.purple : Color.purple.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple, lineWidth: 1)
                )
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Уведомления") {
                    Toggle("Push-уведомления", isOn: .constant(true))
                    Toggle("Email-уведомления", isOn: .constant(false))
                }
                
                Section("Конфиденциальность") {
                    Toggle("Показывать профиль всем", isOn: .constant(true))
                    Toggle("Разрешить сообщения", isOn: .constant(true))
                }
                
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Политика конфиденциальности") {
                        // Открыть политику конфиденциальности
                    }
                    
                    Button("Условия использования") {
                        // Открыть условия использования
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserManager())
}