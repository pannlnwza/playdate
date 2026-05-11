import Foundation

struct Event: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var locationName: String
    var latitude: Double
    var longitude: Double
    var dateTime: Date
    var organizerId: String
    var participantIds: [String]

    var endDateTime: Date?
    var minAge: Int
    var maxAge: Int
    var category: EventCategory
    var attendingFamilyCount: Int
    var isFeatured: Bool
    var tags: [String]
    var isRecurring: Bool
    var frequency: RecurrenceFrequency?

    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         locationName: String,
         latitude: Double,
         longitude: Double,
         dateTime: Date,
         organizerId: String,
         participantIds: [String] = [],
         endDateTime: Date? = nil,
         minAge: Int = 0,
         maxAge: Int = 100,
         category: EventCategory = .outdoors,
         attendingFamilyCount: Int = 0,
         isFeatured: Bool = false,
         tags: [String] = [],
         isRecurring: Bool = false,
         frequency: RecurrenceFrequency? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.dateTime = dateTime
        self.organizerId = organizerId
        self.participantIds = participantIds
        self.endDateTime = endDateTime
        self.minAge = minAge
        self.maxAge = maxAge
        self.category = category
        self.attendingFamilyCount = attendingFamilyCount
        self.isFeatured = isFeatured
        self.tags = tags
        self.isRecurring = isRecurring
        self.frequency = frequency
    }

    var location: String { locationName }
    var date: Date { dateTime }
    var startTime: String { dateTime.formatted(date: .omitted, time: .shortened) }
    var endTime: String { endDateTime?.formatted(date: .omitted, time: .shortened) ?? "" }
}

enum EventCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case outdoors = "Outdoors"
    case sports = "Sports"
    case arts = "Arts"
    case music = "Music"
    case storytime = "Storytime"
    case educational = "Educational"
    case sensory = "Sensory Play"
    case fitness = "Fitness"
    case social = "Social Gathering"

    var id: String { rawValue }
}

enum RecurrenceFrequency: String, Codable, CaseIterable {
    case daily
    case weekly
    case biweekly
    case monthly
}
