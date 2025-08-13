import SwiftUI

struct ChatsView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack {
                if userManager.conversations.isEmpty {
                    EmptyChatsView()
                } else {
                    List {
                        ForEach(userManager.conversations) { conversation in
                            NavigationLink(destination: ChatDetailView(conversation: conversation)) {
                                ChatRowView(conversation: conversation)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Чаты")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ChatRowView: View {
    let conversation: Conversation
    @EnvironmentObject var userManager: UserManager
    
    var otherUser: UserProfile? {
        return conversation.otherParticipant(currentUserId: userManager.currentUser?.id ?? UUID())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Аватар
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text("👤")
                    .font(.system(size: 25))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUser?.name ?? "Unknown")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(timeString(from: lastMessage.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let lastMessage = conversation.lastMessage {
                    HStack {
                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if !lastMessage.isRead && lastMessage.senderId != userManager.currentUser?.id {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                } else {
                    Text("Начните разговор...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isToday(date) {
            formatter.timeStyle = .short
        } else if calendar.isYesterday(date) {
            return "Вчера"
        } else {
            formatter.dateStyle = .short
        }
        
        return formatter.string(from: date)
    }
}

struct ChatDetailView: View {
    let conversation: Conversation
    @EnvironmentObject var userManager: UserManager
    @State private var messageText = ""
    @State private var showingAstroInsight = false
    
    var otherUser: UserProfile? {
        return conversation.otherParticipant(currentUserId: userManager.currentUser?.id ?? UUID())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Сообщения
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(conversation.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isCurrentUser: message.senderId == userManager.currentUser?.id
                        )
                    }
                }
                .padding()
            }
            
            // Панель ввода
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    // Кнопка астро-совета
                    Button(action: { showingAstroInsight = true }) {
                        Image(systemName: "star.circle")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    
                    // Поле ввода
                    TextField("Сообщение...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Кнопка отправки
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? .gray : .purple)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle(otherUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .actionSheet(isPresented: $showingAstroInsight) {
            ActionSheet(
                title: Text("Астрологический совет"),
                message: Text("Выберите тип совета для улучшения общения"),
                buttons: [
                    .default(Text("Совет дня")) { sendAstroInsight(type: .daily) },
                    .default(Text("Совет по общению")) { sendAstroInsight(type: .communication) },
                    .default(Text("Совет по совместимости")) { sendAstroInsight(type: .compatibility) },
                    .cancel()
                ]
            )
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        userManager.sendMessage(messageText, to: conversation)
        messageText = ""
    }
    
    private func sendAstroInsight(type: AstroInsightType) {
        let insight = generateAstroInsight(type: type)
        userManager.sendMessage(insight, to: conversation, type: .astroInsight)
    }
    
    private func generateAstroInsight(type: AstroInsightType) -> String {
        guard let currentUser = userManager.currentUser,
              let otherUser = otherUser,
              let currentChart = currentUser.natalChart,
              let otherChart = otherUser.natalChart else {
            return "Астрологический анализ недоступен"
        }
        
        switch type {
        case .daily:
            return "✨ Сегодня звезды благоприятствуют открытому общению. Это хорошее время для искренних разговоров!"
        case .communication:
            let mercury1 = currentChart.position(of: .mercury)?.sign
            let mercury2 = otherChart.position(of: .mercury)?.sign
            if let m1 = mercury1, let m2 = mercury2 {
                return "💭 Ваш Меркурий в \(m1.rawValue), а у партнера в \(m2.rawValue). Попробуйте быть более \(m1.element == m2.element ? "прямолинейными" : "терпеливыми") в общении."
            }
            return "💭 Помните: понимание приходит через терпение и открытость."
        case .compatibility:
            let compatibility = CompatibilityAnalyzer.analyzeCompatibility(between: currentChart, and: otherChart)
            return "💫 Ваша совместимость \(Int(compatibility.overallScore * 100))%. Ваши сильные стороны: \(compatibility.strengths.first ?? "взаимопонимание")."
        }
    }
}

enum AstroInsightType {
    case daily
    case communication
    case compatibility
}

struct MessageBubbleView: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                HStack {
                    if message.type == .astroInsight {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(bubbleColor)
                        )
                }
                
                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
    
    private var bubbleColor: Color {
        switch message.type {
        case .astroInsight:
            return Color.purple.opacity(0.8)
        default:
            return isCurrentUser ? Color.purple : Color(.systemGray5)
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptyChatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("💬")
                .font(.system(size: 80))
            
            Text("Пока нет чатов")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Когда у вас появятся матчи, вы сможете начать общение здесь")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Звезды подскажут, о чем говорить! ⭐")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.top, 100)
    }
}