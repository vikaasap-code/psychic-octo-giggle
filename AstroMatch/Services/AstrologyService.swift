import Foundation
import Combine

class AstrologyService: ObservableObject {
    @Published var isCalculating = false
    
    // Расчет натальной карты
    func calculateNatalChart(birthDate: Date, birthTime: Date, birthLocation: Location) async throws -> NatalChart {
        isCalculating = true
        defer { isCalculating = false }
        
        // Здесь будет интеграция с реальным астрологическим API
        // Пока используем упрощенные расчеты
        
        let sunSign = calculateSunSign(birthDate: birthDate)
        let moonSign = calculateMoonSign(birthDate: birthDate, birthTime: birthTime)
        let risingSign = calculateRisingSign(birthDate: birthDate, birthTime: birthTime, location: birthLocation)
        
        let planets = calculatePlanetPositions(birthDate: birthDate, birthTime: birthTime)
        let houses = calculateHousePositions(birthDate: birthDate, birthTime: birthTime, location: birthLocation)
        
        return NatalChart(
            sunSign: sunSign,
            moonSign: moonSign,
            risingSign: risingSign,
            planets: planets,
            houses: houses,
            aspects: calculateAspects(planets: planets)
        )
    }
    
    // Расчет совместимости между двумя пользователями
    func calculateCompatibility(user1: User, user2: User) async throws -> Compatibility {
        isCalculating = true
        defer { isCalculating = false }
        
        var compatibility = Compatibility(user1Id: user1.id, user2Id: user2.id)
        
        // Расчет совместимости по знакам
        compatibility.sunSignCompatibility = user1.zodiacSign.compatibility(with: user2.zodiacSign)
        
        if let moon1 = user1.moonSign, let moon2 = user2.moonSign {
            compatibility.moonSignCompatibility = moon1.compatibility(with: moon2)
        }
        
        if let rising1 = user1.risingSign, let rising2 = user2.risingSign {
            compatibility.risingSignCompatibility = rising1.compatibility(with: rising2)
        }
        
        // Расчет совместимости по стихиям
        compatibility.elementCompatibility = calculateElementCompatibility(user1: user1, user2: user2)
        
        // Расчет совместимости по качествам
        compatibility.qualityCompatibility = calculateQualityCompatibility(user1: user1, user2: user2)
        
        // Расчет аспектов
        compatibility.aspects = calculateSynastryAspects(user1: user1, user2: user2)
        
        // Расчет общего балла
        compatibility.overallScore = calculateOverallScore(compatibility: compatibility)
        
        // Генерация рекомендаций
        compatibility.recommendations = generateRecommendations(compatibility: compatibility)
        
        return compatibility
    }
    
    // Поиск совместимых партнеров
    func findCompatiblePartners(for user: User, from candidates: [User], limit: Int = 20) async throws -> [CompatiblePartner] {
        isCalculating = true
        defer { isCalculating = false }
        
        var compatiblePartners: [CompatiblePartner] = []
        
        for candidate in candidates {
            guard candidate.id != user.id else { continue }
            
            // Базовые фильтры
            if !isBasicCompatibility(user: user, candidate: candidate) {
                continue
            }
            
            // Расчет совместимости
            let compatibility = try await calculateCompatibility(user1: user, user2: candidate)
            
            let partner = CompatiblePartner(
                user: candidate,
                compatibility: compatibility,
                matchScore: compatibility.overallScore
            )
            
            compatiblePartners.append(partner)
        }
        
        // Сортировка по баллу совместимости
        compatiblePartners.sort { $0.matchScore > $1.matchScore }
        
        return Array(compatiblePartners.prefix(limit))
    }
    
    // MARK: - Private Methods
    
    private func calculateSunSign(birthDate: Date) -> ZodiacSign {
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
    
    private func calculateMoonSign(birthDate: Date, birthTime: Date) -> ZodiacSign {
        // Упрощенный расчет лунного знака
        // В реальном приложении здесь будет сложный астрономический расчет
        let timeInterval = birthTime.timeIntervalSince(birthDate)
        let moonCycle = 29.53 * 24 * 3600 // Лунный месяц в секундах
        
        let moonPhase = (timeInterval.truncatingRemainder(dividingBy: moonCycle)) / moonCycle
        let signIndex = Int(moonPhase * 12)
        
        return ZodiacSign.allCases[signIndex]
    }
    
    private func calculateRisingSign(birthDate: Date, birthTime: Date, location: Location) -> ZodiacSign {
        // Упрощенный расчет восходящего знака
        // В реальном приложении здесь будет расчет с учетом времени и места рождения
        let hour = Calendar.current.component(.hour, from: birthTime)
        let signIndex = (hour + Int(location.longitude / 15)) % 12
        
        return ZodiacSign.allCases[signIndex]
    }
    
    private func calculatePlanetPositions(birthDate: Date, birthTime: Date) -> [PlanetPosition] {
        // Упрощенный расчет позиций планет
        // В реальном приложении здесь будет интеграция с эфемеридами
        return []
    }
    
    private func calculateHousePositions(birthDate: Date, birthTime: Date, location: Location) -> [HousePosition] {
        // Упрощенный расчет позиций домов
        // В реальном приложении здесь будет расчет с учетом времени и места рождения
        return []
    }
    
    private func calculateAspects(planets: [PlanetPosition]) -> [Aspect] {
        // Расчет аспектов между планетами
        return []
    }
    
    private func calculateElementCompatibility(user1: User, user2: User) -> ElementCompatibility {
        let element1 = user1.zodiacSign.element
        let element2 = user2.zodiacSign.element
        
        let score: Double
        let relationship: ElementCompatibility.ElementRelationship
        let description: String
        
        switch (element1, element2) {
        case (.fire, .fire), (.earth, .earth), (.air, .air), (.water, .water):
            score = 90.0
            relationship = .harmonious
            description = "Стихии \(element1.rawValue) создают гармоничную связь"
            
        case (.fire, .air), (.air, .fire):
            score = 85.0
            relationship = .complementary
            description = "Огонь и Воздух дополняют друг друга"
            
        case (.earth, .water), (.water, .earth):
            score = 80.0
            relationship = .complementary
            description = "Земля и Вода создают плодородную связь"
            
        case (.fire, .water), (.water, .fire):
            score = 30.0
            relationship = .conflicting
            description = "Огонь и Вода могут конфликтовать"
            
        case (.earth, .air), (.air, .earth):
            score = 40.0
            relationship = .challenging
            description = "Земля и Воздух имеют разные подходы"
            
        default:
            score = 50.0
            relationship = .neutral
            description = "Нейтральная совместимость стихий"
        }
        
        return ElementCompatibility(score: score, description: description, relationship: relationship)
    }
    
    private func calculateQualityCompatibility(user1: User, user2: User) -> QualityCompatibility {
        let quality1 = user1.zodiacSign.quality
        let quality2 = user2.zodiacSign.quality
        
        let score: Double
        let dynamic: QualityCompatibility.QualityDynamic
        let description: String
        
        switch (quality1, quality2) {
        case (.cardinal, .cardinal):
            score = 70.0
            dynamic = .dynamic
            description = "Два кардинальных знака создают динамичную пару"
            
        case (.fixed, .fixed):
            score = 80.0
            dynamic = .stable
            description = "Фиксированные знаки обеспечивают стабильность"
            
        case (.mutable, .mutable):
            score = 75.0
            dynamic = .balanced
            description = "Мутабельные знаки легко адаптируются"
            
        case (.cardinal, .fixed), (.fixed, .cardinal):
            score = 60.0
            dynamic = .challenging
            description = "Кардинальный и фиксированный знаки могут конфликтовать"
            
        case (.cardinal, .mutable), (.mutable, .cardinal):
            score = 65.0
            dynamic = .harmonious
            description = "Кардинальный и мутабельный знаки хорошо дополняют друг друга"
            
        case (.fixed, .mutable), (.mutable, .fixed):
            score = 70.0
            dynamic = .balanced
            description = "Фиксированный и мутабельный знаки создают баланс"
            
        default:
            score = 50.0
            dynamic = .neutral
            description = "Нейтральная совместимость качеств"
        }
        
        return QualityCompatibility(score: score, description: description, dynamic: dynamic)
    }
    
    private func calculateSynastryAspects(user1: User, user2: User) -> [Aspect] {
        // Расчет аспектов между планетами двух натальных карт
        // В реальном приложении здесь будет сложный расчет
        return []
    }
    
    private func calculateOverallScore(compatibility: Compatibility) -> Double {
        var totalScore = 0.0
        var weightSum = 0.0
        
        // Солнечный знак (вес 30%)
        totalScore += compatibility.sunSignCompatibility.score * 0.3
        weightSum += 0.3
        
        // Лунный знак (вес 25%)
        if compatibility.moonSignCompatibility.score > 0 {
            totalScore += compatibility.moonSignCompatibility.score * 0.25
            weightSum += 0.25
        }
        
        // Восходящий знак (вес 20%)
        if compatibility.risingSignCompatibility.score > 0 {
            totalScore += compatibility.risingSignCompatibility.score * 0.2
            weightSum += 0.2
        }
        
        // Стихии (вес 15%)
        totalScore += compatibility.elementCompatibility.score * 0.15
        weightSum += 0.15
        
        // Качества (вес 10%)
        totalScore += compatibility.qualityCompatibility.score * 0.1
        weightSum += 0.1
        
        return weightSum > 0 ? totalScore / weightSum : 0.0
    }
    
    private func generateRecommendations(compatibility: Compatibility) -> [String] {
        var recommendations: [String] = []
        
        // Рекомендации на основе общего балла
        if compatibility.overallScore >= 80 {
            recommendations.append("Отличная совместимость! У вас есть все шансы на гармоничные отношения.")
        } else if compatibility.overallScore >= 60 {
            recommendations.append("Хорошая совместимость. Работайте над пониманием различий.")
        } else if compatibility.overallScore >= 40 {
            recommendations.append("Средняя совместимость. Потребуется больше усилий для гармонии.")
        } else {
            recommendations.append("Низкая совместимость. Рассмотрите возможность дружбы вместо романтических отношений.")
        }
        
        // Рекомендации на основе стихий
        if compatibility.elementCompatibility.score < 50 {
            recommendations.append("Стихии могут конфликтовать. Учитесь понимать разные подходы к жизни.")
        }
        
        // Рекомендации на основе качеств
        if compatibility.qualityCompatibility.score < 50 {
            recommendations.append("Разные качества знаков могут создавать напряжение. Ищите компромиссы.")
        }
        
        return recommendations
    }
    
    private func isBasicCompatibility(user: User, candidate: User) -> Bool {
        // Базовые фильтры совместимости
        guard candidate.age >= 18 else { return false }
        
        // Фильтр по полу (если указан)
        switch user.lookingFor {
        case .men:
            // В реальном приложении здесь будет проверка пола
            break
        case .women:
            // В реальном приложении здесь будет проверка пола
            break
        case .both:
            break
        }
        
        // Фильтр по возрасту (разница не более 15 лет)
        let ageDifference = abs(user.age - candidate.age)
        guard ageDifference <= 15 else { return false }
        
        return true
    }
}

// MARK: - Supporting Types

struct NatalChart {
    let sunSign: ZodiacSign
    let moonSign: ZodiacSign
    let risingSign: ZodiacSign
    let planets: [PlanetPosition]
    let houses: [HousePosition]
    let aspects: [Aspect]
}

struct PlanetPosition {
    let planet: Aspect.Planet
    let sign: ZodiacSign
    let degree: Double
    let house: Int
}

struct HousePosition {
    let houseNumber: Int
    let sign: ZodiacSign
    let degree: Double
}

struct CompatiblePartner {
    let user: User
    let compatibility: Compatibility
    let matchScore: Double
}