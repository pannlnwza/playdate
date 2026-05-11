import Foundation

protocol ChatServiceProtocol {
    func observeSessions(for userId: String, onUpdate: @escaping ([ChatSession]) -> Void) -> () -> Void
    func observeMessages(in chatId: String, onUpdate: @escaping ([ChatMessage]) -> Void) -> () -> Void
    func sendMessage(_ message: ChatMessage, in chatId: String) async throws
    func ensureSession(_ session: ChatSession) async throws
    func markSessionRead(chatId: String) async throws
    func deleteSession(_ chatId: String) async throws
}

enum ChatId {
    static func make(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "_")
    }
}
