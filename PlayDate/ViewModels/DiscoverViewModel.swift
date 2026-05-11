import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    // --- Combined Properties ---
    var children: [Child] = []
    var currentUserHobbies: [String] = [] // From enhancement-1
    var matchedChild: Child?
    var showMatch: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    var minAge: Int = 0
    var maxAge: Int = 18
    var maxDistanceKm: Double = 50.0 // From enhancement-1
    var selectedHobbies: Set<String> = []
    var eventFilterId: String?
    var eventFilterParentIds: Set<String> = []

    // --- Merged Filter Logic ---
    var filteredChildren: [Child] {
        children.filter { child in
            if child.age < minAge || child.age > maxAge { return false }
            if !selectedHobbies.isEmpty && selectedHobbies.isDisjoint(with: Set(child.hobbies)) { return false }
            if !eventFilterParentIds.isEmpty && !eventFilterParentIds.contains(child.parentId) { return false }
            
            // Distance filter from enhancement-1
            if let distance = child.distanceKm, distance > maxDistanceKm { return false }
            
            return true
        }
    }

    var hasActiveFilters: Bool {
        minAge > 0 || maxAge < 18 || !selectedHobbies.isEmpty || eventFilterId != nil || maxDistanceKm < 50.0
    }

    func clearFilters() {
        minAge = 0
        maxAge = 18
        selectedHobbies = []
        eventFilterId = nil
        eventFilterParentIds = []
        maxDistanceKm = 50.0
    }

    private var lastSwipedChild: Child?

    // --- Services from Main ---
    private var dataService: DataServiceProtocol?
    private var chatService: ChatServiceProtocol?
    private var notificationService: NotificationServiceProtocol?
    private var currentUserId: String?
    private var currentUserName: String?
    private var currentUserImageUrl: String?
    private var ownChildIds: [String] = []

    init(children: [Child] = [], currentUserHobbies: [String] = []) {
        self.children = children
        self.currentUserHobbies = currentUserHobbies
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

    // --- Loading and Swiping Logic from Main ---
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
                    if isMatch {
                        matchedChild = child
                        showMatch = true
                        createChatSession(for: child)
                        notifyOtherParent(of: child)
                    }
                } catch {
                    print("❌ Swipe right failed: \(error.localizedDescription)")
                }
            }
        } else {
            Task {
                do {
                    try await dataService.swipe(childId: child.id, direction: direction)
                } catch {
                    print("❌ Swipe left failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func rewind() {
        guard let last = lastSwipedChild else { return }
        children.insert(last, at: 0)
        lastSwipedChild = nil
    }

    // --- New Shared Hobby Logic from Enhancement-1 ---
    func sharedHobbiesCount(for child: Child) -> Int {
        let childHobbies = Set(child.hobbies.map { $0.lowercased() })
        let userHobbies = Set(currentUserHobbies.map { $0.lowercased() })
        return childHobbies.intersection(userHobbies).count
    }
    
    func sharedHobbies(for child: Child) -> [String] {
        let childHobbies = Set(child.hobbies.map { $0.lowercased() })
        let userHobbies = Set(currentUserHobbies.map { $0.lowercased() })
        return Array(childHobbies.intersection(userHobbies)).sorted()
    }

    // --- Private Helpers from Main ---
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

            let session = ChatSession(
                id: sessionId,
                participantIds: [userId, child.parentId],
                participantNames: names,
                participantImageUrls: images,
                participantChildIds: [userId: child.id],
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
