import SwiftUI

struct MatchesView: View {
    @EnvironmentObject var viewModel: AstroMatchViewModel
    @State private var selectedFilter: MatchFilter = .all
    
    var body: some View {
        NavigationView {
            VStack {
                // Фильтры
                filterSection
                
                if viewModel.compatibilityResults.isEmpty {
                    emptyMatchesView
                } else {
                    // Список совпадений
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredMatches) { match in
                                MatchRowView(match: match)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Совпадения")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Обновить") {
                        viewModel.findPotentialMatches()
                    }
                }
            }
        }
        .onAppear {
            if viewModel.compatibilityResults.isEmpty {
                viewModel.findPotentialMatches()
            }
        }
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MatchFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        isSelected: selectedFilter == filter,
                        action: {
                            selectedFilter = filter
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Filtered Matches
    
    private var filteredMatches: [CompatibilityResult] {
        switch selectedFilter {
        case .all:
            return viewModel.compatibilityResults
        case .highCompatibility:
            return viewModel.compatibilityResults.filter { $0.overallScore >= 80 }
        case .mediumCompatibility:
            return viewModel.compatibilityResults.filter { $0.overallScore >= 60 && $0.overallScore < 80 }
        case .lowCompatibility:
            return viewModel.compatibilityResults.filter { $0.overallScore < 60 }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyMatchesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Пока нет совпадений")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Начните поиск, чтобы найти свою звездную пару")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Найти совпадения") {
                viewModel.findPotentialMatches()
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .padding()
    }
}

// MARK: - Match Row View

struct MatchRowView: View {
    let match: CompatibilityResult
    @State private var showCompatibility = false
    
    var body: some View {
        Button(action: {
            showCompatibility = true
        }) {
            HStack(spacing: 16) {
                // Аватар пользователя
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    
                    Text(match.user2.natalChart.sunSign.emoji)
                        .font(.system(size: 30))
                }
                
                // Информация о пользователе
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(match.user2.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("\(match.user2.age)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(match.user2.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(match.user2.natalChart.sunSign.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Балл совместимости
                VStack(spacing: 4) {
                    Text("\(match.overallScore)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(compatibilityColor)
                    
                    Text(compatibilityStatus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Стрелка
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showCompatibility) {
            CompatibilityDetailView(compatibility: match)
        }
    }
    
    private var compatibilityColor: Color {
        if match.overallScore >= 80 { return .green }
        if match.overallScore >= 60 { return .orange }
        return .red
    }
    
    private var compatibilityStatus: String {
        if match.overallScore >= 80 { return "Отлично" }
        if match.overallScore >= 60 { return "Хорошо" }
        return "Умеренно"
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.purple : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Match Filter

enum MatchFilter: CaseIterable {
    case all
    case highCompatibility
    case mediumCompatibility
    case lowCompatibility
    
    var title: String {
        switch self {
        case .all: return "Все"
        case .highCompatibility: return "Высокая"
        case .mediumCompatibility: return "Средняя"
        case .lowCompatibility: return "Низкая"
        }
    }
}

#Preview {
    MatchesView()
        .environmentObject(AstroMatchViewModel())
}