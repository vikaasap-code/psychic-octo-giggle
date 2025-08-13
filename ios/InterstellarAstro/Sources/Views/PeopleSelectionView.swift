import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let city: String
    let compatibilityScore: Int // 0...100
}

struct PeopleSelectionView: View {
    let people: [Person]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                ForEach(people) { person in
                    PersonCard(person: person)
                }
                disclaimer
            }
            .padding(16)
        }
        .background(LinearGradient(colors: [Color.black, Color(red: 0.04, green: 0.05, blue: 0.12)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Выбор человека")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.cyan, .purple, .pink], startPoint: .leading, endPoint: .trailing))
            Text("Совместимость — от «лучше даже не пробовать» до «возможно, это ваша судьба».")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var disclaimer: some View {
        Text("18+. Расчёт носит развлекательный характер и не заменяет консультаций специалистов.")
            .font(.footnote)
            .foregroundColor(.white.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

struct PersonCard: View {
    let person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(person.name), \(person.age)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Text(person.city)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                CompatibilityBadge(score: person.compatibilityScore)
            }

            Text(CompatibilityCopy.description(for: person.compatibilityScore))
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))

            HStack(spacing: 10) {
                Button {
                    // открыть детальную синастрию
                } label: {
                    Text("Открыть совместимость")
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    // начать чат/лайк
                } label: {
                    Text("Связаться")
                        .font(.system(size: 15, weight: .medium))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.18), lineWidth: 1)
                        )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
        )
    }
}

struct CompatibilityBadge: View {
    let score: Int

    var body: some View {
        let level = CompatibilityLevel.from(score: score)
        HStack(spacing: 8) {
            ZStack {
                RingGauge(progress: Double(score) / 100.0, gradient: level.gradient)
                    .frame(width: 42, height: 42)
                Text(level.emoji)
                    .font(.system(size: 14))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(level.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(score)%")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct RingGauge: View {
    let progress: Double // 0...1
    let gradient: LinearGradient

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.08), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

enum CompatibilityLevel {
    case veryLow, low, neutral, promising, fate

    var title: String {
        switch self {
        case .veryLow: return "Лучше даже не пробовать"
        case .low:     return "Сомнительно"
        case .neutral: return "Нейтрально"
        case .promising: return "Многообещающе"
        case .fate:    return "Возможно, это ваша судьба"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .veryLow:
            return LinearGradient(colors: [.red.opacity(0.9), .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .low:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .neutral:
            return LinearGradient(colors: [.gray, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .promising:
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .fate:
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var emoji: String {
        switch self {
        case .veryLow: return "🪨"
        case .low: return "⚠️"
        case .neutral: return "🌗"
        case .promising: return "✨"
        case .fate: return "💫"
        }
    }

    static func from(score: Int) -> CompatibilityLevel {
        switch score {
        case ..<20: return .veryLow
        case 20..<40: return .low
        case 40..<60: return .neutral
        case 60..<80: return .promising
        default: return .fate
        }
    }
}

enum CompatibilityCopy {
    static func description(for score: Int) -> String {
        switch CompatibilityLevel.from(score: score) {
        case .veryLow:
            return "Много острых углов и разная динамика. Если решите попробовать — крайне бережно."
        case .low:
            return "Притяжение слабое. Шансы есть, но потребуются усилия и терпение."
        case .neutral:
            return "Баланс возможен. Всё решит общение и уважение границ."
        case .promising:
            return "Чувствуется химия и схожие ценности. Перспективно."
        case .fate:
            return "Сильный резонанс. Возможно, судьбоносная встреча."
        }
    }
}