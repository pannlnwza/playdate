import Foundation
import Observation

@Observable
final class EventsViewModel {
    // --- Merged Properties ---
    var events: [Event] = []
    var selectedCategories: Set<EventCategory> = [] // Support multiple categories
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Properties from enhancement-1
    var startDate: Date?
    var endDate: Date?
    
    enum SortOption {
        case date
        case participantCount
    }
    
    var sortOption: SortOption = .date

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

    // --- Merged Filtering & Sorting Logic ---
    var upcomingEvents: [Event] {
        let featuredId = featuredEvent?.id
        
        let filtered = events.filter { event in
            // Exclude featured event from the main list
            if event.id == featuredId { return false }
            
            // Multi-category filter
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
        
        // Sorting logic
        switch sortOption {
        case .date:
            return filtered.sorted { $0.dateTime < $1.dateTime }
        case .participantCount:
            return filtered.sorted { $0.participantIds.count > $1.participantIds.count }
        }
    }

    // --- Async Methods from Main ---
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
                // Rollback on failure
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
    
    func clearFilters() {
        selectedCategories.removeAll()
        searchText = ""
        startDate = nil
        endDate = nil
        sortOption = .date
    }
}