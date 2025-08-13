import SwiftUI

struct ChatView: View {
    let match: Match
    
    var body: some View {
        // Перенаправляем к существующему ChatDetailView
        ChatDetailView(conversation: createConversation())
    }
    
    private func createConversation() -> Conversation {
        return Conversation(participant1: match.user1, participant2: match.user2)
    }
}