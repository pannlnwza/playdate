import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let session: ChatSession
    private let chatService: ChatServiceProtocol
    private let userId: String
    
    init(session: ChatSession, chatService: ChatServiceProtocol, userId: String) {
        self.session = session
        self.chatService = chatService
        self.userId = userId
    }
    
    func fetchMessages() async {
        isLoading = true
        errorMessage = nil
        do {
            messages = try await chatService.fetchMessages(for: session.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func sendText(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            senderId: userId,
            content: text,
            type: .text
        )
        
        await sendMessage(newMessage)
    }
    
    func sendSticker(url: String) async {
        let newMessage = ChatMessage(
            senderId: userId,
            content: url,
            type: .sticker
        )
        
        await sendMessage(newMessage)
    }
    
    func sendVoiceNote(url: String) async {
        let newMessage = ChatMessage(
            senderId: userId,
            content: url,
            type: .voiceNote
        )
        
        await sendMessage(newMessage)
    }
    
    private func sendMessage(_ message: ChatMessage) async {
        // Optimistic update
        messages.append(message)
        
        do {
            try await chatService.sendMessage(message, in: session.id)
        } catch {
            errorMessage = error.localizedDescription
            // In a real app, you might mark the message as failed to send
        }
    }
}
