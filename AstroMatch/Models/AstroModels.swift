import Foundation

// MARK: - Основные астрологические модели

/// Знаки зодиака
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
        case .aries: return "♈️"
        case .taurus: return "♉️"
        case .gemini: return "♊️"
        case .cancer: return "♋️"
        case .leo: return "♌️"
        case .virgo: return "♍️"
        case .libra: return "♎️"
        case .scorpio: return "♏️"
        case .sagittarius: return "♐️"
        case .capricorn: return "♑️"
        case .aquarius: return "♒️"
        case .pisces: return "♓️"
        }
    }
}

/// Стихии
enum Element: String, CaseIterable, Codable {
    case fire = "Огонь"
    case earth = "Земля"
    case air = "Воздух"
    case water = "Вода"
    
    var emoji: String {
        switch self {
        case .fire: return "🔥"
        case .earth: return "🌍"
        case .air: return "💨"
        case .water: return "💧"
        }
    }
}

/// Качества знаков
enum Quality: String, CaseIterable, Codable {
    case cardinal = "Кардинальный"
    case fixed = "Фиксированный"
    case mutable = "Мутабельный"
}

/// Планеты
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
    
    var emoji: String {
        switch self {
        case .sun: return "☀️"
        case .moon: return "🌙"
        case .mercury: return "☿"
        case .venus: return "♀️"
        case .mars: return "♂️"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        }
    }
}

/// Дома гороскопа
enum House: Int, CaseIterable, Codable {
    case first = 1, second, third, fourth, fifth, sixth
    case seventh, eighth, ninth, tenth, eleventh, twelfth
    
    var name: String {
        switch self {
        case .first: return "1-й дом - Личность"
        case .second: return "2-й дом - Финансы"
        case .third: return "3-й дом - Коммуникация"
        case .fourth: return "4-й дом - Дом и семья"
        case .fifth: return "5-й дом - Творчество и любовь"
        case .sixth: return "6-й дом - Работа и здоровье"
        case .seventh: return "7-й дом - Партнерство"
        case .eighth: return "8-й дом - Трансформация"
        case .ninth: return "9-й дом - Философия"
        case .tenth: return "10-й дом - Карьера"
        case .eleventh: return "11-й дом - Друзья и цели"
        case .twelfth: return "12-й дом - Подсознание"
        }
    }
}

// MARK: - Натальная карта

/// Натальная карта пользователя
struct NatalChart: Codable, Identifiable {
    let id = UUID()
    let birthDate: Date
    let birthTime: Date
    let birthPlace: String
    let latitude: Double
    let longitude: Double
    
    var sunSign: ZodiacSign {
        // Упрощенный расчет знака Солнца
        let calendar = Calendar.current
        let month = calendar.component(.month, from: birthDate)
        let day = calendar.component(.day, from: birthDate)
        
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return .aries
        case (4, 20...30), (5, 1...20): return .taurus
        case (5, 21...31), (6, 1...20): return .gemini
        case (6, 21...30), (7, 1...22): return .cancer
        case (7, 23...31), (8, 1...22): return .leo
        case (8, 23...31), (9, 1...22): return .virgo
        case (9, 23...30), (10, 1...22): return .libra
        case (10, 23...31), (11, 1...21): return .scorpio
        case (11, 22...30), (12, 1...21): return .sagittarius
        case (12, 22...31), (1, 1...19): return .capricorn
        case (1, 20...31), (2, 1...18): return .aquarius
        case (2, 19...29), (3, 1...20): return .pisces
        default: return .aries
        }
    }
    
    var moonSign: ZodiacSign {
        // Упрощенный расчет - в реальном приложении нужен более сложный алгоритм
        return sunSign
    }
    
    var risingSign: ZodiacSign {
        // Упрощенный расчет - в реальном приложении нужен более сложный алгоритм
        return sunSign
    }
}

// MARK: - Профиль пользователя

/// Профиль пользователя
struct UserProfile: Codable, Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let gender: Gender
    let photoURL: String?
    let bio: String
    let interests: [String]
    let natalChart: NatalChart
    let lookingFor: Gender
    let ageRange: ClosedRange<Int>
    let location: String
    
    var compatibilityScore: Int = 0
}

/// Пол пользователя
enum Gender: String, CaseIterable, Codable {
    case male = "Мужской"
    case female = "Женский"
    case other = "Другой"
    
    var emoji: String {
        switch self {
        case .male: return "👨"
        case .female: return "👩"
        case .other: return "👤"
        }
    }
}

// MARK: - Совместимость

/// Результат анализа совместимости
struct CompatibilityResult: Codable, Identifiable {
    let id = UUID()
    let user1: UserProfile
    let user2: UserProfile
    let overallScore: Int
    let sunSignCompatibility: Int
    let moonSignCompatibility: Int
    let elementCompatibility: Int
    let qualityCompatibility: Int
    let detailedAnalysis: String
    let recommendations: [String]
    
    var isCompatible: Bool {
        overallScore >= 70
    }
}

/// Сервис для расчета совместимости
class CompatibilityService {
    
    /// Расчет общего балла совместимости
    static func calculateCompatibility(between user1: UserProfile, and user2: UserProfile) -> CompatibilityResult {
        let sunScore = calculateSunSignCompatibility(user1.natalChart.sunSign, user2.natalChart.sunSign)
        let moonScore = calculateMoonSignCompatibility(user1.natalChart.moonSign, user2.natalChart.moonSign)
        let elementScore = calculateElementCompatibility(user1.natalChart.sunSign.element, user2.natalChart.sunSign.element)
        let qualityScore = calculateQualityCompatibility(user1.natalChart.sunSign.quality, user2.natalChart.sunSign.quality)
        
        let overallScore = (sunScore + moonScore + elementScore + qualityScore) / 4
        
        let detailedAnalysis = generateDetailedAnalysis(user1: user1, user2: user2, scores: (sunScore, moonScore, elementScore, qualityScore))
        let recommendations = generateRecommendations(overallScore: overallScore, user1: user1, user2: user2)
        
        return CompatibilityResult(
            user1: user1,
            user2: user2,
            overallScore: overallScore,
            sunSignCompatibility: sunScore,
            moonSignCompatibility: moonScore,
            elementCompatibility: elementScore,
            qualityCompatibility: qualityScore,
            detailedAnalysis: detailedAnalysis,
            recommendations: recommendations
        )
    }
    
    private static func calculateSunSignCompatibility(_ sign1: ZodiacSign, _ sign2: ZodiacSign) -> Int {
        // Совместимость по знакам зодиака
        if sign1 == sign2 { return 85 } // Одинаковые знаки
        
        let compatibleSigns: [ZodiacSign: [ZodiacSign]] = [
            .aries: [.leo, .sagittarius, .gemini, .aquarius],
            .taurus: [.virgo, .capricorn, .cancer, .pisces],
            .gemini: [.libra, .aquarius, .aries, .leo],
            .cancer: [.scorpio, .pisces, .taurus, .virgo],
            .leo: [.aries, .sagittarius, .gemini, .libra],
            .virgo: [.taurus, .capricorn, .cancer, .scorpio],
            .libra: [.gemini, .aquarius, .leo, .sagittarius],
            .scorpio: [.cancer, .pisces, .virgo, .capricorn],
            .sagittarius: [.aries, .leo, .libra, .aquarius],
            .capricorn: [.taurus, .virgo, .scorpio, .pisces],
            .aquarius: [.gemini, .libra, .aries, .sagittarius],
            .pisces: [.cancer, .scorpio, .taurus, .capricorn]
        ]
        
        if let compatible = compatibleSigns[sign1], compatible.contains(sign2) {
            return 75
        }
        
        return 50 // Нейтральная совместимость
    }
    
    private static func calculateMoonSignCompatibility(_ sign1: ZodiacSign, _ sign2: ZodiacSign) -> Int {
        // Аналогично солнечному знаку, но с другими весами
        return calculateSunSignCompatibility(sign1, sign2)
    }
    
    private static func calculateElementCompatibility(_ element1: Element, _ element2: Element) -> Int {
        let compatibleElements: [Element: [Element]] = [
            .fire: [.fire, .air],
            .earth: [.earth, .water],
            .air: [.air, .fire],
            .water: [.water, .earth]
        ]
        
        if element1 == element2 { return 80 }
        if let compatible = compatibleElements[element1], compatible.contains(element2) { return 70 }
        return 40
    }
    
    private static func calculateQualityCompatibility(_ quality1: Quality, _ quality2: Quality) -> Int {
        if quality1 == quality2 { return 60 }
        if (quality1 == .cardinal && quality2 == .mutable) || (quality1 == .mutable && quality2 == .cardinal) { return 70 }
        return 50
    }
    
    private static func generateDetailedAnalysis(user1: UserProfile, user2: UserProfile, scores: (sun: Int, moon: Int, element: Int, quality: Int)) -> String {
        var analysis = "Анализ совместимости между \(user1.name) (\(user1.natalChart.sunSign.emoji) \(user1.natalChart.sunSign.rawValue)) и \(user2.name) (\(user2.natalChart.sunSign.emoji) \(user2.natalChart.sunSign.rawValue)):\n\n"
        
        analysis += "☀️ Совместимость по Солнцу: \(scores.sun)%\n"
        analysis += "🌙 Совместимость по Луне: \(scores.moon)%\n"
        analysis += "\(user1.natalChart.sunSign.element.emoji) Совместимость по стихиям: \(scores.element)%\n"
        analysis += "⚡ Совместимость по качествам: \(scores.quality)%\n\n"
        
        if scores.sun >= 75 {
            analysis += "Отличная совместимость по солнечным знакам! Ваши характеры хорошо дополняют друг друга.\n"
        } else if scores.sun >= 60 {
            analysis += "Хорошая совместимость по солнечным знакам. Есть потенциал для гармоничных отношений.\n"
        } else {
            analysis += "Совместимость по солнечным знакам требует работы над пониманием различий.\n"
        }
        
        return analysis
    }
    
    private static func generateRecommendations(overallScore: Int, user1: UserProfile, user2: UserProfile) -> [String] {
        var recommendations: [String] = []
        
        if overallScore >= 80 {
            recommendations.append("Отличная совместимость! Рекомендуем развивать отношения.")
            recommendations.append("Ваши астрологические профили идеально дополняют друг друга.")
        } else if overallScore >= 70 {
            recommendations.append("Хорошая совместимость. Есть потенциал для серьезных отношений.")
            recommendations.append("Работайте над пониманием различий в характерах.")
        } else if overallScore >= 60 {
            recommendations.append("Умеренная совместимость. Отношения возможны при взаимном желании.")
            recommendations.append("Фокусируйтесь на общих интересах и ценностях.")
        } else {
            recommendations.append("Низкая совместимость. Рекомендуем дружеские отношения.")
            recommendations.append("Различия могут стать источником конфликтов.")
        }
        
        return recommendations
    }
}