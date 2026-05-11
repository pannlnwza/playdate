import Foundation
import FirebaseFirestore

final class FirestoreChatService: ChatServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let chatsCollection = "chats"

    func observeSessions(for userId: String, onUpdate: @escaping ([ChatSession]) -> Void) -> () -> Void {
        let listener = db.collection(chatsCollection)
            .whereField("participantIds", arrayContains: userId)
            .addSnapshotListener { snapshot, _ in
                let sessions = snapshot?.documents
                    .compactMap { try? $0.data(as: ChatSession.self) }
                    .sorted { ($0.lastMessageTimestamp ?? .distantPast) > ($1.lastMessageTimestamp ?? .distantPast) }
                    ?? []
                Task { @MainActor in onUpdate(sessions) }
            }
        return { listener.remove() }
    }

    func observeMessages(in chatId: String, onUpdate: @escaping ([ChatMessage]) -> Void) -> () -> Void {
        let listener = db.collection(chatsCollection)
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, _ in
                let messages = snapshot?.documents
                    .compactMap { try? $0.data(as: ChatMessage.self) }
                    ?? []
                Task { @MainActor in onUpdate(messages) }
            }
        return { listener.remove() }
    }

    func sendMessage(_ message: ChatMessage, in chatId: String) async throws {
        try db.collection(chatsCollection)
            .document(chatId)
            .collection("messages")
            .document(message.id)
            .setData(from: message)

        try await db.collection(chatsCollection).document(chatId).updateData([
            "lastMessage": message.content,
            "lastMessageTimestamp": Timestamp(date: message.timestamp)
        ])
    }

    func ensureSession(_ session: ChatSession) async throws {
        try db.collection(chatsCollection).document(session.id).setData(from: session, merge: true)
    }

    func markSessionRead(chatId: String) async throws {
        try await db.collection(chatsCollection).document(chatId).updateData([
            "isNewMatch": false
        ])
    }

    func deleteSession(_ chatId: String) async throws {
        try await db.collection(chatsCollection).document(chatId).delete()
    }
}
