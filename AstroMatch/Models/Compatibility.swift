import Foundation

struct Compatibility: Identifiable, Codable {
    let id: String
    let user1Id: String
    let user2Id: String
    let overallScore: Double
    let sunSignCompatibility: SignCompatibility
    let moonSignCompatibility: SignCompatibility
    let risingSignCompatibility: SignCompatibility
    let elementCompatibility: ElementCompatibility
    let qualityCompatibility: QualityCompatibility
    let aspects: [Aspect]
    let synastry: Synastry
    let recommendations: [String]
    let createdAt: Date
    
    init(user1Id: String, user2Id: String) {
        self.id = UUID().uuidString
        self.user1Id = user1Id
        self.user2Id = user2Id
        self.overallScore = 0.0
        self.sunSignCompatibility = SignCompatibility(score: 0.0, description: "")
        self.moonSignCompatibility = SignCompatibility(score: 0.0, description: "")
        self.risingSignCompatibility = SignCompatibility(score: 0.0, description: "")
        self.elementCompatibility = ElementCompatibility(score: 0.0, description: "")
        self.qualityCompatibility = QualityCompatibility(score: 0.0, description: "")
        self.aspects = []
        self.synastry = Synastry()
        self.recommendations = []
        self.createdAt = Date()
    }
}

struct SignCompatibility: Codable {
    let score: Double // 0.0 - 100.0
    let description: String
    let harmony: HarmonyLevel
    
    enum HarmonyLevel: String, CaseIterable, Codable {
        case excellent = "Отличная"
        case good = "Хорошая"
        case neutral = "Нейтральная"
        case challenging = "Сложная"
        case difficult = "Трудная"
    }
}

struct ElementCompatibility: Codable {
    let score: Double
    let description: String
    let relationship: ElementRelationship
    
    enum ElementRelationship: String, CaseIterable, Codable {
        case harmonious = "Гармоничные"
        case complementary = "Дополняющие"
        case neutral = "Нейтральные"
        case challenging = "Сложные"
        case conflicting = "Конфликтующие"
    }
}

struct QualityCompatibility: Codable {
    let score: Double
    let description: String
    let dynamic: QualityDynamic
    
    enum QualityDynamic: String, CaseIterable, Codable {
        case balanced = "Сбалансированная"
        case dynamic = "Динамичная"
        case stable = "Стабильная"
        case challenging = "Сложная"
        case harmonious = "Гармоничная"
    }
}

struct Aspect: Codable {
    let planet1: Planet
    let planet2: Planet
    let aspectType: AspectType
    let orb: Double
    let influence: AspectInfluence
    
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
    }
    
    enum AspectType: String, CaseIterable, Codable {
        case conjunction = "Соединение"
        case sextile = "Секстиль"
        case square = "Квадрат"
        case trine = "Трин"
        case opposition = "Оппозиция"
    }
    
    enum AspectInfluence: String, CaseIterable, Codable {
        case veryHarmonious = "Очень гармоничный"
        case harmonious = "Гармоничный"
        case neutral = "Нейтральный"
        case challenging = "Сложный"
        case veryChallenging = "Очень сложный"
    }
}

struct Synastry: Codable {
    var houseOverlays: [HouseOverlay] = []
    var compositeChart: CompositeChart?
    
    struct HouseOverlay: Codable {
        let planet: Aspect.Planet
        let house: Int
        let influence: String
    }
    
    struct CompositeChart: Codable {
        let midpoints: [PlanetMidpoint]
        let compositeSun: ZodiacSign
        let compositeMoon: ZodiacSign
        let compositeAscendant: ZodiacSign?
        
        struct PlanetMidpoint: Codable {
            let planet: Aspect.Planet
            let degree: Double
            let sign: ZodiacSign
        }
    }
}

// Расширения для расчета совместимости
extension ZodiacSign {
    func compatibility(with other: ZodiacSign) -> SignCompatibility {
        let score = calculateCompatibilityScore(with: other)
        let description = generateCompatibilityDescription(with: other)
        let harmony = determineHarmonyLevel(score: score)
        
        return SignCompatibility(score: score, description: description, harmony: harmony)
    }
    
    private func calculateCompatibilityScore(with other: ZodiacSign) -> Double {
        // Базовые принципы астрологической совместимости
        if self == other {
            return 85.0 // Одинаковые знаки
        }
        
        // Тригоны (огненная, земная, воздушная, водная стихии)
        if self.element == other.element {
            return 90.0
        }
        
        // Секстили (дружественные аспекты)
        if isSextile(to: other) {
            return 75.0
        }
        
        // Квадраты (сложные аспекты)
        if isSquare(to: other) {
            return 40.0
        }
        
        // Оппозиции (полярные аспекты)
        if isOpposition(to: other) {
            return 60.0
        }
        
        return 50.0 // Нейтральная совместимость
    }
    
    private func isSextile(to other: ZodiacSign) -> Bool {
        let signs = ZodiacSign.allCases
        guard let selfIndex = signs.firstIndex(of: self),
              let otherIndex = signs.firstIndex(of: other) else { return false }
        
        let distance = abs(selfIndex - otherIndex)
        return distance == 2 || distance == 10
    }
    
    private func isSquare(to other: ZodiacSign) -> Bool {
        let signs = ZodiacSign.allCases
        guard let selfIndex = signs.firstIndex(of: self),
              let otherIndex = signs.firstIndex(of: other) else { return false }
        
        let distance = abs(selfIndex - otherIndex)
        return distance == 3 || distance == 9
    }
    
    private func isOpposition(to other: ZodiacSign) -> Bool {
        let signs = ZodiacSign.allCases
        guard let selfIndex = signs.firstIndex(of: self),
              let otherIndex = signs.firstIndex(of: other) else { return false }
        
        let distance = abs(selfIndex - otherIndex)
        return distance == 6
    }
    
    private func generateCompatibilityDescription(with other: ZodiacSign) -> String {
        if self == other {
            return "Одинаковые знаки создают глубокое понимание, но могут быть слишком похожими"
        }
        
        if self.element == other.element {
            return "Стихии \(self.element.rawValue) создают гармоничную связь и взаимопонимание"
        }
        
        if isSextile(to: other) {
            return "Секстиль создает дружественную и поддерживающую связь"
        }
        
        if isSquare(to: other) {
            return "Квадрат создает напряжение, но может привести к росту через преодоление трудностей"
        }
        
        if isOpposition(to: other) {
            return "Оппозиция создает полярность, которая может быть как притягательной, так и сложной"
        }
        
        return "Нейтральная совместимость - знаки не имеют особых аспектов друг к другу"
    }
    
    private func determineHarmonyLevel(score: Double) -> SignCompatibility.HarmonyLevel {
        switch score {
        case 80...100: return .excellent
        case 60..<80: return .good
        case 40..<60: return .neutral
        case 20..<40: return .challenging
        default: return .difficult
        }
    }
}