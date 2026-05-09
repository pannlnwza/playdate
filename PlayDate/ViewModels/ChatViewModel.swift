import Foundation
import Observation

@Observable
final class ChatViewModel {
    var conversations: [Conversation]

    init(conversations: [Conversation] = Conversation.mockConversations) {
        self.conversations = conversations
    }

    var recentMatches: [Conversation] {
        Array(conversations.prefix(4))
    }
}
