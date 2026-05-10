import Foundation

extension Parent {
    static let mockCurrentUser = Parent(
        id: "user-current",
        name: "Rachel Anderson",
        email: "rachel@example.com",
        isVerified: true,
        childrenIds: ["lucas", "mia"],
        location: "Brooklyn, NY",
        matchesCount: 24,
        playdatesCount: 12,
        rating: 4.9
    )

    static let mockOwnChildren: [Child] = [
        Child(id: "lucas", parentId: "user-current", name: "Lucas", age: 6, hobbies: ["Soccer", "Lego"]),
        Child(id: "mia", parentId: "user-current", name: "Mia", age: 3, hobbies: ["Dance", "Art"])
    ]
}
