import Foundation
import CoreLocation
import FirebaseFirestore

final class FirestoreDataService: DataServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let parentsCollection = "parents"
    private let childrenCollection = "children"
    private let swipesCollection = "swipes"
    private let eventsCollection = "events"

    private let currentUserId: String?

    init(currentUserId: String?) {
        self.currentUserId = currentUserId
    }

    func loadParent(id: String) async throws -> Parent? {
        try await db.collection(parentsCollection).document(id).getDocument().data(as: Parent.self)
    }

    func loadChild(id: String) async throws -> Child? {
        try await db.collection(childrenCollection).document(id).getDocument().data(as: Child.self)
    }

    func fetchPotentialMatches() async throws -> [Child] {
        let snapshot = try await db.collection(childrenCollection).getDocuments()
        var children = snapshot.documents.compactMap { try? $0.data(as: Child.self) }

        guard let userId = currentUserId else { return children }
        let swipedIds = try await fetchSwipedChildIds()
        children = children.filter { $0.parentId != userId && !swipedIds.contains($0.id) }

        return try await annotateDistances(children: children, currentUserId: userId)
    }

    private func annotateDistances(children: [Child], currentUserId: String) async throws -> [Child] {
        var parentMap: [String: Parent] = [:]
        for parentId in Set(children.map(\.parentId)) {
            if let parent = try? await db.collection(parentsCollection).document(parentId).getDocument().data(as: Parent.self) {
                parentMap[parent.id] = parent
            }
        }

        var myLocation: CLLocation?
        if let myParent = try? await db.collection(parentsCollection).document(currentUserId).getDocument().data(as: Parent.self),
           let myLat = myParent.latitude, let myLon = myParent.longitude {
            myLocation = CLLocation(latitude: myLat, longitude: myLon)
        }

        return children.map { child in
            var c = child
            if let other = parentMap[child.parentId] {
                c.parentImageUrl = other.profileImageUrl
                if let myLoc = myLocation, let lat = other.latitude, let lon = other.longitude {
                    let otherLocation = CLLocation(latitude: lat, longitude: lon)
                    c.distanceKm = myLoc.distance(from: otherLocation) / 1000.0
                }
            }
            return c
        }
    }

    func swipe(childId: String, direction: SwipeDirection) async throws {
        guard let userId = currentUserId else { return }
        let docId = "\(userId)_\(childId)"
        try await db.collection(swipesCollection).document(docId).setData([
            "userId": userId,
            "childId": childId,
            "direction": direction == .right ? "right" : "left",
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    func recordSwipeAndCheckMatch(childId: String, otherParentId: String, ownChildIds: [String]) async throws -> Bool {
        try await swipe(childId: childId, direction: .right)

        if otherParentId.hasPrefix("seed-parent-") { return true }
        guard !ownChildIds.isEmpty else { return false }

        let snapshot = try await db.collection(swipesCollection)
            .whereField("userId", isEqualTo: otherParentId)
            .whereField("direction", isEqualTo: "right")
            .whereField("childId", in: Array(ownChildIds.prefix(10)))
            .getDocuments()
        return !snapshot.documents.isEmpty
    }

    func fetchSwipedChildIds() async throws -> Set<String> {
        guard let userId = currentUserId else { return [] }
        let snapshot = try await db.collection(swipesCollection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        return Set(snapshot.documents.compactMap { $0.data()["childId"] as? String })
    }

    func fetchEvents() async throws -> [Event] {
        let snapshot = try await db.collection(eventsCollection).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Event.self) }
    }

    func joinEvent(eventId: String, userId: String) async throws {
        try await db.collection(eventsCollection).document(eventId).updateData([
            "participantIds": FieldValue.arrayUnion([userId])
        ])
    }

    func leaveEvent(eventId: String, userId: String) async throws {
        try await db.collection(eventsCollection).document(eventId).updateData([
            "participantIds": FieldValue.arrayRemove([userId])
        ])
    }

    func createEvent(_ event: Event) async throws {
        try db.collection(eventsCollection).document(event.id).setData(from: event)
    }
}
