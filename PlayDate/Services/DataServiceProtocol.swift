import Foundation

enum SwipeDirection {
    case left, right
}

protocol DataServiceProtocol {
    func fetchPotentialMatches() async throws -> [Child]
    func loadParent(id: String) async throws -> Parent?
    func loadChild(id: String) async throws -> Child?
    func swipe(childId: String, direction: SwipeDirection) async throws
    func recordSwipeAndCheckMatch(childId: String, otherParentId: String, ownChildIds: [String]) async throws -> Bool
    func fetchSwipedChildIds() async throws -> Set<String>
    func fetchEvents() async throws -> [Event]
    func joinEvent(eventId: String, userId: String) async throws
    func leaveEvent(eventId: String, userId: String) async throws
    func createEvent(_ event: Event) async throws
}
