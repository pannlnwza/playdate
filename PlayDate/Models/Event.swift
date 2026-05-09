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
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         locationName: String,
         latitude: Double,
         longitude: Double,
         dateTime: Date,
         organizerId: String,
         participantIds: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.dateTime = dateTime
        self.organizerId = organizerId
        self.participantIds = participantIds
    }
}
