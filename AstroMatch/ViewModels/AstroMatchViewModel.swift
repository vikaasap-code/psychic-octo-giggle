import Foundation
import SwiftUI

/// Основной ViewModel для приложения AstroMatch
@MainActor
class AstroMatchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentUser: UserProfile?
    @Published var potentialMatches: [UserProfile] = []
    @Published var compatibilityResults: [CompatibilityResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab = 0
    
    // MARK: - Private Properties
    
    private var mockUsers: [UserProfile] = []
    
    // MARK: - Initialization
    
    init() {
        setupMockData()
        loadCurrentUser()
    }
    
    // MARK: - Public Methods
    
    /// Загрузка текущего пользователя
    func loadCurrentUser() {
        // В реальном приложении здесь была бы загрузка из UserDefaults или API
        if let user = mockUsers.first {
            currentUser = user
        }
    }
    
    /// Поиск потенциальных совпадений
    func findPotentialMatches() {
        guard let currentUser = currentUser else { return }
        
        isLoading = true
        
        // Имитация задержки сети
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.potentialMatches = self.mockUsers.filter { user in
                user.id != currentUser.id &&
                user.gender == currentUser.lookingFor &&
                user.lookingFor == currentUser.gender &&
                user.age >= currentUser.ageRange.lowerBound &&
                user.age <= currentUser.ageRange.upperBound
            }
            
            // Расчет совместимости для каждого потенциального совпадения
            self.calculateCompatibilityForMatches()
            
            self.isLoading = false
        }
    }
    
    /// Расчет совместимости для всех потенциальных совпадений
    func calculateCompatibilityForMatches() {
        guard let currentUser = currentUser else { return }
        
        compatibilityResults = potentialMatches.map { potentialMatch in
            CompatibilityService.calculateCompatibility(between: currentUser, and: potentialMatch)
        }
        
        // Сортировка по совместимости
        compatibilityResults.sort { $0.overallScore > $1.overallScore }
        
        // Обновление потенциальных совпадений с баллами совместимости
        potentialMatches = potentialMatches.map { user in
            var updatedUser = user
            if let result = compatibilityResults.first(where: { $0.user2.id == user.id }) {
                updatedUser.compatibilityScore = result.overallScore
            }
            return updatedUser
        }
        
        // Сортировка по совместимости
        potentialMatches.sort { $0.compatibilityScore > $1.compatibilityScore }
    }
    
    /// Получение результата совместимости для конкретного пользователя
    func getCompatibilityResult(for user: UserProfile) -> CompatibilityResult? {
        return compatibilityResults.first { $0.user2.id == user.id }
    }
    
    /// Лайк пользователя
    func likeUser(_ user: UserProfile) {
        // В реальном приложении здесь был бы API вызов
        print("Пользователь \(currentUser?.name ?? "Unknown") лайкнул \(user.name)")
    }
    
    /// Дизлайк пользователя
    func dislikeUser(_ user: UserProfile) {
        // В реальном приложении здесь был бы API вызов
        print("Пользователь \(currentUser?.name ?? "Unknown") дизлайкнул \(user.name)")
    }
    
    /// Переход к следующему пользователю
    func nextUser() {
        // Логика для перехода к следующему пользователю
        print("Переход к следующему пользователю")
    }
    
    // MARK: - Private Methods
    
    /// Настройка тестовых данных
    private func setupMockData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Создание тестовых пользователей
        mockUsers = [
            UserProfile(
                name: "Анна",
                age: 28,
                gender: .female,
                photoURL: nil,
                bio: "Люблю путешествия, астрологию и хорошие книги. Ищу серьезные отношения с духовно развитым человеком.",
                interests: ["Путешествия", "Астрология", "Книги", "Йога"],
                natalChart: NatalChart(
                    birthDate: calendar.date(byAdding: .year, value: -28, to: now) ?? now,
                    birthTime: calendar.date(bySettingHour: 14, minute: 30, second: 0, of: now) ?? now,
                    birthPlace: "Москва",
                    latitude: 55.7558,
                    longitude: 37.6176
                ),
                lookingFor: .male,
                ageRange: 25...35,
                location: "Москва"
            ),
            UserProfile(
                name: "Михаил",
                age: 30,
                gender: .male,
                photoURL: nil,
                bio: "Программист по профессии, астролог по призванию. Ищу девушку, которая разделяет мои интересы.",
                interests: ["Программирование", "Астрология", "Музыка", "Спорт"],
                natalChart: NatalChart(
                    birthDate: calendar.date(byAdding: .year, value: -30, to: now) ?? now,
                    birthTime: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now) ?? now,
                    birthPlace: "Санкт-Петербург",
                    latitude: 59.9311,
                    longitude: 30.3609
                ),
                lookingFor: .female,
                ageRange: 25...32,
                location: "Санкт-Петербург"
            ),
            UserProfile(
                name: "Елена",
                age: 26,
                gender: .female,
                photoURL: nil,
                bio: "Художница и дизайнер. Верю в силу звезд и ищу человека, который понимает важность духовного развития.",
                interests: ["Искусство", "Дизайн", "Астрология", "Медитация"],
                natalChart: NatalChart(
                    birthDate: calendar.date(byAdding: .year, value: -26, to: now) ?? now,
                    birthTime: calendar.date(bySettingHour: 18, minute: 45, second: 0, of: now) ?? now,
                    birthPlace: "Казань",
                    latitude: 55.7887,
                    longitude: 49.1221
                ),
                lookingFor: .male,
                ageRange: 24...30,
                location: "Казань"
            ),
            UserProfile(
                name: "Дмитрий",
                age: 32,
                gender: .male,
                photoURL: nil,
                bio: "Врач-кардиолог с увлечением астрологией. Ищу умную и духовно развитую девушку для серьезных отношений.",
                interests: ["Медицина", "Астрология", "Наука", "Путешествия"],
                natalChart: NatalChart(
                    birthDate: calendar.date(byAdding: .year, value: -32, to: now) ?? now,
                    birthTime: calendar.date(bySettingHour: 6, minute: 20, second: 0, of: now) ?? now,
                    birthPlace: "Новосибирск",
                    latitude: 55.0084,
                    longitude: 82.9357
                ),
                lookingFor: .female,
                ageRange: 26...34,
                location: "Новосибирск"
            ),
            UserProfile(
                name: "Мария",
                age: 29,
                gender: .female,
                photoURL: nil,
                bio: "Психолог и астролог. Помогаю людям найти свой путь через понимание звезд. Ищу партнера для духовного роста.",
                interests: ["Психология", "Астрология", "Духовное развитие", "Природа"],
                natalChart: NatalChart(
                    birthDate: calendar.date(byAdding: .year, value: -29, to: now) ?? now,
                    birthTime: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now,
                    birthPlace: "Екатеринбург",
                    latitude: 56.8519,
                    longitude: 60.6122
                ),
                lookingFor: .male,
                ageRange: 27...35,
                location: "Екатеринбург"
            )
        ]
    }
}