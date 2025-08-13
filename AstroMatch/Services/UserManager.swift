import Foundation
import Combine

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // В реальном приложении здесь будет проверка сохраненной сессии
        loadSavedUser()
    }
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // В реальном приложении здесь будет API вызов
            try await performSignIn(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp(userData: UserRegistrationData) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // В реальном приложении здесь будет API вызов
            let user = try await performSignUp(userData: userData)
            
            await MainActor.run {
                currentUser = user
                isLoading = false
                isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        saveUser(nil)
    }
    
    // MARK: - Profile Management
    
    func updateProfile(_ updatedUser: User) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // В реальном приложении здесь будет API вызов
            let user = try await performProfileUpdate(updatedUser)
            
            await MainActor.run {
                currentUser = user
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteAccount() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // В реальном приложении здесь будет API вызов
            try await performAccountDeletion()
            
            await MainActor.run {
                currentUser = nil
                isAuthenticated = false
                isLoading = false
                saveUser(nil)
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - User Search
    
    func searchUsers(query: String, filters: UserFilters) async throws -> [User] {
        // В реальном приложении здесь будет API вызов
        return mockUsers.filter { user in
            guard user.id != currentUser?.id else { return false }
            
            // Фильтр по имени
            if !query.isEmpty && !user.name.localizedCaseInsensitiveContains(query) {
                return false
            }
            
            // Фильтр по возрасту
            if let ageRange = filters.ageRange {
                if user.age < ageRange.lowerBound || user.age > ageRange.upperBound {
                    return false
                }
            }
            
            // Фильтр по знаку зодиака
            if let zodiacSign = filters.zodiacSign, user.zodiacSign != zodiacSign {
                return false
            }
            
            // Фильтр по стихии
            if let element = filters.element, user.zodiacSign.element != element {
                return false
            }
            
            return true
        }
    }
    
    // MARK: - Private Methods
    
    private func performSignIn(email: String, password: String) async throws {
        // Имитация задержки сети
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // В реальном приложении здесь будет проверка учетных данных
        if email.isEmpty || password.isEmpty {
            throw AuthError.invalidCredentials
        }
        
        // Создаем тестового пользователя
        let user = createMockUser()
        currentUser = user
        saveUser(user)
    }
    
    private func performSignUp(userData: UserRegistrationData) async throws -> User {
        // Имитация задержки сети
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // В реальном приложении здесь будет создание пользователя
        let user = User(
            name: userData.name,
            age: userData.age,
            bio: userData.bio,
            birthDate: userData.birthDate,
            birthTime: userData.birthTime,
            birthLocation: userData.birthLocation,
            zodiacSign: userData.zodiacSign,
            interests: userData.interests
        )
        
        saveUser(user)
        return user
    }
    
    private func performProfileUpdate(_ updatedUser: User) async throws -> User {
        // Имитация задержки сети
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // В реальном приложении здесь будет обновление профиля
        saveUser(updatedUser)
        return updatedUser
    }
    
    private func performAccountDeletion() async throws {
        // Имитация задержки сети
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // В реальном приложении здесь будет удаление аккаунта
    }
    
    private func loadSavedUser() {
        // В реальном приложении здесь будет загрузка сохраненного пользователя
        if let user = loadUser() {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    private func saveUser(_ user: User?) {
        // В реальном приложении здесь будет сохранение пользователя
        UserDefaults.standard.set(try? JSONEncoder().encode(user), forKey: "savedUser")
    }
    
    private func loadUser() -> User? {
        // В реальном приложении здесь будет загрузка пользователя
        guard let data = UserDefaults.standard.data(forKey: "savedUser") else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
    private func createMockUser() -> User {
        return User(
            name: "Тестовый Пользователь",
            age: 25,
            bio: "Люблю астрологию и новые знакомства",
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
            birthTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(),
            birthLocation: Location(city: "Москва", country: "Россия", latitude: 55.7558, longitude: 37.6176),
            zodiacSign: .libra,
            risingSign: .scorpio,
            moonSign: .cancer,
            interests: ["Астрология", "Путешествия", "Музыка", "Книги"],
            lookingFor: .both
        )
    }
    
    // MARK: - Mock Data
    
    private var mockUsers: [User] {
        [
            User(
                name: "Анна",
                age: 23,
                bio: "Ищу интересного собеседника",
                birthDate: Calendar.current.date(byAdding: .year, value: -23, to: Date()) ?? Date(),
                birthTime: Calendar.current.date(bySettingHour: 15, minute: 30, second: 0, of: Date()) ?? Date(),
                birthLocation: Location(city: "Санкт-Петербург", country: "Россия", latitude: 59.9311, longitude: 30.3609),
                zodiacSign: .taurus,
                risingSign: .gemini,
                moonSign: .pisces,
                interests: ["Искусство", "Природа", "Йога"],
                lookingFor: .men
            ),
            User(
                name: "Михаил",
                age: 28,
                bio: "Увлекаюсь астрономией и философией",
                birthDate: Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date(),
                birthTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                birthLocation: Location(city: "Екатеринбург", country: "Россия", latitude: 56.8519, longitude: 60.6122),
                zodiacSign: .aquarius,
                risingSign: .capricorn,
                moonSign: .sagittarius,
                interests: ["Наука", "Философия", "Путешествия"],
                lookingFor: .women
            ),
            User(
                name: "Елена",
                age: 26,
                bio: "Люблю активный образ жизни",
                birthDate: Calendar.current.date(byAdding: .year, value: -26, to: Date()) ?? Date(),
                birthTime: Calendar.current.date(bySettingHour: 20, minute: 15, second: 0, of: Date()) ?? Date(),
                birthLocation: Location(city: "Новосибирск", country: "Россия", latitude: 55.0084, longitude: 82.9357),
                zodiacSign: .aries,
                risingSign: .leo,
                moonSign: .gemini,
                interests: ["Спорт", "Танцы", "Приключения"],
                lookingFor: .both
            )
        ]
    }
}

// MARK: - Supporting Types

struct UserRegistrationData {
    let name: String
    let age: Int
    let bio: String
    let birthDate: Date
    let birthTime: Date
    let birthLocation: Location
    let zodiacSign: ZodiacSign
    let interests: [String]
}

struct UserFilters {
    let ageRange: ClosedRange<Int>?
    let zodiacSign: ZodiacSign?
    let element: Element?
    let quality: Quality?
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Неверный email или пароль"
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету"
        case .serverError:
            return "Ошибка сервера. Попробуйте позже"
        }
    }
}