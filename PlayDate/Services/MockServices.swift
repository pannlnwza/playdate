import Foundation

enum AppEnvironment {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

final class MockAuthService: AuthServiceProtocol {
    var currentUserId: String? { nil }
    var currentUserEmail: String? { nil }

    func signIn(email: String, password: String) async throws -> Parent {
        Parent(id: "preview", name: "Preview User", email: email)
    }

    func signUp(name: String, email: String, password: String) async throws -> Parent {
        Parent(id: "preview", name: name, email: email)
    }

    func signOut() throws {}

    func loadParent(id: String) async throws -> Parent? { nil }

    func saveParent(_ parent: Parent, profileImage: Data?) async throws -> Parent { parent }

    func saveChild(_ child: Child, images: [Data]) async throws -> Child { child }
    func updateChild(_ child: Child, newImages: [Data], keptImageUrls: [String]) async throws -> Child { child }
    func deleteChild(_ child: Child, parent: Parent) async throws -> Parent { parent }
    func fetchChildren(ids: [String]) async throws -> [Child] { Parent.mockOwnChildren }
}

final class MockNotificationService: NotificationServiceProtocol {
    func observeNotifications(for userId: String, onUpdate: @escaping ([AppNotification]) -> Void) -> () -> Void {
        Task { @MainActor in onUpdate(AppNotification.mockNotifications) }
        return {}
    }
    func markRead(notificationDocId: String) async throws {}
    func markAllRead(for userId: String) async throws {}
    func delete(notificationDocId: String) async throws {}
    func notifyMatch(forUserId: String, fromUserName: String, childName: String) async throws {}
    func notifyMessage(forUserId: String, fromUserName: String, preview: String) async throws {}
}

final class MockChatService: ChatServiceProtocol {
    func observeSessions(for userId: String, onUpdate: @escaping ([ChatSession]) -> Void) -> () -> Void {
        Task { @MainActor in onUpdate(ChatSession.mockSessions) }
        return {}
    }

    func observeMessages(in chatId: String, onUpdate: @escaping ([ChatMessage]) -> Void) -> () -> Void {
        Task { @MainActor in onUpdate(ChatMessage.mockMessages(for: chatId)) }
        return {}
    }

    func sendMessage(_ message: ChatMessage, in chatId: String) async throws {}
    func ensureSession(_ session: ChatSession) async throws {}
    func markSessionRead(chatId: String) async throws {}
    func deleteSession(_ chatId: String) async throws {}
}

final class MockDataService: DataServiceProtocol {
    func fetchPotentialMatches() async throws -> [Child] { Child.mockChildren }
    func loadParent(id: String) async throws -> Parent? { .mockCurrentUser }
    func loadChild(id: String) async throws -> Child? { Child.mockChildren.first }
    func swipe(childId: String, direction: SwipeDirection) async throws {}
    func recordSwipeAndCheckMatch(childId: String, otherParentId: String, ownChildIds: [String]) async throws -> Bool { true }
    func fetchSwipedChildIds() async throws -> Set<String> { [] }
    func fetchEvents() async throws -> [Event] { Event.mockEvents }
    func joinEvent(eventId: String, userId: String) async throws {}
    func leaveEvent(eventId: String, userId: String) async throws {}
    func createEvent(_ event: Event) async throws {}
}
