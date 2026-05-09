import Foundation

protocol ChatServiceProtocol {
    func fetchSessions(for userId: String) async throws -> [ChatSession]
    func fetchMessages(for sessionId: String) async throws -> [ChatMessage]
    func sendMessage(_ message: ChatMessage, in sessionId: String) async throws
    func deleteSession(_ sessionId: String) async throws
}
