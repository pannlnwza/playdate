import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    var children: [Child] = []
    var matchedChild: Child?
    var showMatch: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    var minAge: Int = 0
    var maxAge: Int = 18
    var selectedHobbies: Set<String> = []
    var eventFilterId: String?
    var eventFilterParentIds: Set<String> = []

    var filteredChildren: [Child] {
        children.filter { child in
            if child.age < minAge || child.age > maxAge { return false }
            if !selectedHobbies.isEmpty && selectedHobbies.isDisjoint(with: Set(child.hobbies)) { return false }
            if !eventFilterParentIds.isEmpty && !eventFilterParentIds.contains(child.parentId) { return false }
            return true
        }
    }

    var hasActiveFilters: Bool {
        minAge > 0 || maxAge < 18 || !selectedHobbies.isEmpty || eventFilterId != nil
    }

    func clearFilters() {
        minAge = 0
        maxAge = 18
        selectedHobbies = []
        eventFilterId = nil
        eventFilterParentIds = []
    }

    private var lastSwipedChild: Child?

    private var dataService: DataServiceProtocol?
    private var chatService: ChatServiceProtocol?
    private var notificationService: NotificationServiceProtocol?
    private var currentUserId: String?
    private var currentUserName: String?
    private var currentUserImageUrl: String?
    private var ownChildIds: [String] = []

    init(children: [Child] = []) {
        self.children = children
    }

    func attach(dataService: DataServiceProtocol,
                chatService: ChatServiceProtocol,
                notificationService: NotificationServiceProtocol,
                currentUserId: String?,
                currentUserName: String?,
                currentUserImageUrl: String?,
                ownChildIds: [String]) {
        self.dataService = dataService
        self.chatService = chatService
        self.notificationService = notificationService
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.currentUserImageUrl = currentUserImageUrl
        self.ownChildIds = ownChildIds
    }

    var canRewind: Bool { lastSwipedChild != nil }

    func load() async {
        guard let dataService else { return }
        isLoading = true
        errorMessage = nil
        do {
            children = try await dataService.fetchPotentialMatches()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func swipeTop(_ direction: SwipeDirection) {
        guard let topChild = filteredChildren.first else { return }
        swipe(direction, child: topChild)
    }

    func swipe(_ direction: SwipeDirection, child: Child) {
        children.removeAll { $0.id == child.id }
        lastSwipedChild = child

        guard let dataService else {
            print("⚠️ DiscoverViewModel.swipe: no dataService attached")
            return
        }

        if direction == .right {
            Task {
                do {
                    let isMatch = try await dataService.recordSwipeAndCheckMatch(
                        childId: child.id,
                        otherParentId: child.parentId,
                        ownChildIds: ownChildIds
                    )
                    print("✅ Swipe right recorded for child \(child.id). isMatch=\(isMatch)")
                    if isMatch {
                        matchedChild = child
                        showMatch = true
                        createChatSession(for: child)
                        notifyOtherParent(of: child)
                    }
                } catch {
                    print("❌ Swipe right failed for child \(child.id): \(error.localizedDescription)")
                    let ns = error as NSError
                    print("   domain: \(ns.domain) code: \(ns.code) info: \(ns.userInfo)")
                }
            }
        } else {
            Task {
                do {
                    try await dataService.swipe(childId: child.id, direction: direction)
                    print("✅ Swipe left recorded for child \(child.id)")
                } catch {
                    print("❌ Swipe left failed for child \(child.id): \(error.localizedDescription)")
                    let ns = error as NSError
                    print("   domain: \(ns.domain) code: \(ns.code) info: \(ns.userInfo)")
                }
            }
        }
    }

    func rewind() {
        guard let last = lastSwipedChild else { return }
        children.insert(last, at: 0)
        lastSwipedChild = nil
    }

    private func notifyOtherParent(of child: Child) {
        guard let notificationService else { return }
        let fromName = currentUserName ?? ""
        Task {
            try? await notificationService.notifyMatch(
                forUserId: child.parentId,
                fromUserName: fromName,
                childName: child.name
            )
        }
    }

    private func createChatSession(for child: Child) {
        guard let userId = currentUserId, let chatService else { return }
        let sessionId = ChatId.make(userId, child.parentId)
        Task {
            let otherParent = try? await dataService?.loadParent(id: child.parentId)

            var names: [String: String] = [:]
            if let name = currentUserName, !name.isEmpty { names[userId] = name }
            let otherName = child.parentName ?? otherParent?.name ?? ""
            if !otherName.isEmpty { names[child.parentId] = otherName }

            var images: [String: String] = [:]
            if let url = currentUserImageUrl, !url.isEmpty { images[userId] = url }
            if let url = otherParent?.profileImageUrl, !url.isEmpty { images[child.parentId] = url }

            let childIds: [String: String] = [userId: child.id]

            let session = ChatSession(
                id: sessionId,
                participantIds: [userId, child.parentId],
                participantNames: names,
                participantImageUrls: images,
                participantChildIds: childIds,
                parentName: otherName,
                parentImageUrl: otherParent?.profileImageUrl,
                childId: child.id,
                childContext: "Just matched with \(child.name)",
                isNewMatch: true
            )
            try? await chatService.ensureSession(session)
        }
    }
}
