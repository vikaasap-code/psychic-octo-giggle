import SwiftUI

struct CompatibilityDetailView: View {
    let compatibility: CompatibilityResult
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок с общим рейтингом
                    HeaderSection(compatibility: compatibility)
                    
                    // Основные показатели совместимости
                    CompatibilityScoresSection(compatibility: compatibility)
                    
                    // Сильные стороны
                    StrengthsSection(strengths: compatibility.strengths)
                    
                    // Вызовы
                    ChallengesSection(challenges: compatibility.challenges)
                    
                    // Важные аспекты
                    AspectsSection(aspects: compatibility.strongAspects)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Анализ совместимости")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Закрыть") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct HeaderSection: View {
    let compatibility: CompatibilityResult
    
    var body: some View {
        VStack(spacing: 16) {
            // Аватары пользователей
            HStack(spacing: 20) {
                UserAvatarView(name: compatibility.chart1.birthData.latitude > 0 ? "User 1" : "User 1")
                
                VStack {
                    Text(compatibility.compatibilityLevel.emoji)
                        .font(.system(size: 50))
                    Text("\(Int(compatibility.overallScore * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(compatibility.compatibilityLevel.color))
                }
                
                UserAvatarView(name: compatibility.chart2.birthData.latitude > 0 ? "User 2" : "User 2")
            }
            
            Text(compatibility.compatibilityLevel.rawValue + " совместимость")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(compatibility.compatibilityLevel.color))
            
            Text("Анализ основан на сравнении ваших натальных карт")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(compatibility.compatibilityLevel.color).opacity(0.1))
        )
    }
}

struct UserAvatarView: View {
    let name: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
            
            Text("👤")
                .font(.system(size: 40))
        }
    }
}

struct CompatibilityScoresSection: View {
    let compatibility: CompatibilityResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Детальный анализ")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                CompatibilityScoreRow(
                    title: "Элементы",
                    description: "Баланс стихий",
                    score: compatibility.elementCompatibility,
                    icon: "🌟"
                )
                
                CompatibilityScoreRow(
                    title: "Солнце-Луна",
                    description: "Эмоциональная связь",
                    score: compatibility.sunMoonCompatibility,
                    icon: "☀️"
                )
                
                CompatibilityScoreRow(
                    title: "Венера",
                    description: "Любовь и привязанность",
                    score: compatibility.venusCompatibility,
                    icon: "💝"
                )
                
                CompatibilityScoreRow(
                    title: "Марс",
                    description: "Страсть и энергия",
                    score: compatibility.marsCompatibility,
                    icon: "🔥"
                )
                
                CompatibilityScoreRow(
                    title: "Коммуникация",
                    description: "Понимание и общение",
                    score: compatibility.communicationCompatibility,
                    icon: "💭"
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

struct CompatibilityScoreRow: View {
    let title: String
    let description: String
    let score: Double
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(score * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor(for: score))
                
                // Прогресс бар
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                        .frame(width: 60, height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(scoreColor(for: score))
                        .frame(width: 60 * score, height: 8)
                }
            }
        }
    }
    
    private func scoreColor(for score: Double) -> Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .orange
        default: return .red
        }
    }
}

struct StrengthsSection: View {
    let strengths: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сильные стороны")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(strengths, id: \.self) { strength in
                HStack(alignment: .top, spacing: 12) {
                    Text("✅")
                        .font(.title3)
                    Text(strength)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
}

struct ChallengesSection: View {
    let challenges: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Области для развития")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(challenges, id: \.self) { challenge in
                HStack(alignment: .top, spacing: 12) {
                    Text("⚠️")
                        .font(.title3)
                    Text(challenge)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
}

struct AspectsSection: View {
    let aspects: [Aspect]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ключевые аспекты")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(aspects.prefix(5), id: \.planet1) { aspect in
                AspectRowView(aspect: aspect)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct AspectRowView: View {
    let aspect: Aspect
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(aspect.planet1.emoji)
                    Text(aspectSymbol)
                        .font(.title3)
                        .foregroundColor(aspect.type.harmonious ? .green : .orange)
                    Text(aspect.planet2.emoji)
                }
                
                Text("\(aspect.planet1.rawValue) \(aspect.type.rawValue) \(aspect.planet2.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Сила: \(Int(aspect.strength * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                Text("Орб: \(String(format: "%.1f", aspect.orb))°")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
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
}