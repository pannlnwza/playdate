import Foundation
import Observation

@Observable
final class EventsViewModel {
    var events: [Event]
    var selectedCategories: Set<EventCategory> = []
    var searchText: String = ""
    var joinedEventIDs: Set<String> = []
    
    var startDate: Date?
    var endDate: Date?
    
    enum SortOption {
        case date
        case participantCount
    }
    
    var sortOption: SortOption = .date

    init(events: [Event] = Event.mockEvents) {
        self.events = events
    }

    var featuredEvent: Event? {
        events.first { $0.isFeatured }
    }

    var upcomingEvents: [Event] {
        let filtered = events.filter { event in
            guard !event.isFeatured else { return false }
            
            // Category filter
            if !selectedCategories.isEmpty, !selectedCategories.contains(event.category) {
                return false
            }
            
            // Search text filter
            if !searchText.isEmpty,
               !event.title.localizedCaseInsensitiveContains(searchText),
               !event.location.localizedCaseInsensitiveContains(searchText) {
                return false
            }
            
            // Date range filter
            if let start = startDate, event.dateTime < start { return false }
            if let end = endDate, event.dateTime > end { return false }
            
            return true
        }
        
        // Sorting
        switch sortOption {
        case .date:
            return filtered.sorted { $0.dateTime < $1.dateTime }
        case .participantCount:
            return filtered.sorted { $0.attendingFamilyCount > $1.attendingFamilyCount }
        }
    }

    func toggleJoin(_ event: Event) {
        if joinedEventIDs.contains(event.id) {
            joinedEventIDs.remove(event.id)
        } else {
            joinedEventIDs.insert(event.id)
        }
    }

    func isJoined(_ event: Event) -> Bool {
        joinedEventIDs.contains(event.id)
    }
    
    func clearFilters() {
        selectedCategories.removeAll()
        searchText = ""
        startDate = nil
        endDate = nil
    }
}
