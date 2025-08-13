import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable, Identifiable, Hashable {
    let id = UUID()
    var name: String
    var age: Int
    var bio: String
    var photos: [String] // URLs to photos
    var birthData: BirthData
    var natalChart: NatalChart?
    var preferences: UserPreferences
    var location: Location
    var isOnline: Bool
    var lastSeen: Date
    var verificationStatus: VerificationStatus
    
    init(name: String, age: Int, bio: String, photos: [String] = [], birthData: BirthData, preferences: UserPreferences, location: Location) {
        self.name = name
        self.age = age
        self.bio = bio
        self.photos = photos
        self.birthData = birthData
        self.preferences = preferences
        self.location = location
        self.isOnline = false
        self.lastSeen = Date()
        self.verificationStatus = .unverified
    }
    
    var primaryPhoto: String? {
        return photos.first
    }
    
    var sunSign: ZodiacSign? {
        return natalChart?.position(of: .sun)?.sign
    }
    
    var moonSign: ZodiacSign? {
        return natalChart?.position(of: .moon)?.sign
    }
    
    var ascendantSign: ZodiacSign? {
        return natalChart?.ascendant
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable, Hashable {
    var ageRange: ClosedRange<Int>
    var maxDistance: Double // в километрах
    var showOnlyVerified: Bool
    var compatibilityThreshold: Double // минимальный уровень совместимости
    var interestedInGenders: [Gender]
    var dealBreakers: [DealBreaker]
    var importantAspects: [Planet] // планеты, которые особенно важны для пользователя
    
    init() {
        self.ageRange = 18...65
        self.maxDistance = 50.0
        self.showOnlyVerified = false
        self.compatibilityThreshold = 0.5
        self.interestedInGenders = [.male, .female]
        self.dealBreakers = []
        self.importantAspects = [.sun, .moon, .venus]
    }
}

// MARK: - Supporting Enums
enum Gender: String, CaseIterable, Codable {
    case male = "Мужской"
    case female = "Женский"
    case nonBinary = "Небинарный"
    case other = "Другой"
}

enum VerificationStatus: String, CaseIterable, Codable {
    case unverified = "Не подтвержден"
    case verified = "Подтвержден"
    case premium = "Премиум"
    
    var icon: String {
        switch self {
        case .unverified: return ""
        case .verified: return "checkmark.circle.fill"
        case .premium: return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .unverified: return .gray
        case .verified: return .blue
        case .premium: return .yellow
        }
    }
}

enum DealBreaker: String, CaseIterable, Codable {
    case smoking = "Курение"
    case drinking = "Алкоголь"
    case children = "Дети"
    case pets = "Домашние животные"
    case religion = "Религия"
    case politics = "Политика"
    
    var emoji: String {
        switch self {
        case .smoking: return "🚭"
        case .drinking: return "🍷"
        case .children: return "👶"
        case .pets: return "🐕"
        case .religion: return "🙏"
        case .politics: return "🗳️"
        }
    }
}

// MARK: - Location
struct Location: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let city: String
    let country: String
    
    func distance(to other: Location) -> Double {
        let earthRadius = 6371.0 // км
        
        let lat1Rad = latitude * .pi / 180
        let lat2Rad = other.latitude * .pi / 180
        let deltaLatRad = (other.latitude - latitude) * .pi / 180
        let deltaLngRad = (other.longitude - longitude) * .pi / 180
        
        let a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLngRad / 2) * sin(deltaLngRad / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
}

// MARK: - Match
struct Match: Codable, Identifiable, Hashable {
    let id = UUID()
    let user1: UserProfile
    let user2: UserProfile
    let compatibilityResult: CompatibilityResult
    let matchedAt: Date
    var isLikedByUser1: Bool
    var isLikedByUser2: Bool
    var conversationId: UUID?
    
    var isMatched: Bool {
        return isLikedByUser1 && isLikedByUser2
    }
    
    var compatibilityScore: Double {
        return compatibilityResult.overallScore
    }
    
    init(user1: UserProfile, user2: UserProfile, compatibilityResult: CompatibilityResult) {
        self.user1 = user1
        self.user2 = user2
        self.compatibilityResult = compatibilityResult
        self.matchedAt = Date()
        self.isLikedByUser1 = false
        self.isLikedByUser2 = false
    }
}

// MARK: - Conversation
struct Conversation: Codable, Identifiable, Hashable {
    let id = UUID()
    let participant1: UserProfile
    let participant2: UserProfile
    var messages: [Message]
    let createdAt: Date
    var lastActivity: Date
    var isActive: Bool
    
    init(participant1: UserProfile, participant2: UserProfile) {
        self.participant1 = participant1
        self.participant2 = participant2
        self.messages = []
        self.createdAt = Date()
        self.lastActivity = Date()
        self.isActive = true
    }
    
    var lastMessage: Message? {
        return messages.last
    }
    
    func otherParticipant(currentUserId: UUID) -> UserProfile? {
        if participant1.id == currentUserId {
            return participant2
        } else if participant2.id == currentUserId {
            return participant1
        }
        return nil
    }
}

// MARK: - Message
struct Message: Codable, Identifiable, Hashable {
    let id = UUID()
    let senderId: UUID
    let content: String
    let timestamp: Date
    var isRead: Bool
    let type: MessageType
    
    init(senderId: UUID, content: String, type: MessageType = .text) {
        self.senderId = senderId
        self.content = content
        self.timestamp = Date()
        self.isRead = false
        self.type = type
    }
}

enum MessageType: String, CaseIterable, Codable {
    case text = "Текст"
    case image = "Изображение"
    case astroInsight = "Астрологический совет"
    case compatibilityUpdate = "Обновление совместимости"
}

// MARK: - App State Models
class UserManager: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var discoveredUsers: [UserProfile] = []
    @Published var matches: [Match] = []
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    
    func login(user: UserProfile) {
        currentUser = user
        if user.natalChart == nil {
            generateNatalChart(for: user)
        }
    }
    
    private func generateNatalChart(for user: UserProfile) {
        guard var updatedUser = currentUser else { return }
        updatedUser.natalChart = AstrologyCalculator.generateNatalChart(from: user.birthData)
        currentUser = updatedUser
    }
    
    func likeUser(_ likedUser: UserProfile) -> Match? {
        guard let currentUser = currentUser else { return nil }
        
        // Проверяем, есть ли уже матч
        if let existingMatch = matches.first(where: {
            ($0.user1.id == currentUser.id && $0.user2.id == likedUser.id) ||
            ($0.user1.id == likedUser.id && $0.user2.id == currentUser.id)
        }) {
            var updatedMatch = existingMatch
            if existingMatch.user1.id == currentUser.id {
                updatedMatch.isLikedByUser1 = true
            } else {
                updatedMatch.isLikedByUser2 = true
            }
            
            // Обновляем матч в массиве
            if let index = matches.firstIndex(where: { $0.id == existingMatch.id }) {
                matches[index] = updatedMatch
            }
            
            // Если взаимная симпатия, создаем разговор
            if updatedMatch.isMatched && updatedMatch.conversationId == nil {
                let conversation = Conversation(participant1: currentUser, participant2: likedUser)
                conversations.append(conversation)
                matches[matches.firstIndex(where: { $0.id == updatedMatch.id })!].conversationId = conversation.id
            }
            
            return updatedMatch
        } else {
            // Создаем новый матч
            guard let currentChart = currentUser.natalChart,
                  let likedChart = likedUser.natalChart else { return nil }
            
            let compatibility = CompatibilityAnalyzer.analyzeCompatibility(between: currentChart, and: likedChart)
            var newMatch = Match(user1: currentUser, user2: likedUser, compatibilityResult: compatibility)
            newMatch.isLikedByUser1 = true
            
            matches.append(newMatch)
            return newMatch
        }
    }
    
    func sendMessage(_ content: String, to conversation: Conversation, type: MessageType = .text) {
        guard let currentUser = currentUser else { return }
        
        let message = Message(senderId: currentUser.id, content: content, type: type)
        
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].messages.append(message)
            conversations[index].lastActivity = Date()
        }
    }
}

// MARK: - Sample Data
extension UserProfile {
    static let sampleUsers: [UserProfile] = [
        UserProfile(
            name: "Анна",
            age: 28,
            bio: "Люблю астрологию, йогу и путешествия. Ищу глубокие связи ✨",
            photos: ["https://example.com/photo1.jpg"],
            birthData: BirthData(
                date: Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 15, hour: 14, minute: 30))!,
                latitude: 55.7558,
                longitude: 37.6173
            ),
            preferences: UserPreferences(),
            location: Location(latitude: 55.7558, longitude: 37.6173, city: "Москва", country: "Россия")
        ),
        UserProfile(
            name: "Дмитрий",
            age: 32,
            bio: "Музыкант и художник. Верю в силу звезд 🌟",
            photos: ["https://example.com/photo2.jpg"],
            birthData: BirthData(
                date: Calendar.current.date(from: DateComponents(year: 1991, month: 10, day: 8, hour: 9, minute: 15))!,
                latitude: 59.9311,
                longitude: 30.3609
            ),
            preferences: UserPreferences(),
            location: Location(latitude: 59.9311, longitude: 30.3609, city: "Санкт-Петербург", country: "Россия")
        ),
        UserProfile(
            name: "София",
            age: 25,
            bio: "Психолог, изучающий астрологию. Водолей с восходящим Львом 🦁",
            photos: ["https://example.com/photo3.jpg"],
            birthData: BirthData(
                date: Calendar.current.date(from: DateComponents(year: 1998, month: 2, day: 12, hour: 18, minute: 45))!,
                latitude: 56.8431,
                longitude: 60.6454
            ),
            preferences: UserPreferences(),
            location: Location(latitude: 56.8431, longitude: 60.6454, city: "Екатеринбург", country: "Россия")
        )
    ]
}