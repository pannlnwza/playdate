import Foundation

protocol NotificationServiceProtocol {
    func observeNotifications(for userId: String, onUpdate: @escaping ([AppNotification]) -> Void) -> () -> Void
    func markRead(notificationDocId: String) async throws
    func markAllRead(for userId: String) async throws
    func delete(notificationDocId: String) async throws
    func notifyMatch(forUserId: String, fromUserName: String, childName: String) async throws
    func notifyMessage(forUserId: String, fromUserName: String, preview: String) async throws
}
