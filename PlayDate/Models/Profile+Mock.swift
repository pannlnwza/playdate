import Foundation

extension Profile {
    static let mockProfile = Profile(
        id: "user-current",
        name: "Rachel Anderson",
        location: "Brooklyn, NY",
        isVerified: true,
        matchesCount: 24,
        playdatesCount: 12,
        rating: 4.9,
        children: [
            ProfileChild(id: "lucas", name: "Lucas", age: 6, interests: ["Soccer", "Lego"]),
            ProfileChild(id: "mia", name: "Mia", age: 3, interests: ["Dance", "Art"])
        ]
    )
}
