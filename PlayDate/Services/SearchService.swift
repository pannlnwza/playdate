import Foundation

protocol SearchServiceProtocol {
    func filterEvents(_ events: [Event], categories: Set<EventCategory>, searchText: String, startDate: Date?, endDate: Date?) -> [Event]
    func filterChildren(_ children: [Child], minAge: Int, maxAge: Int, maxDistance: Double?) -> [Child]
}

class SearchService: SearchServiceProtocol {
    func filterEvents(_ events: [Event], categories: Set<EventCategory>, searchText: String, startDate: Date?, endDate: Date?) -> [Event] {
        events.filter { event in
            // Category filter
            if !categories.isEmpty, !categories.contains(event.category) {
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
    }
    
    func filterChildren(_ children: [Child], minAge: Int, maxAge: Int, maxDistance: Double?) -> [Child] {
        children.filter { child in
            // Age filter
            if child.age < minAge || child.age > maxAge { return false }
            
            // Distance filter
            if let maxDist = maxDistance, let distance = child.distanceKm, distance > maxDist {
                return false
            }
            
            return true
        }
    }
}
