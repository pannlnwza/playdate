import Foundation

enum LocationTag: String, Codable, CaseIterable, Identifiable {
    case strollerFriendly = "Stroller Friendly"
    case fenced = "Fenced"
    case quiet = "Quiet"
    case restrooms = "Restrooms Nearby"
    case indoor = "Indoor"
    case outdoor = "Outdoor"
    case changingStation = "Changing Station"

    var id: String { rawValue }
}
