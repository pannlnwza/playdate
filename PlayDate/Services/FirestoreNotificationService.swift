import Foundation
import FirebaseFirestore

final class FirestoreNotificationService: NotificationServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let collectionName = "notifications"

    func observeNotifications(for userId: String, onUpdate: @escaping ([AppNotification]) -> Void) -> () -> Void {
        print("📬 NotificationService: starting listener for userId=\(userId)")
        let listener = db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    print("❌ NotificationService listener error: \(error.localizedDescription)")
                }
                let docCount = snapshot?.documents.count ?? 0
                let items = snapshot?.documents.compactMap { doc -> AppNotification? in
                    do {
                        let n = try doc.data(as: AppNotification.self)
                        return AppNotification(
                            id: doc.documentID,
                            kind: n.kind,
                            title: n.title,
                            body: n.body,
                            timestamp: n.timestamp,
                            isRead: n.isRead,
                            iconName: n.iconName
                        )
                    } catch {
                        print("❌ Failed to decode notification \(doc.documentID): \(error)")
                        return nil
                    }
                }
                .sorted { $0.timestamp > $1.timestamp } ?? []
                print("📬 NotificationService: \(docCount) raw docs, \(items.count) decoded")
                Task { @MainActor in onUpdate(items) }
            }
        return { listener.remove() }
    }

    func markRead(notificationDocId: String) async throws {
        try await db.collection(collectionName).document(notificationDocId).updateData([
            "isRead": true
        ])
    }

    func markAllRead(for userId: String) async throws {
        let snapshot = try await db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        for doc in snapshot.documents {
            try await doc.reference.updateData(["isRead": true])
        }
    }

    func delete(notificationDocId: String) async throws {
        try await db.collection(collectionName).document(notificationDocId).delete()
    }

    func notifyMatch(forUserId: String, fromUserName: String, childName: String) async throws {
        let docId = "\(forUserId)_match_\(UUID().uuidString)"
        try await db.collection(collectionName).document(docId).setData([
            "id": docId,
            "userId": forUserId,
            "kind": AppNotificationKind.match.rawValue,
            "title": "It's a PlayDate!",
            "body": "\(fromUserName.isEmpty ? "Someone" : fromUserName) swiped right on \(childName). Say hello!",
            "timestamp": Timestamp(date: Date()),
            "isRead": false,
            "iconName": "hand.thumbsup.fill"
        ])
    }

    func notifyMessage(forUserId: String, fromUserName: String, preview: String) async throws {
        let docId = "\(forUserId)_message_\(UUID().uuidString)"
        try await db.collection(collectionName).document(docId).setData([
            "id": docId,
            "userId": forUserId,
            "kind": AppNotificationKind.message.rawValue,
            "title": "New message from \(fromUserName.isEmpty ? "someone" : fromUserName)",
            "body": preview,
            "timestamp": Timestamp(date: Date()),
            "isRead": false,
            "iconName": "message.fill"
        ])
    }
}
