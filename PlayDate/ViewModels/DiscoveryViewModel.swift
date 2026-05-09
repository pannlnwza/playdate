import Foundation
import Combine

@MainActor
class DiscoveryViewModel: ObservableObject {
    @Published var potentialMatches: [Child] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    func fetchPotentialMatches() async {
        isLoading = true
        errorMessage = nil
        do {
            potentialMatches = try await dataService.fetchPotentialMatches()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func swipeRight(child: Child) async {
        // Remove from list immediately for better UI feel
        if let index = potentialMatches.firstIndex(where: { $0.id == child.id }) {
            potentialMatches.remove(at: index)
        }
        
        do {
            try await dataService.swipe(childId: child.id, direction: .right)
        } catch {
            errorMessage = error.localizedDescription
            // Re-add to list if swipe failed? 
            // In a real app, you might handle this more gracefully.
        }
    }
    
    func swipeLeft(child: Child) async {
        if let index = potentialMatches.firstIndex(where: { $0.id == child.id }) {
            potentialMatches.remove(at: index)
        }
        
        do {
            try await dataService.swipe(childId: child.id, direction: .left)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
