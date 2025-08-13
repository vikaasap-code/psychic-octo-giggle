import SwiftUI

struct MatchView: View {
    @EnvironmentObject var viewModel: AstroMatchViewModel
    @State private var currentIndex = 0
    @State private var offset: CGFloat = 0
    @State private var showCompatibility = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.potentialMatches.isEmpty {
                    EmptyStateView()
                } else {
                    ZStack {
                        ForEach(Array(viewModel.potentialMatches.enumerated()), id: \.element.id) { index, user in
                            if index >= currentIndex && index < currentIndex + 2 {
                                UserCardView(user: user) { action in
                                    handleCardAction(action, for: user)
                                }
                                .offset(x: index == currentIndex ? offset : 0)
                                .rotationEffect(.degrees(Double(offset) * 0.1))
                                .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                                .zIndex(index == currentIndex ? 1 : 0)
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation.x
                            }
                            .onEnded { value in
                                handleSwipe(value)
                            }
                    )
                    
                    // Кнопки действий
                    HStack(spacing: 40) {
                        Button(action: {
                            withAnimation(.spring()) {
                                dislikeCurrentUser()
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            showCompatibility = true
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                likeCurrentUser()
                            }
                        }) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.top, 30)
                }
                
                Spacer()
            }
            .navigationTitle("AstroMatch")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Найти") {
                        viewModel.findPotentialMatches()
                    }
                }
            }
        }
        .sheet(isPresented: $showCompatibility) {
            if let currentUser = viewModel.currentUser,
               let matchUser = viewModel.potentialMatches[safe: currentIndex],
               let compatibility = viewModel.getCompatibilityResult(for: matchUser) {
                CompatibilityDetailView(compatibility: compatibility)
            }
        }
        .onAppear {
            if viewModel.potentialMatches.isEmpty {
                viewModel.findPotentialMatches()
            }
        }
    }
    
    private func handleCardAction(_ action: CardAction, for user: UserProfile) {
        switch action {
        case .like:
            likeUser(user)
        case .dislike:
            dislikeUser(user)
        }
    }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        let threshold: CGFloat = 100
        
        if abs(value.translation.x) > threshold {
            if value.translation.x > 0 {
                likeCurrentUser()
            } else {
                dislikeCurrentUser()
            }
        } else {
            withAnimation(.spring()) {
                offset = 0
            }
        }
    }
    
    private func likeCurrentUser() {
        guard currentIndex < viewModel.potentialMatches.count else { return }
        let user = viewModel.potentialMatches[currentIndex]
        viewModel.likeUser(user)
        moveToNextUser()
    }
    
    private func dislikeCurrentUser() {
        guard currentIndex < viewModel.potentialMatches.count else { return }
        let user = viewModel.potentialMatches[currentIndex]
        viewModel.dislikeUser(user)
        moveToNextUser()
    }
    
    private func likeUser(_ user: UserProfile) {
        viewModel.likeUser(user)
        moveToNextUser()
    }
    
    private func dislikeUser(_ user: UserProfile) {
        viewModel.dislikeUser(user)
        moveToNextUser()
    }
    
    private func moveToNextUser() {
        withAnimation(.spring()) {
            currentIndex += 1
            offset = 0
            
            if currentIndex >= viewModel.potentialMatches.count {
                currentIndex = 0
            }
        }
    }
}

// MARK: - User Card View

struct UserCardView: View {
    let user: UserProfile
    let onAction: (CardAction) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Фото пользователя (заглушка)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 400)
                
                VStack {
                    Text(user.natalChart.sunSign.emoji)
                        .font(.system(size: 80))
                    
                    Text(user.natalChart.sunSign.rawValue)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            // Информация о пользователе
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(user.age)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(user.compatibilityScore)%")
                        .font(.headline)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(20)
                }
                
                Text(user.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(user.bio)
                    .font(.body)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Интересы
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(user.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(15)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Ищем ваши звездные совпадения...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.stars")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Пока нет совпадений")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Нажмите 'Найти' чтобы начать поиск")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Supporting Types

enum CardAction {
    case like
    case dislike
}

// MARK: - Extensions

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    MatchView()
        .environmentObject(AstroMatchViewModel())
}