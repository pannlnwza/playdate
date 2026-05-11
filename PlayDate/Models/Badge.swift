import Foundation

struct Badge: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let iconName: String
    let description: String

    init(id: String = UUID().uuidString,
         name: String,
         iconName: String,
         description: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.description = description
    }
}

extension Badge {
    static let verified = Badge(name: "Verified Parent", iconName: "checkmark.seal.fill", description: "This parent has been verified by the PlayDate team.")
    static let frequentHost = Badge(name: "Frequent Host", iconName: "house.fill", description: "This parent has hosted 5 or more playdates.")
    static let superResponder = Badge(name: "Super Responder", iconName: "bolt.fill", description: "This parent usually responds within an hour.")
}
