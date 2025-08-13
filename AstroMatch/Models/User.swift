import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var age: Int
    var bio: String
    var profileImageURL: String?
    var birthDate: Date
    var birthTime: Date
    var birthLocation: Location
    var zodiacSign: ZodiacSign
    var risingSign: ZodiacSign?
    var moonSign: ZodiacSign?
    var interests: [String]
    var lookingFor: LookingFor
    var isOnline: Bool
    var lastSeen: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         age: Int,
         bio: String = "",
         profileImageURL: String? = nil,
         birthDate: Date,
         birthTime: Date,
         birthLocation: Location,
         zodiacSign: ZodiacSign,
         risingSign: ZodiacSign? = nil,
         moonSign: ZodiacSign? = nil,
         interests: [String] = [],
         lookingFor: LookingFor = .both,
         isOnline: Bool = false,
         lastSeen: Date = Date()) {
        self.id = id
        self.name = name
        self.age = age
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocation = birthLocation
        self.zodiacSign = zodiacSign
        self.risingSign = risingSign
        self.moonSign = moonSign
        self.interests = interests
        self.lookingFor = lookingFor
        self.isOnline = isOnline
        self.lastSeen = lastSeen
    }
}

struct Location: Codable {
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
}

enum ZodiacSign: String, CaseIterable, Codable {
    case aries = "Овен"
    case taurus = "Телец"
    case gemini = "Близнецы"
    case cancer = "Рак"
    case leo = "Лев"
    case virgo = "Дева"
    case libra = "Весы"
    case scorpio = "Скорпион"
    case sagittarius = "Стрелец"
    case capricorn = "Козерог"
    case aquarius = "Водолей"
    case pisces = "Рыбы"
    
    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }
    
    var quality: Quality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }
}

enum Element: String, CaseIterable, Codable {
    case fire = "Огонь"
    case earth = "Земля"
    case air = "Воздух"
    case water = "Вода"
}

enum Quality: String, CaseIterable, Codable {
    case cardinal = "Кардинальный"
    case fixed = "Фиксированный"
    case mutable = "Мутабельный"
}

enum LookingFor: String, CaseIterable, Codable {
    case men = "Мужчин"
    case women = "Женщин"
    case both = "Всех"
}