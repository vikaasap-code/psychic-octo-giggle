import SwiftUI

struct NatalChartView: View {
    let chart: NatalChart
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Круговая диаграмма натальной карты
                    ChartWheelView(chart: chart)
                        .frame(height: 350)
                    
                    // Список планет с позициями
                    PlanetListView(chart: chart)
                    
                    // Список аспектов
                    AspectListView(chart: chart)
                    
                    // Анализ домов
                    HouseAnalysisView(chart: chart)
                }
                .padding()
            }
            .navigationTitle("Натальная карта")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Закрыть") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ChartWheelView: View {
    let chart: NatalChart
    
    var body: some View {
        ZStack {
            // Основной круг
            Circle()
                .stroke(Color.gray, lineWidth: 2)
            
            // Внутренний круг для домов
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .scaleEffect(0.8)
            
            // Центральный круг
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .scaleEffect(0.3)
            
            // Линии домов
            ForEach(0..<12, id: \.self) { house in
                Path { path in
                    let angle = Double(house) * 30.0 - 90.0 // -90 для начала с Асцендента
                    let radians = angle * .pi / 180
                    let center = CGPoint(x: 0, y: 0)
                    let outerRadius: CGFloat = 150
                    let innerRadius: CGFloat = 45
                    
                    path.move(to: CGPoint(
                        x: center.x + cos(radians) * innerRadius,
                        y: center.y + sin(radians) * innerRadius
                    ))
                    path.addLine(to: CGPoint(
                        x: center.x + cos(radians) * outerRadius,
                        y: center.y + sin(radians) * outerRadius
                    ))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
            
            // Знаки зодиака
            ForEach(ZodiacSign.allCases.indices, id: \.self) { index in
                let sign = ZodiacSign.allCases[index]
                let angle = Double(index) * 30.0 + 15.0 - 90.0 // Центр знака
                let radians = angle * .pi / 180
                let radius: CGFloat = 130
                
                Text(sign.emoji)
                    .font(.title2)
                    .position(
                        x: 175 + cos(radians) * radius,
                        y: 175 + sin(radians) * radius
                    )
            }
            
            // Планеты
            ForEach(chart.planets, id: \.planet) { planetPosition in
                let signIndex = ZodiacSign.allCases.firstIndex(of: planetPosition.sign) ?? 0
                let angle = Double(signIndex) * 30.0 + planetPosition.degree - 90.0
                let radians = angle * .pi / 180
                let radius: CGFloat = 105
                
                VStack(spacing: 2) {
                    Text(planetPosition.planet.emoji)
                        .font(.title3)
                    
                    if planetPosition.retrograde {
                        Text("R")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                .position(
                    x: 175 + cos(radians) * radius,
                    y: 175 + sin(radians) * radius
                )
            }
            
            // Номера домов
            ForEach(1...12, id: \.self) { houseNumber in
                let angle = Double(houseNumber - 1) * 30.0 + 15.0 - 90.0
                let radians = angle * .pi / 180
                let radius: CGFloat = 75
                
                Text("\(houseNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .position(
                        x: 175 + cos(radians) * radius,
                        y: 175 + sin(radians) * radius
                    )
            }
            
            // Асцендент (AC)
            Text("AC")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .position(x: 325, y: 175)
            
            // Центральная информация
            VStack {
                Text("🌟")
                    .font(.title)
                Text("Натальная карта")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 350, height: 350)
    }
}

struct PlanetListView: View {
    let chart: NatalChart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Позиции планет")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(chart.planets, id: \.planet) { planetPosition in
                    PlanetPositionCard(planetPosition: planetPosition)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct PlanetPositionCard: View {
    let planetPosition: PlanetPosition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(planetPosition.planet.emoji)
                    .font(.title2)
                
                Text(planetPosition.planet.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if planetPosition.retrograde {
                    Text("R")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange.opacity(0.2))
                        )
                }
            }
            
            HStack {
                Text(planetPosition.sign.emoji)
                Text(planetPosition.sign.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(String(format: "%.1f", planetPosition.degree))° • \(planetPosition.house.name)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
}

struct AspectListView: View {
    let chart: NatalChart
    
    var strongAspects: [Aspect] {
        return chart.aspects.filter { $0.strength > 0.6 }.prefix(8).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Сильные аспекты")
                .font(.headline)
                .fontWeight(.bold)
            
            if strongAspects.isEmpty {
                Text("Нет значимых аспектов")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(spacing: 8) {
                    ForEach(strongAspects, id: \.planet1) { aspect in
                        AspectRowDetailView(aspect: aspect)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct AspectRowDetailView: View {
    let aspect: Aspect
    
    var body: some View {
        HStack {
            // Планеты и аспект
            HStack(spacing: 8) {
                Text(aspect.planet1.emoji)
                    .font(.title3)
                
                Text(aspectSymbol)
                    .font(.title3)
                    .foregroundColor(aspect.type.harmonious ? .green : .orange)
                
                Text(aspect.planet2.emoji)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(aspect.planet1.rawValue) \(aspect.type.rawValue) \(aspect.planet2.rawValue)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Орб: \(String(format: "%.1f", aspect.orb))° • Сила: \(Int(aspect.strength * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Индикатор силы
            Circle()
                .fill(strengthColor)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 4)
    }
    
    private var aspectSymbol: String {
        switch aspect.type {
        case .conjunction: return "☌"
        case .opposition: return "☍"
        case .trine: return "△"
        case .square: return "□"
        case .sextile: return "⚹"
        case .quincunx: return "⚻"
        }
    }
    
    private var strengthColor: Color {
        switch aspect.strength {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        default: return .gray
        }
    }
}

struct HouseAnalysisView: View {
    let chart: NatalChart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Анализ домов")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                HouseInfoRow(
                    house: .first,
                    sign: chart.houses[.first] ?? .aries,
                    description: "Личность, внешность, первое впечатление"
                )
                
                HouseInfoRow(
                    house: .seventh,
                    sign: chart.houses[.seventh] ?? .libra,
                    description: "Партнерство, брак, открытые враги"
                )
                
                HouseInfoRow(
                    house: .tenth,
                    sign: chart.houses[.tenth] ?? .capricorn,
                    description: "Карьера, репутация, призвание"
                )
                
                HouseInfoRow(
                    house: .fourth,
                    sign: chart.houses[.fourth] ?? .cancer,
                    description: "Семья, дом, корни, подсознание"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct HouseInfoRow: View {
    let house: House
    let sign: ZodiacSign
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(house.rawValue) дом")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(sign.emoji)
                    Text(sign.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
}