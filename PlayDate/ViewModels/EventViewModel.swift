import Foundation
import Combine

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    
    private let dataService: DataServiceProtocol
    private let userId: String
    
    var filteredEvents: [Event] {
        if searchQuery.isEmpty {
            return events
        } else {
            return events.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) || $0.description.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    init(dataService: DataServiceProtocol, userId: String) {
        self.dataService = dataService
        self.userId = userId
    }
    
    func fetchEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            events = try await dataService.fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func joinEvent(_ event: Event) async {
        isLoading = true
        errorMessage = nil
        do {
            try await dataService.joinEvent(eventId: event.id, userId: userId)
            // Update local state if successful
            if let index = events.firstIndex(where: { $0.id == event.id }) {
                if !events[index].participantIds.contains(userId) {
                    events[index].participantIds.append(userId)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func createEvent(title: String, description: String, locationName: String, latitude: Double, longitude: Double, dateTime: Date) async {
        let newEvent = Event(
            title: title,
            description: description,
            locationName: locationName,
            latitude: latitude,
            longitude: longitude,
            dateTime: dateTime,
            organizerId: userId,
            participantIds: [userId]
        )
        
        isLoading = true
        errorMessage = nil
        do {
            try await dataService.createEvent(newEvent)
            events.append(newEvent)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
