import Foundation

class AstrologyCalculator {
    
    // MARK: - Main Chart Generation
    static func generateNatalChart(from birthData: BirthData) -> NatalChart {
        let planets = calculatePlanetPositions(for: birthData)
        let houses = calculateHouses(for: birthData)
        let aspects = calculateAspects(between: planets)
        
        return NatalChart(
            birthData: birthData,
            planets: planets,
            houses: houses,
            aspects: aspects
        )
    }
    
    // MARK: - Planet Position Calculations
    private static func calculatePlanetPositions(for birthData: BirthData) -> [PlanetPosition] {
        var positions: [PlanetPosition] = []
        
        // Упрощенный расчет позиций планет
        // В реальном приложении здесь должны быть точные астрономические расчеты
        let dayOfYear = Calendar.current.ordinally(of: .day, in: .year, for: birthData.date) ?? 1
        let yearProgress = Double(dayOfYear) / 365.25
        
        for planet in Planet.allCases {
            let basePosition = getBasePlanetPosition(planet: planet, yearProgress: yearProgress)
            let sign = calculateSign(from: basePosition)
            let house = calculateHouse(for: basePosition, birthData: birthData)
            let degree = basePosition.truncatingRemainder(dividingBy: 30.0)
            
            positions.append(PlanetPosition(
                planet: planet,
                sign: sign,
                house: house,
                degree: degree,
                retrograde: isRetrograde(planet: planet, date: birthData.date)
            ))
        }
        
        return positions
    }
    
    private static func getBasePlanetPosition(planet: Planet, yearProgress: Double) -> Double {
        // Упрощенные базовые позиции планет (в градусах от 0 до 360)
        let basePositions: [Planet: Double] = [
            .sun: yearProgress * 360.0,
            .moon: yearProgress * 360.0 * 13.0, // Луна делает ~13 оборотов в год
            .mercury: yearProgress * 360.0 * 4.0,
            .venus: yearProgress * 360.0 * 1.6,
            .mars: yearProgress * 360.0 * 0.5,
            .jupiter: yearProgress * 360.0 * 0.08,
            .saturn: yearProgress * 360.0 * 0.03,
            .uranus: yearProgress * 360.0 * 0.01,
            .neptune: yearProgress * 360.0 * 0.006,
            .pluto: yearProgress * 360.0 * 0.004,
            .northNode: 360.0 - yearProgress * 360.0 * 0.05,
            .southNode: 180.0 - yearProgress * 360.0 * 0.05
        ]
        
        return (basePositions[planet] ?? 0.0).truncatingRemainder(dividingBy: 360.0)
    }
    
    private static func calculateSign(from degrees: Double) -> ZodiacSign {
        let signIndex = Int(degrees / 30.0) % 12
        return ZodiacSign.allCases[signIndex]
    }
    
    private static func calculateHouse(for degrees: Double, birthData: BirthData) -> House {
        // Упрощенный расчет домов на основе времени рождения
        let timeOfDay = Calendar.current.component(.hour, from: birthData.date)
        let houseOffset = Int((degrees + Double(timeOfDay) * 15.0) / 30.0) % 12
        return House.allCases[houseOffset]
    }
    
    private static func isRetrograde(planet: Planet, date: Date) -> Bool {
        // Упрощенная логика ретроградности
        let dayOfYear = Calendar.current.ordinally(of: .day, in: .year, for: date) ?? 1
        
        switch planet {
        case .mercury:
            return (dayOfYear % 88) > 70
        case .venus:
            return (dayOfYear % 225) > 200
        case .mars:
            return (dayOfYear % 687) > 650
        case .jupiter:
            return (dayOfYear % 4333) > 4200
        case .saturn:
            return (dayOfYear % 10759) > 10500
        case .uranus, .neptune, .pluto:
            return (dayOfYear % 365) > 300
        default:
            return false
        }
    }
    
    // MARK: - House Calculations
    private static func calculateHouses(for birthData: BirthData) -> [House: ZodiacSign] {
        var houses: [House: ZodiacSign] = [:]
        
        // Упрощенный расчет домов
        let timeOfDay = Calendar.current.component(.hour, from: birthData.date)
        let ascendantDegrees = (Double(timeOfDay) * 15.0 + birthData.latitude).truncatingRemainder(dividingBy: 360.0)
        
        for house in House.allCases {
            let houseDegrees = (ascendantDegrees + Double(house.rawValue - 1) * 30.0).truncatingRemainder(dividingBy: 360.0)
            houses[house] = calculateSign(from: houseDegrees)
        }
        
        return houses
    }
    
    // MARK: - Aspect Calculations
    private static func calculateAspects(between planets: [PlanetPosition]) -> [Aspect] {
        var aspects: [Aspect] = []
        
        for i in 0..<planets.count {
            for j in (i+1)..<planets.count {
                let planet1 = planets[i]
                let planet2 = planets[j]
                
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
}