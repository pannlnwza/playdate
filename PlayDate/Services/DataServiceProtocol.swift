import Foundation

enum SwipeDirection {
    case left, right
}

protocol DataServiceProtocol {
    func fetchPotentialMatches() async throws -> [Child]
    func swipe(childId: String, direction: SwipeDirection) async throws
    func fetchEvents() async throws -> [Event]
    func joinEvent(eventId: String, userId: String) async throws
    func createEvent(_ event: Event) async throws
}
