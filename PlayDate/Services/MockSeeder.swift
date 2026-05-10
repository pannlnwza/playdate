import Foundation
import FirebaseFirestore

enum MockSeeder {
    private static let globalSentinelId = "seed-parent-1"

    static func seedIfNeeded() async {
        let db = Firestore.firestore()
        do {
            let sentinel = try await db.collection("parents").document(globalSentinelId).getDocument()
            guard !sentinel.exists else { return }
            try await seedGlobal(db: db)
        } catch {
            print("MockSeeder: skipping global seed — \(error.localizedDescription)")
        }
    }

    static func seedUserDataIfNeeded(userId: String) async {
        let db = Firestore.firestore()
        do {
            let sentinel = try await db.collection("notifications").document("\(userId)_seed-1").getDocument()
            guard !sentinel.exists else { return }
            try await seedUserData(db: db, userId: userId)
        } catch {
            print("MockSeeder: skipping user seed — \(error.localizedDescription)")
        }
    }

    private static func seedGlobal(db: Firestore) async throws {
        let parents: [Parent] = [
            Parent(id: "seed-parent-1", name: "Sarah Lee", email: "sarah@demo.com",
                   isVerified: true, bio: "Brooklyn mom of 2. Always up for a park day.",
                   childrenIds: ["seed-child-emma", "seed-child-noah"],
                   location: "Brooklyn, NY", latitude: 40.6782, longitude: -73.9442,
                   matchesCount: 18, playdatesCount: 9, rating: 4.8),
            Parent(id: "seed-parent-2", name: "Mike Johnson", email: "mike@demo.com",
                   isVerified: true, bio: "Single dad. Music, art, and snack negotiations.",
                   childrenIds: ["seed-child-olivia"],
                   location: "Manhattan, NY", latitude: 40.7831, longitude: -73.9712,
                   matchesCount: 11, playdatesCount: 5, rating: 4.6),
            Parent(id: "seed-parent-3", name: "Aisha Patel", email: "aisha@demo.com",
                   isVerified: false, bio: "Queens-based. Coding club & weekend hikes.",
                   childrenIds: ["seed-child-zayn", "seed-child-kira"],
                   location: "Queens, NY", latitude: 40.7282, longitude: -73.7949,
                   matchesCount: 22, playdatesCount: 14, rating: 4.9)
        ]

        let children: [Child] = [
            Child(id: "seed-child-emma", parentId: "seed-parent-1", name: "Emma", age: 5,
                  bio: "Loves twirling and crayons.", hobbies: ["Dance", "Art"], imageUrls: [],
                  parentName: "Sarah Lee", parentVerified: true, distanceKm: 1.2),
            Child(id: "seed-child-noah", parentId: "seed-parent-1", name: "Noah", age: 7,
                  bio: "Soccer star with a Lego empire.", hobbies: ["Soccer", "Lego"], imageUrls: [],
                  parentName: "Sarah Lee", parentVerified: true, distanceKm: 1.2),
            Child(id: "seed-child-olivia", parentId: "seed-parent-2", name: "Olivia", age: 4,
                  bio: "Sings before she talks.", hobbies: ["Music", "Painting"], imageUrls: [],
                  parentName: "Mike Johnson", parentVerified: true, distanceKm: 3.8),
            Child(id: "seed-child-zayn", parentId: "seed-parent-3", name: "Zayn", age: 6,
                  bio: "Builds robots out of cereal boxes.", hobbies: ["Basketball", "Coding"], imageUrls: [],
                  parentName: "Aisha Patel", parentVerified: false, distanceKm: 5.1),
            Child(id: "seed-child-kira", parentId: "seed-parent-3", name: "Kira", age: 3,
                  bio: "Wants to be a vet. And a unicorn.", hobbies: ["Books", "Animals"], imageUrls: [],
                  parentName: "Aisha Patel", parentVerified: false, distanceKm: 5.1)
        ]

        for parent in parents {
            try db.collection("parents").document(parent.id).setData(from: parent)
        }
        for child in children {
            try db.collection("children").document(child.id).setData(from: child)
        }

        let seedIds = parents.map(\.id)
        for (index, baseEvent) in Event.mockEvents.enumerated() {
            var event = baseEvent
            let take = min(seedIds.count, (index % 3) + 1)
            event.participantIds = Array(seedIds.shuffled().prefix(take))
            try db.collection("events").document(event.id).setData(from: event)
        }

        print("MockSeeder: seeded \(parents.count) parents, \(children.count) children, \(Event.mockEvents.count) events")
    }

    private static func seedUserData(db: Firestore, userId: String) async throws {
        for (index, notification) in AppNotification.mockNotifications.enumerated() {
            let docId = "\(userId)_seed-\(index + 1)"
            try await db.collection("notifications").document(docId).setData([
                "id": notification.id,
                "userId": userId,
                "kind": notification.kind.rawValue,
                "title": notification.title,
                "body": notification.body,
                "timestamp": Timestamp(date: notification.timestamp),
                "isRead": notification.isRead,
                "iconName": notification.iconName
            ])
        }
        print("MockSeeder: seeded \(AppNotification.mockNotifications.count) notifications for \(userId)")
    }
}
