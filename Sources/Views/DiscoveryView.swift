import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var currentIndex = 0
    @State private var showingCompatibilityDetail = false
    @State private var selectedCompatibility: CompatibilityResult?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон с градиентом
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Заголовок
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Открывайте")
                                .font(.title2)
                                .fontWeight(.light)
                            Text("совместимость")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Фильтры
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Карточки пользователей
                    ZStack {
                        ForEach(userManager.discoveredUsers.indices, id: \.self) { index in
                            if index >= currentIndex && index < currentIndex + 3 {
                                UserCardView(
                                    user: userManager.discoveredUsers[index],
                                    compatibility: getCompatibility(for: userManager.discoveredUsers[index]),
                                    onLike: {
                                        likeUser(userManager.discoveredUsers[index])
                                    },
                                    onPass: {
                                        passUser()
                                    },
                                    onShowCompatibility: { compatibility in
                                        selectedCompatibility = compatibility
                                        showingCompatibilityDetail = true
                                    }
                                )
                                .zIndex(Double(userManager.discoveredUsers.count - index))
                                .offset(
                                    x: index == currentIndex ? 0 : CGFloat(index - currentIndex) * 10,
                                    y: index == currentIndex ? 0 : CGFloat(index - currentIndex) * 10
                                )
                                .scaleEffect(index == currentIndex ? 1.0 : 0.95)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопки действий
                    HStack(spacing: 40) {
                        // Кнопка "Нет"
                        Button(action: passUser) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundColor(.red)
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        // Кнопка "Супер лайк"
                        Button(action: {
                            if currentIndex < userManager.discoveredUsers.count {
                                superLikeUser(userManager.discoveredUsers[currentIndex])
                            }
                        }) {
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 50, height: 50)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        // Кнопка "Да"
                        Button(action: {
                            if currentIndex < userManager.discoveredUsers.count {
                                likeUser(userManager.discoveredUsers[currentIndex])
                            }
                        }) {
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(.pink)
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCompatibilityDetail) {
            if let compatibility = selectedCompatibility {
                CompatibilityDetailView(compatibility: compatibility)
            }
        }
    }
    
    private func getCompatibility(for user: UserProfile) -> CompatibilityResult? {
        guard let currentUser = userManager.currentUser,
              let currentChart = currentUser.natalChart,
              let userChart = user.natalChart else { return nil }
        
        return CompatibilityAnalyzer.analyzeCompatibility(between: currentChart, and: userChart)
    }
    
    private func likeUser(_ user: UserProfile) {
        let match = userManager.likeUser(user)
        nextUser()
        
        if let match = match, match.isMatched {
            // Показать уведомление о матче
            showMatchNotification()
        }
    }
    
    private func superLikeUser(_ user: UserProfile) {
        // Супер лайк (особая логика)
        likeUser(user)
    }
    
    private func passUser() {
        nextUser()
    }
    
    private func nextUser() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex += 1
        }
    }
    
    private func showMatchNotification() {
        // Здесь можно добавить анимацию уведомления о матче
    }
}

struct UserCardView: View {
    let user: UserProfile
    let compatibility: CompatibilityResult?
    let onLike: () -> Void
    let onPass: () -> Void
    let onShowCompatibility: (CompatibilityResult) -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Основная карточка
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
            
            VStack(alignment: .leading, spacing: 0) {
                // Фото (заглушка)
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 400)
                    
                    VStack {
                        Spacer()
                        Text("📸")
                            .font(.system(size: 60))
                        Text("Фото пользователя")
                            .foregroundColor(.white)
                            .font(.headline)
                        Spacer()
                    }
                    
                    // Индикатор совместимости
                    if let compatibility = compatibility {
                        VStack {
                            HStack {
                                Spacer()
                                CompatibilityBadge(level: compatibility.compatibilityLevel, score: compatibility.overallScore)
                                    .onTapGesture {
                                        onShowCompatibility(compatibility)
                                    }
                            }
                            .padding()
                            Spacer()
                        }
                    }
                }
                .clipped()
                
                // Информация о пользователе
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(user.name), \(user.age)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if let sunSign = user.sunSign {
                            HStack(spacing: 4) {
                                Text(sunSign.emoji)
                                Text(sunSign.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text("\(user.location.city)")
                            .foregroundColor(.secondary)
                    }
                    
                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.body)
                            .lineLimit(3)
                            .padding(.top, 4)
                    }
                    
                    // Астрологическая информация
                    if let sunSign = user.sunSign, let moonSign = user.moonSign {
                        HStack {
                            AstroSignView(title: "Солнце", sign: sunSign)
                            Spacer()
                            AstroSignView(title: "Луна", sign: moonSign)
                            Spacer()
                            if let ascendant = user.ascendantSign {
                                AstroSignView(title: "Асц", sign: ascendant)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
        }
        .frame(height: 600)
        .offset(dragOffset)
        .rotationEffect(.degrees(rotation))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                    rotation = Double(value.translation.x / 10)
                }
                .onEnded { value in
                    let threshold: CGFloat = 100
                    
                    if value.translation.x > threshold {
                        // Свайп вправо - лайк
                        withAnimation {
                            dragOffset = CGSize(width: 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onLike()
                            resetCard()
                        }
                    } else if value.translation.x < -threshold {
                        // Свайп влево - пасс
                        withAnimation {
                            dragOffset = CGSize(width: -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onPass()
                            resetCard()
                        }
                    } else {
                        // Возвращаем карточку в исходное положение
                        withAnimation(.spring()) {
                            resetCard()
                        }
                    }
                }
        )
    }
    
    private func resetCard() {
        dragOffset = .zero
        rotation = 0
    }
}

struct CompatibilityBadge: View {
    let level: CompatibilityLevel
    let score: Double
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Int(score * 100))%")
                .font(.headline)
                .fontWeight(.bold)
            Text(level.rawValue)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(level.color), lineWidth: 2)
        )
    }
}

struct AstroSignView: View {
    let title: String
    let sign: ZodiacSign
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(sign.emoji)
                .font(.title3)
            Text(sign.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}