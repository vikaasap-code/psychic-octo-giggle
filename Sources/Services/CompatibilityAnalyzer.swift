import Foundation

class CompatibilityAnalyzer {
    
    // MARK: - Main Compatibility Analysis
    static func analyzeCompatibility(between chart1: NatalChart, and chart2: NatalChart) -> CompatibilityResult {
        
        let elementCompatibility = calculateElementCompatibility(chart1: chart1, chart2: chart2)
        let sunMoonCompatibility = calculateSunMoonCompatibility(chart1: chart1, chart2: chart2)
        let venusCompatibility = calculateVenusCompatibility(chart1: chart1, chart2: chart2)
        let marsCompatibility = calculateMarsCompatibility(chart1: chart1, chart2: chart2)
        let communicationCompatibility = calculateCommunicationCompatibility(chart1: chart1, chart2: chart2)
        let synastricalAspects = calculateSynastricalAspects(chart1: chart1, chart2: chart2)
        
        let overallScore = calculateOverallScore(
            elementCompatibility: elementCompatibility,
            sunMoonCompatibility: sunMoonCompatibility,
            venusCompatibility: venusCompatibility,
            marsCompatibility: marsCompatibility,
            communicationCompatibility: communicationCompatibility,
            aspects: synastricalAspects
        )
        
        let (strengths, challenges) = generateStrengthsAndChallenges(
            chart1: chart1,
            chart2: chart2,
            aspects: synastricalAspects
        )
        
        return CompatibilityResult(
            chart1: chart1,
            chart2: chart2,
            overallScore: overallScore,
            elementCompatibility: elementCompatibility,
            sunMoonCompatibility: sunMoonCompatibility,
            venusCompatibility: venusCompatibility,
            marsCompatibility: marsCompatibility,
            communicationCompatibility: communicationCompatibility,
            strongAspects: synastricalAspects.prefix(10).map { $0 },
            challenges: challenges,
            strengths: strengths
        )
    }
    
    // MARK: - Element Compatibility
    private static func calculateElementCompatibility(chart1: NatalChart, chart2: NatalChart) -> Double {
        let elements1 = getElementDistribution(chart: chart1)
        let elements2 = getElementDistribution(chart: chart2)
        
        var compatibility = 0.0
        
        for element in Element.allCases {
            let strength1 = elements1[element] ?? 0.0
            let strength2 = elements2[element] ?? 0.0
            
            switch element {
            case .fire:
                // Огонь хорошо с воздухом, умеренно с огнем
                compatibility += strength1 * (elements2[.air] ?? 0.0) * 0.9
                compatibility += strength1 * strength2 * 0.7
            case .earth:
                // Земля хорошо с водой, умеренно с землей
                compatibility += strength1 * (elements2[.water] ?? 0.0) * 0.9
                compatibility += strength1 * strength2 * 0.7
            case .air:
                // Воздух хорошо с огнем, умеренно с воздухом
                compatibility += strength1 * (elements2[.fire] ?? 0.0) * 0.9
                compatibility += strength1 * strength2 * 0.7
            case .water:
                // Вода хорошо с землей, умеренно с водой
                compatibility += strength1 * (elements2[.earth] ?? 0.0) * 0.9
                compatibility += strength1 * strength2 * 0.7
            }
        }
        
        return min(compatibility, 1.0)
    }
    
    private static func getElementDistribution(chart: NatalChart) -> [Element: Double] {
        var distribution: [Element: Double] = [:]
        
        for planet in chart.planets {
            let element = planet.sign.element
            let importance = planet.planet.importance
            distribution[element, default: 0.0] += importance
        }
        
        // Нормализация
        let total = distribution.values.reduce(0, +)
        if total > 0 {
            for element in Element.allCases {
                distribution[element] = (distribution[element] ?? 0.0) / total
            }
        }
        
        return distribution
    }
    
    // MARK: - Sun-Moon Compatibility
    private static func calculateSunMoonCompatibility(chart1: NatalChart, chart2: NatalChart) -> Double {
        guard let sun1 = chart1.position(of: .sun),
              let moon1 = chart1.position(of: .moon),
              let sun2 = chart2.position(of: .sun),
              let moon2 = chart2.position(of: .moon) else {
            return 0.5
        }
        
        var compatibility = 0.0
        
        // Солнце одного с Луной другого
        compatibility += calculateSignCompatibility(sign1: sun1.sign, sign2: moon2.sign) * 0.4
        compatibility += calculateSignCompatibility(sign1: sun2.sign, sign2: moon1.sign) * 0.4
        
        // Солнце с Солнцем
        compatibility += calculateSignCompatibility(sign1: sun1.sign, sign2: sun2.sign) * 0.1
        
        // Луна с Луной
        compatibility += calculateSignCompatibility(sign1: moon1.sign, sign2: moon2.sign) * 0.1
        
        return min(compatibility, 1.0)
    }
    
    // MARK: - Venus Compatibility
    private static func calculateVenusCompatibility(chart1: NatalChart, chart2: NatalChart) -> Double {
        guard let venus1 = chart1.position(of: .venus),
              let venus2 = chart2.position(of: .venus),
              let mars1 = chart1.position(of: .mars),
              let mars2 = chart2.position(of: .mars) else {
            return 0.5
        }
        
        var compatibility = 0.0
        
        // Венера одного с Венерой другого
        compatibility += calculateSignCompatibility(sign1: venus1.sign, sign2: venus2.sign) * 0.4
        
        // Венера одного с Марсом другого
        compatibility += calculateSignCompatibility(sign1: venus1.sign, sign2: mars2.sign) * 0.3
        compatibility += calculateSignCompatibility(sign1: venus2.sign, sign2: mars1.sign) * 0.3
        
        return min(compatibility, 1.0)
    }
    
    // MARK: - Mars Compatibility
    private static func calculateMarsCompatibility(chart1: NatalChart, chart2: NatalChart) -> Double {
        guard let mars1 = chart1.position(of: .mars),
              let mars2 = chart2.position(of: .mars) else {
            return 0.5
        }
        
        return calculateSignCompatibility(sign1: mars1.sign, sign2: mars2.sign)
    }
    
    // MARK: - Communication Compatibility
    private static func calculateCommunicationCompatibility(chart1: NatalChart, chart2: NatalChart) -> Double {
        guard let mercury1 = chart1.position(of: .mercury),
              let mercury2 = chart2.position(of: .mercury) else {
            return 0.5
        }
        
        var compatibility = calculateSignCompatibility(sign1: mercury1.sign, sign2: mercury2.sign)
        
        // Бонус за одинаковые элементы
        if mercury1.sign.element == mercury2.sign.element {
            compatibility += 0.2
        }
        
        return min(compatibility, 1.0)
    }
    
    // MARK: - Sign Compatibility
    private static func calculateSignCompatibility(sign1: ZodiacSign, sign2: ZodiacSign) -> Double {
        // Одинаковые знаки
        if sign1 == sign2 {
            return 0.8
        }
        
        // Одинаковые элементы
        if sign1.element == sign2.element {
            return 0.7
        }
        
        // Совместимые элементы
        let compatibleElements: [Element: [Element]] = [
            .fire: [.air],
            .earth: [.water],
            .air: [.fire],
            .water: [.earth]
        ]
        
        if compatibleElements[sign1.element]?.contains(sign2.element) == true {
            return 0.6
        }
        
        // Противоположные знаки (часто привлекают друг друга)
        let oppositeIndex = (ZodiacSign.allCases.firstIndex(of: sign1)! + 6) % 12
        if ZodiacSign.allCases[oppositeIndex] == sign2 {
            return 0.5
        }
        
        // Трин (120 градусов)
        let trinIndices = [
            (ZodiacSign.allCases.firstIndex(of: sign1)! + 4) % 12,
            (ZodiacSign.allCases.firstIndex(of: sign1)! + 8) % 12
        ]
        if trinIndices.contains(ZodiacSign.allCases.firstIndex(of: sign2)!) {
            return 0.8
        }
        
        // Секстиль (60 градусов)
        let sextileIndices = [
            (ZodiacSign.allCases.firstIndex(of: sign1)! + 2) % 12,
            (ZodiacSign.allCases.firstIndex(of: sign1)! + 10) % 12
        ]
        if sextileIndices.contains(ZodiacSign.allCases.firstIndex(of: sign2)!) {
            return 0.7
        }
        
        // Квадрат (90 градусов) - вызов
        let squareIndices = [
            (ZodiacSign.allCases.firstIndex(of: sign1)! + 3) % 12,
            (ZodiacSign.allCases.firstIndex(of: sign1)! + 9) % 12
        ]
        if squareIndices.contains(ZodiacSign.allCases.firstIndex(of: sign2)!) {
            return 0.3
        }
        
        return 0.4 // Нейтральные отношения
    }
    
    // MARK: - Synastry Aspects
    private static func calculateSynastricalAspects(chart1: NatalChart, chart2: NatalChart) -> [Aspect] {
        var aspects: [Aspect] = []
        
        for planet1 in chart1.planets {
            for planet2 in chart2.planets {
                let angle = calculateAngleBetween(planet1: planet1, planet2: planet2)
                
                for aspectType in AspectType.allCases {
                    let orb = abs(angle - aspectType.angle)
                    let alternativeOrb = abs(360.0 - angle - aspectType.angle)
                    let actualOrb = min(orb, alternativeOrb)
                    
                    if actualOrb <= aspectType.orb {
                        aspects.append(Aspect(
                            planet1: planet1.planet,
                            planet2: planet2.planet,
                            type: aspectType,
                            orb: actualOrb,
                            applying: actualOrb < aspectType.orb * 0.8
                        ))
                    }
                }
            }
        }
        
        return aspects.sorted { $0.strength > $1.strength }
    }
    
    private static func calculateAngleBetween(planet1: PlanetPosition, planet2: PlanetPosition) -> Double {
        let pos1 = Double(ZodiacSign.allCases.firstIndex(of: planet1.sign) ?? 0) * 30.0 + planet1.degree
        let pos2 = Double(ZodiacSign.allCases.firstIndex(of: planet2.sign) ?? 0) * 30.0 + planet2.degree
        
        let angle = abs(pos1 - pos2)
        return min(angle, 360.0 - angle)
    }
    
    // MARK: - Overall Score Calculation
    private static func calculateOverallScore(
        elementCompatibility: Double,
        sunMoonCompatibility: Double,
        venusCompatibility: Double,
        marsCompatibility: Double,
        communicationCompatibility: Double,
        aspects: [Aspect]
    ) -> Double {
        
        var score = 0.0
        
        // Весовые коэффициенты
        score += elementCompatibility * 0.2
        score += sunMoonCompatibility * 0.25
        score += venusCompatibility * 0.2
        score += marsCompatibility * 0.1
        score += communicationCompatibility * 0.1
        
        // Аспекты
        let aspectScore = calculateAspectScore(aspects: aspects)
        score += aspectScore * 0.15
        
        return min(max(score, 0.0), 1.0)
    }
    
    private static func calculateAspectScore(aspects: [Aspect]) -> Double {
        var score = 0.5 // Базовый балл
        
        for aspect in aspects.prefix(10) { // Берем только 10 сильнейших аспектов
            if aspect.type.harmonious {
                score += aspect.strength * 0.1
            } else {
                score -= aspect.strength * 0.05
            }
        }
        
        return min(max(score, 0.0), 1.0)
    }
    
    // MARK: - Strengths and Challenges
    private static func generateStrengthsAndChallenges(
        chart1: NatalChart,
        chart2: NatalChart,
        aspects: [Aspect]
    ) -> ([String], [String]) {
        
        var strengths: [String] = []
        var challenges: [String] = []
        
        // Анализ сильных аспектов
        for aspect in aspects.prefix(5) {
            if aspect.type.harmonious && aspect.strength > 0.7 {
                strengths.append(generateAspectDescription(aspect: aspect, positive: true))
            } else if !aspect.type.harmonious && aspect.strength > 0.6 {
                challenges.append(generateAspectDescription(aspect: aspect, positive: false))
            }
        }
        
        // Анализ элементов
        let elements1 = getElementDistribution(chart: chart1)
        let elements2 = getElementDistribution(chart: chart2)
        
        for element in Element.allCases {
            let strength1 = elements1[element] ?? 0.0
            let strength2 = elements2[element] ?? 0.0
            
            if strength1 > 0.3 && strength2 > 0.3 {
                strengths.append("Общий акцент на элементе \(element.rawValue) создает взаимопонимание")
            }
        }
        
        // Если нет достаточно информации, добавляем общие описания
        if strengths.isEmpty {
            strengths.append("Потенциал для гармоничных отношений")
        }
        
        if challenges.isEmpty {
            challenges.append("Необходимо работать над взаимопониманием")
        }
        
        return (strengths, challenges)
    }
    
    private static func generateAspectDescription(aspect: Aspect, positive: Bool) -> String {
        let planet1Name = aspect.planet1.rawValue
        let planet2Name = aspect.planet2.rawValue
        let aspectName = aspect.type.rawValue
        
        if positive {
            return "\(aspectName) между \(planet1Name) и \(planet2Name) создает гармонию"
        } else {
            return "\(aspectName) между \(planet1Name) и \(planet2Name) требует внимания"
        }
    }
}