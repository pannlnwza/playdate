import Foundation

enum AppNotificationKind: String, Codable, Hashable {
    case match
    case message
    case event
    case eventReminder
}

struct AppNotification: Identifiable, Codable, Hashable {
    var id: String
    var kind: AppNotificationKind
    var title: String
    var body: String
    var timestamp: Date
    var isRead: Bool
    var iconName: String
}
