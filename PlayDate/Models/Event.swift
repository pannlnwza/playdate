import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var location: String
    var date: Date
    var startTime: String
    var endTime: String
    var minAge: Int
    var maxAge: Int
    var category: EventCategory
    var attendingFamilyCount: Int
    var isFeatured: Bool
}

enum EventCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case outdoors = "Outdoors"
    case sports = "Sports"
    case arts = "Arts"
    case music = "Music"
    case storytime = "Storytime"

    var id: String { rawValue }
}
