import Foundation
import Observation

@Observable
final class ChatListViewModel {
    var sessions: [ChatSession] = []
    var isLoading: Bool = true

    var unreadCount: Int { sessions.filter(\.isNewMatch).count }

    private var chatService: ChatServiceProtocol?
    private var stop: (() -> Void)?

    deinit {
        stop?()
    }

    func attach(service: ChatServiceProtocol, userId: String) {
        stop?()
        chatService = service
        stop = service.observeSessions(for: userId) { [weak self] sessions in
            self?.sessions = sessions
            self?.isLoading = false
        }
    }

    func detach() {
        stop?()
        stop = nil
    }
}
