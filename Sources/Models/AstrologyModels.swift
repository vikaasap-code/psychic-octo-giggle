import Foundation

// MARK: - Zodiac Signs
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
    
    var emoji: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }
}

// MARK: - Elements and Qualities
enum Element: String, CaseIterable, Codable {
    case fire = "Огонь"
    case earth = "Земля"
    case air = "Воздух"
    case water = "Вода"
    
    var color: String {
        switch self {
        case .fire: return "red"
        case .earth: return "brown"
        case .air: return "yellow"
        case .water: return "blue"
        }
    }
}

enum Quality: String, CaseIterable, Codable {
    case cardinal = "Кардинальный"
    case fixed = "Фиксированный"
    case mutable = "Мутабельный"
}

// MARK: - Planets
enum Planet: String, CaseIterable, Codable {
    case sun = "Солнце"
    case moon = "Луна"
    case mercury = "Меркурий"
    case venus = "Венера"
    case mars = "Марс"
    case jupiter = "Юпитер"
    case saturn = "Сатурн"
    case uranus = "Уран"
    case neptune = "Нептун"
    case pluto = "Плутон"
    case northNode = "Северный узел"
    case southNode = "Южный узел"
    
    var emoji: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        case .southNode: return "☋"
        }
    }
    
    var importance: Double {
        switch self {
        case .sun, .moon: return 1.0
        case .mercury, .venus, .mars: return 0.8
        case .jupiter, .saturn: return 0.6
        case .uranus, .neptune, .pluto: return 0.4
        case .northNode, .southNode: return 0.3
        }
    }
}

// MARK: - Houses
enum House: Int, CaseIterable, Codable {
    case first = 1, second, third, fourth, fifth, sixth
    case seventh, eighth, ninth, tenth, eleventh, twelfth
    
    var name: String {
        switch self {
        case .first: return "Дом личности"
        case .second: return "Дом ресурсов"
        case .third: return "Дом коммуникаций"
        case .fourth: return "Дом семьи"
        case .fifth: return "Дом творчества"
        case .sixth: return "Дом работы"
        case .seventh: return "Дом партнерства"
        case .eighth: return "Дом трансформации"
        case .ninth: return "Дом философии"
        case .tenth: return "Дом карьеры"
        case .eleventh: return "Дом дружбы"
        case .twelfth: return "Дом подсознания"
        }
    }
    
    var relationshipRelevance: Double {
        switch self {
        case .first, .seventh: return 1.0
        case .fifth, .eighth: return 0.8
        case .eleventh: return 0.6
        default: return 0.3
        }
    }
}

// MARK: - Aspects
enum AspectType: String, CaseIterable, Codable {
    case conjunction = "Соединение"
    case opposition = "Оппозиция"
    case trine = "Трин"
    case square = "Квадрат"
    case sextile = "Секстиль"
    case quincunx = "Квинконс"
    
    var angle: Double {
        switch self {
        case .conjunction: return 0
        case .opposition: return 180
        case .trine: return 120
        case .square: return 90
        case .sextile: return 60
        case .quincunx: return 150
        }
    }
    
    var orb: Double {
        switch self {
        case .conjunction, .opposition: return 8
        case .trine, .square: return 6
        case .sextile: return 4
        case .quincunx: return 3
        }
    }
    
    var harmonious: Bool {
        switch self {
        case .conjunction, .trine, .sextile: return true
        case .opposition, .square, .quincunx: return false
        }
    }
    
    var strength: Double {
        switch self {
        case .conjunction, .opposition: return 1.0
        case .trine, .square: return 0.8
        case .sextile: return 0.6
        case .quincunx: return 0.4
        }
    }
}

// MARK: - Birth Data
struct BirthData: Codable, Hashable {
    let date: Date
    let latitude: Double
    let longitude: Double
    let timezone: String
    
    init(date: Date, latitude: Double, longitude: Double, timezone: String = "UTC") {
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }
}

// MARK: - Planet Position
struct PlanetPosition: Codable, Hashable {
    let planet: Planet
    let sign: ZodiacSign
    let house: House
    let degree: Double
    let retrograde: Bool
    
    init(planet: Planet, sign: ZodiacSign, house: House, degree: Double, retrograde: Bool = false) {
        self.planet = planet
        self.sign = sign
        self.house = house
        self.degree = degree
        self.retrograde = retrograde
    }
}

// MARK: - Aspect
struct Aspect: Codable, Hashable {
    let planet1: Planet
    let planet2: Planet
    let type: AspectType
    let orb: Double
    let applying: Bool
    
    var strength: Double {
        let orbFactor = 1.0 - (abs(orb) / type.orb)
        return type.strength * orbFactor * (planet1.importance + planet2.importance) / 2
    }
}

// MARK: - Natal Chart
struct NatalChart: Codable, Hashable {
    let id = UUID()
    let birthData: BirthData
    let planets: [PlanetPosition]
    let houses: [House: ZodiacSign]
    let aspects: [Aspect]
    
    // Ascendant (восходящий знак)
    var ascendant: ZodiacSign {
        return houses[.first] ?? .aries
    }
    
    // Midheaven (МС)
    var midheaven: ZodiacSign {
        return houses[.tenth] ?? .capricorn
    }
    
    // Get planet position by planet
    func position(of planet: Planet) -> PlanetPosition? {
        return planets.first { $0.planet == planet }
    }
    
    // Get all aspects involving a specific planet
    func aspects(involving planet: Planet) -> [Aspect] {
        return aspects.filter { $0.planet1 == planet || $0.planet2 == planet }
    }
}

// MARK: - Compatibility Analysis
struct CompatibilityResult: Codable {
    let chart1: NatalChart
    let chart2: NatalChart
    let overallScore: Double
    let elementCompatibility: Double
    let sunMoonCompatibility: Double
    let venusCompatibility: Double
    let marsCompatibility: Double
    let communicationCompatibility: Double
    let strongAspects: [Aspect]
    let challenges: [String]
    let strengths: [String]
    
    var compatibilityLevel: CompatibilityLevel {
        switch overallScore {
        case 0.8...1.0: return .excellent
        case 0.6..<0.8: return .good
        case 0.4..<0.6: return .moderate
        case 0.2..<0.4: return .challenging
        default: return .difficult
        }
    }
}

enum CompatibilityLevel: String, CaseIterable {
    case excellent = "Отличная"
    case good = "Хорошая"
    case moderate = "Умеренная"
    case challenging = "Сложная"
    case difficult = "Трудная"
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .moderate: return "yellow"
        case .challenging: return "orange"
        case .difficult: return "red"
        }
    }
    
    var emoji: String {
        switch self {
        case .excellent: return "💚"
        case .good: return "💙"
        case .moderate: return "💛"
        case .challenging: return "🧡"
        case .difficult: return "❤️"
        }
    }
}