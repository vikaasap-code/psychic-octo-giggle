import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var chats: [ChatPreview] = []
    @State private var isLoading = false
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поисковая строка
                searchBar
                
                // Список чатов
                if isLoading {
                    loadingView
                } else if chats.isEmpty {
                    emptyStateView
                } else {
                    chatsList
                }
            }
            .navigationTitle("Чаты")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadChats()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Поиск по имени...", text: $searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
        .onChange(of: searchQuery) { _ in
            filterChats()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(1.5)
            
            Text("Загружаем чаты...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("У вас пока нет чатов")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Начните общение с совместимыми партнерами в разделе 'Поиск'")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chatsList: some View {
        List(filteredChats) { chat in
            ChatRow(chat: chat) {
                // Открыть чат
                openChat(chat)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var filteredChats: [ChatPreview] {
        if searchQuery.isEmpty {
            return chats
        } else {
            return chats.filter { $0.partnerName.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    private func loadChats() {
        isLoading = true
        
        // Имитация загрузки чатов
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            chats = createMockChats()
            isLoading = false
        }
    }
    
    private func filterChats() {
        // Фильтрация уже загруженных чатов
    }
    
    private func openChat(_ chat: ChatPreview) {
        // В реальном приложении здесь будет открытие чата
        print("Открытие чата с \(chat.partnerName)")
    }
    
    private func createMockChats() -> [ChatPreview] {
        return [
            ChatPreview(
                id: "1",
                partnerId: "1",
                partnerName: "Анна",
                partnerAvatar: "А",
                lastMessage: "Привет! Как дела?",
                lastMessageTime: Date().addingTimeInterval(-3600),
                unreadCount: 2,
                isOnline: true
            ),
            ChatPreview(
                id: "2",
                partnerId: "2",
                partnerName: "Михаил",
                partnerAvatar: "М",
                lastMessage: "Спасибо за интересную беседу!",
                lastMessageTime: Date().addingTimeInterval(-7200),
                unreadCount: 0,
                isOnline: false
            ),
            ChatPreview(
                id: "3",
                partnerId: "3",
                partnerName: "Елена",
                partnerAvatar: "Е",
                lastMessage: "До встречи!",
                lastMessageTime: Date().addingTimeInterval(-86400),
                unreadCount: 1,
                isOnline: true
            )
        ]
    }
}

// MARK: - Supporting Views

struct ChatRow: View {
    let chat: ChatPreview
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Аватар партнера
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                    
                    Text(chat.partnerAvatar)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Индикатор онлайн
                    if chat.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
                
                // Информация о чате
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(chat.partnerName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(formatTime(chat.lastMessageTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(chat.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if chat.unreadCount > 0 {
                            Text("\(chat.unreadCount)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Circle()
                                        .fill(Color.purple)
                                )
                        }
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter.string(from: date)
        }
    }
}

// MARK: - Models

struct ChatPreview: Identifiable {
    let id: String
    let partnerId: String
    let partnerName: String
    let partnerAvatar: String
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
    let isOnline: Bool
}

#Preview {
    ChatListView()
        .environmentObject(UserManager())
}