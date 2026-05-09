import Foundation
import Observation

@Observable
final class EventsViewModel {
    var events: [Event]
    var selectedCategory: EventCategory?
    var searchText: String = ""
    var joinedEventIDs: Set<String> = []

    init(events: [Event] = Event.mockEvents) {
        self.events = events
    }

    var featuredEvent: Event? {
        events.first { $0.isFeatured }
    }

    var upcomingEvents: [Event] {
        events.filter { event in
            guard !event.isFeatured else { return false }
            if let category = selectedCategory, event.category != category { return false }
            if !searchText.isEmpty,
               !event.title.localizedCaseInsensitiveContains(searchText),
               !event.location.localizedCaseInsensitiveContains(searchText) {
                return false
            }
            return true
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
}
