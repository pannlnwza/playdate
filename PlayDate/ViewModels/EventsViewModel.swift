import Foundation
import Observation

@Observable
final class EventsViewModel {
    var events: [Event] = []
    var selectedCategory: EventCategory?
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private var dataService: DataServiceProtocol?
    private var userId: String?

    init(events: [Event] = []) {
        self.events = events
    }

    func attach(service: DataServiceProtocol, userId: String?) {
        self.dataService = service
        self.userId = userId
    }

    var featuredEvent: Event? {
        let now = Date()
        return events
            .filter { $0.dateTime >= now }
            .max { $0.participantIds.count < $1.participantIds.count }
    }

    var upcomingEvents: [Event] {
        let featuredId = featuredEvent?.id
        return events.filter { event in
            if event.id == featuredId { return false }
            if let category = selectedCategory, event.category != category { return false }
            if !searchText.isEmpty,
               !event.title.localizedCaseInsensitiveContains(searchText),
               !event.location.localizedCaseInsensitiveContains(searchText) {
                return false
            }
            return true
        }
    }

    func load() async {
        guard let dataService else { return }
        isLoading = true
        errorMessage = nil
        do {
            events = try await dataService.fetchEvents().sorted { $0.dateTime < $1.dateTime }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func toggleJoin(_ event: Event) {
        guard let userId, let dataService,
              let index = events.firstIndex(where: { $0.id == event.id }) else { return }

        let wasJoined = events[index].participantIds.contains(userId)
        if wasJoined {
            events[index].participantIds.removeAll { $0 == userId }
        } else {
            events[index].participantIds.append(userId)
        }

        Task {
            do {
                if wasJoined {
                    try await dataService.leaveEvent(eventId: event.id, userId: userId)
                } else {
                    try await dataService.joinEvent(eventId: event.id, userId: userId)
                }
            } catch {
                if wasJoined {
                    events[index].participantIds.append(userId)
                } else {
                    events[index].participantIds.removeAll { $0 == userId }
                }
                errorMessage = error.localizedDescription
            }
        }
    }

    var joinedUpcomingEvents: [Event] {
        guard let userId else { return [] }
        return upcomingEvents(joinedBy: userId)
    }

    func upcomingEvents(joinedBy participantId: String) -> [Event] {
        let now = Date()
        return events
            .filter { $0.participantIds.contains(participantId) && $0.dateTime >= now }
            .sorted { $0.dateTime < $1.dateTime }
    }

    func isJoined(_ event: Event) -> Bool {
        guard let userId else { return false }
        return event.participantIds.contains(userId)
    }
}
