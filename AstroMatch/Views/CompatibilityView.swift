import SwiftUI

struct CompatibilityView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var astrologyService: AstrologyService
    
    @State private var selectedUser: User?
    @State private var compatibility: Compatibility?
    @State private var isLoading = false
    @State private var showingUserPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let currentUser = userManager.currentUser {
                    // Заголовок
                    headerSection
                    
                    // Выбор пользователя для сравнения
                    userSelectionSection
                    
                    // Результаты анализа совместимости
                    if let compatibility = compatibility {
                        compatibilityResultsSection(compatibility)
                    } else {
                        emptyStateSection
                    }
                    
                    Spacer()
                } else {
                    notAuthenticatedSection
                }
            }
            .padding()
            .navigationTitle("Совместимость")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingUserPicker) {
                UserPickerView(selectedUser: $selectedUser, onUserSelected: { user in
                    selectedUser = user
                    showingUserPicker = false
                    calculateCompatibility(with: user)
                })
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("Анализ совместимости")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Сравните вашу натальную карту с картой другого человека для определения совместимости")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var userSelectionSection: some View {
        VStack(spacing: 15) {
            Text("Выберите человека для анализа")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let selectedUser = selectedUser {
                selectedUserCard(selectedUser)
            }
            
            Button(action: { showingUserPicker = true }) {
                HStack {
                    Image(systemName: selectedUser == nil ? "person.badge.plus" : "arrow.triangle.2.circlepath")
                    Text(selectedUser == nil ? "Выбрать человека" : "Изменить выбор")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(25)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
        )
    }
    
    private func selectedUserCard(_ user: User) -> some View {
        HStack(spacing: 15) {
            // Аватар
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Text(String(user.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(user.age) лет • \(user.zodiacSign.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { selectedUser = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Выберите человека для анализа совместимости")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Нажмите кнопку выше, чтобы начать анализ")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var notAuthenticatedSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Необходима авторизация")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Войдите в аккаунт, чтобы использовать функцию анализа совместимости")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func compatibilityResultsSection(_ compatibility: Compatibility) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Общий балл совместимости
                overallScoreSection(compatibility)
                
                // Детальный анализ
                detailedAnalysisSection(compatibility)
                
                // Рекомендации
                recommendationsSection(compatibility)
            }
        }
    }
    
    private func overallScoreSection(_ compatibility: Compatibility) -> some View {
        VStack(spacing: 15) {
            Text("Общая совместимость")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: compatibility.overallScore / 100)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: compatibility.overallScore)
                
                VStack(spacing: 5) {
                    Text("\(Int(compatibility.overallScore))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    
                    Text(getCompatibilityLevel(compatibility.overallScore))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func detailedAnalysisSection(_ compatibility: Compatibility) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Детальный анализ")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                CompatibilityDetailRow(
                    title: "Солнечный знак",
                    score: compatibility.sunSignCompatibility.score,
                    description: compatibility.sunSignCompatibility.description,
                    harmony: compatibility.sunSignCompatibility.harmony
                )
                
                if compatibility.moonSignCompatibility.score > 0 {
                    CompatibilityDetailRow(
                        title: "Лунный знак",
                        score: compatibility.moonSignCompatibility.score,
                        description: compatibility.moonSignCompatibility.description,
                        harmony: compatibility.moonSignCompatibility.harmony
                    )
                }
                
                if compatibility.risingSignCompatibility.score > 0 {
                    CompatibilityDetailRow(
                        title: "Восходящий знак",
                        score: compatibility.risingSignCompatibility.score,
                        description: compatibility.risingSignCompatibility.description,
                        harmony: compatibility.risingSignCompatibility.harmony
                    )
                }
                
                CompatibilityDetailRow(
                    title: "Стихии",
                    score: compatibility.elementCompatibility.score,
                    description: compatibility.elementCompatibility.description,
                    harmony: getHarmonyLevel(for: compatibility.elementCompatibility.score)
                )
                
                CompatibilityDetailRow(
                    title: "Качества",
                    score: compatibility.qualityCompatibility.score,
                    description: compatibility.qualityCompatibility.description,
                    harmony: getHarmonyLevel(for: compatibility.qualityCompatibility.score)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func recommendationsSection(_ compatibility: Compatibility) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Рекомендации")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !compatibility.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(compatibility.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Text(recommendation)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
            } else {
                Text("Рекомендации будут доступны после полного анализа")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func calculateCompatibility(with user: User) {
        guard let currentUser = userManager.currentUser else { return }
        
        isLoading = true
        
        Task {
            do {
                let compatibility = try await astrologyService.calculateCompatibility(user1: currentUser, user2: user)
                
                await MainActor.run {
                    self.compatibility = compatibility
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Ошибка расчета совместимости: \(error)")
            }
        }
    }
    
    private func getCompatibilityLevel(_ score: Double) -> String {
        switch score {
        case 80...100: return "Отличная"
        case 60..<80: return "Хорошая"
        case 40..<60: return "Средняя"
        case 20..<40: return "Низкая"
        default: return "Очень низкая"
        }
    }
    
    private func getHarmonyLevel(for score: Double) -> SignCompatibility.HarmonyLevel {
        switch score {
        case 80...100: return .excellent
        case 60..<80: return .good
        case 40..<60: return .neutral
        case 20..<40: return .challenging
        default: return .difficult
        }
    }
}

// MARK: - Supporting Views

struct CompatibilityDetailRow: View {
    let title: String
    let score: Double
    let description: String
    let harmony: SignCompatibility.HarmonyLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(score))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(harmony.rawValue)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(harmonyColor)
                    )
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
    
    private var harmonyColor: Color {
        switch harmony {
        case .excellent: return .green
        case .good: return .blue
        case .neutral: return .orange
        case .challenging: return .red
        case .difficult: return .purple
        }
    }
}

struct UserPickerView: View {
    @Binding var selectedUser: User?
    let onUserSelected: (User) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager
    
    @State private var searchQuery = ""
    @State private var users: [User] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Поисковая строка
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск по имени...", text: $searchQuery)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Список пользователей
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredUsers) { user in
                        UserRow(user: user) {
                            onUserSelected(user)
                        }
                    }
                }
            }
            .navigationTitle("Выбор пользователя")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadUsers()
            }
            .onChange(of: searchQuery) { _ in
                // Поиск будет выполняться локально
            }
        }
    }
    
    private var filteredUsers: [User] {
        if searchQuery.isEmpty {
            return users
        } else {
            return users.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    private func loadUsers() {
        isLoading = true
        
        Task {
            do {
                let allUsers = try await userManager.searchUsers(query: "", filters: UserFilters())
                
                await MainActor.run {
                    users = allUsers
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Ошибка загрузки пользователей: \(error)")
            }
        }
    }
}

struct UserRow: View {
    let user: User
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 15) {
                // Аватар
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Text(String(user.name.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(user.age) лет • \(user.zodiacSign.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CompatibilityView()
        .environmentObject(UserManager())
        .environmentObject(AstrologyService())
}