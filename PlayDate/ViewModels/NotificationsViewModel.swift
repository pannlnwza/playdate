import Foundation
import Observation

@Observable
final class NotificationsViewModel {
    var notifications: [AppNotification] = []
    var isLoading: Bool = true

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    private var service: NotificationServiceProtocol?
    private var userId: String?
    private var stop: (() -> Void)?

    deinit { stop?() }

    func attach(service: NotificationServiceProtocol, userId: String) {
        stop?()
        self.service = service
        self.userId = userId
        stop = service.observeNotifications(for: userId) { [weak self] items in
            self?.notifications = items
            self?.isLoading = false
        }
    }

    func markRead(_ notification: AppNotification) {
        guard let service else { return }
        Task { try? await service.markRead(notificationDocId: notification.id) }
    }

    func markAllRead() {
        guard let service, let userId else { return }
        Task { try? await service.markAllRead(for: userId) }
    }

    func delete(_ notification: AppNotification) {
        guard let service else { return }
        Task { try? await service.delete(notificationDocId: notification.id) }
    }
}
