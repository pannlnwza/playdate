import Foundation
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let chatService: ChatServiceProtocol
    private let userId: String
    
    init(chatService: ChatServiceProtocol, userId: String) {
        self.chatService = chatService
        self.userId = userId
    }
    
    func fetchSessions() async {
        isLoading = true
        errorMessage = nil
        do {
            sessions = try await chatService.fetchSessions(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func deleteSession(sessionId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await chatService.deleteSession(sessionId)
            sessions.removeAll(where: { $0.id == sessionId })
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
