import SwiftUI

struct CompatibilityDetailView: View {
    let compatibility: CompatibilityResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок
                    headerSection
                    
                    // Общий балл совместимости
                    overallScoreSection
                    
                    // Детальные показатели
                    detailedScoresSection
                    
                    // Анализ совместимости
                    analysisSection
                    
                    // Рекомендации
                    recommendationsSection
                    
                    // Информация о пользователях
                    usersInfoSection
                }
                .padding()
            }
            .navigationTitle("Анализ совместимости")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Первый пользователь
                VStack {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Text(compatibility.user1.natalChart.sunSign.emoji)
                            .font(.system(size: 40))
                    }
                    
                    Text(compatibility.user1.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(compatibility.user1.natalChart.sunSign.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Сердце совместимости
                VStack {
                    Image(systemName: compatibility.isCompatible ? "heart.fill" : "heart")
                        .font(.system(size: 40))
                        .foregroundColor(compatibility.isCompatible ? .red : .gray)
                    
                    Text("\(compatibility.overallScore)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(compatibility.isCompatible ? .purple : .secondary)
                }
                
                // Второй пользователь
                VStack {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Text(compatibility.user2.natalChart.sunSign.emoji)
                            .font(.system(size: 40))
                    }
                    
                    Text(compatibility.user2.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(compatibility.user2.natalChart.sunSign.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Статус совместимости
            Text(compatibility.isCompatible ? "Отличная совместимость! 💫" : "Умеренная совместимость ⚖️")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(compatibility.isCompatible ? .green : .orange)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(compatibility.isCompatible ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                )
        }
    }
    
    // MARK: - Overall Score Section
    
    private var overallScoreSection: some View {
        VStack(spacing: 16) {
            Text("Общий балл совместимости")
                .font(.headline)
                .fontWeight(.semibold)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(compatibility.overallScore) / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: compatibility.overallScore)
                
                VStack {
                    Text("\(compatibility.overallScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    
                    Text("%")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Detailed Scores Section
    
    private var detailedScoresSection: some View {
        VStack(spacing: 16) {
            Text("Детальные показатели")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ScoreRow(
                    title: "☀️ Солнце",
                    score: compatibility.sunSignCompatibility,
                    icon: "sun.max.fill",
                    color: .orange
                )
                
                ScoreRow(
                    title: "🌙 Луна",
                    score: compatibility.moonSignCompatibility,
                    icon: "moon.fill",
                    color: .blue
                )
                
                ScoreRow(
                    title: "\(compatibility.user1.natalChart.sunSign.element.emoji) Стихии",
                    score: compatibility.elementCompatibility,
                    icon: "flame.fill",
                    color: .red
                )
                
                ScoreRow(
                    title: "⚡ Качества",
                    score: compatibility.qualityCompatibility,
                    icon: "bolt.fill",
                    color: .yellow
                )
            }
        }
    }
    
    // MARK: - Analysis Section
    
    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Астрологический анализ")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(compatibility.detailedAnalysis)
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.05))
                )
        }
    }
    
    // MARK: - Recommendations Section
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Рекомендации")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(compatibility.recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(recommendation)
                            .font(.body)
                            .lineSpacing(2)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.05))
            )
        }
    }
    
    // MARK: - Users Info Section
    
    private var usersInfoSection: some View {
        VStack(spacing: 16) {
            Text("Информация о пользователях")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                UserInfoCard(user: compatibility.user1)
                UserInfoCard(user: compatibility.user2)
            }
        }
    }
}

// MARK: - Score Row

struct ScoreRow: View {
    let title: String
    let score: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Text("\(score)%")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// MARK: - User Info Card

struct UserInfoCard: View {
    let user: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(user.natalChart.sunSign.emoji)
                    .font(.title2)
                
                Text(user.name)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("\(user.age) лет")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(user.location)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(user.natalChart.sunSign.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .foregroundColor(.purple)
                .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

#Preview {
    let mockCompatibility = CompatibilityResult(
        user1: UserProfile(
            name: "Анна",
            age: 28,
            gender: .female,
            photoURL: nil,
            bio: "Тестовый профиль",
            interests: ["Тест"],
            natalChart: NatalChart(
                birthDate: Date(),
                birthTime: Date(),
                birthPlace: "Москва",
                latitude: 55.7558,
                longitude: 37.6176
            ),
            lookingFor: .male,
            ageRange: 25...35,
            location: "Москва"
        ),
        user2: UserProfile(
            name: "Михаил",
            age: 30,
            gender: .male,
            photoURL: nil,
            bio: "Тестовый профиль",
            interests: ["Тест"],
            natalChart: NatalChart(
                birthDate: Date(),
                birthTime: Date(),
                birthPlace: "СПб",
                latitude: 59.9311,
                longitude: 30.3609
            ),
            lookingFor: .female,
            ageRange: 25...32,
            location: "СПб"
        ),
        overallScore: 85,
        sunSignCompatibility: 80,
        moonSignCompatibility: 75,
        elementCompatibility: 90,
        qualityCompatibility: 85,
        detailedAnalysis: "Отличная совместимость!",
        recommendations: ["Рекомендация 1", "Рекомендация 2"]
    )
    
    CompatibilityDetailView(compatibility: mockCompatibility)
}