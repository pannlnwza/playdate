import Foundation
import Observation

@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var isLoading: Bool = true
    var errorMessage: String?

    private var chatService: ChatServiceProtocol?
    private var chatId: String?
    private var userId: String?
    private var stop: (() -> Void)?

    deinit {
        stop?()
    }

    func attach(service: ChatServiceProtocol, chatId: String, userId: String) {
        stop?()
        self.chatService = service
        self.chatId = chatId
        self.userId = userId
        stop = service.observeMessages(in: chatId) { [weak self] messages in
            self?.messages = messages
            self?.isLoading = false
        }
        Task { try? await service.markSessionRead(chatId: chatId) }
    }

    func detach() {
        stop?()
        stop = nil
    }

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let chatService, let chatId, let userId else { return }

        let message = ChatMessage(senderId: userId, content: trimmed, timestamp: Date(), type: .text)
        messages.append(message)

        Task {
            do {
                try await chatService.sendMessage(message, in: chatId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
