import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: Parent?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        self.currentUser = authService.currentUser
        self.isAuthenticated = authService.currentUser != nil
    }
    
    func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            currentUser = try await authService.signIn()
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        isLoading = false
    }
    
    func signOut() {
        do {
            try authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(name: String, bio: String?) async {
        guard var updatedUser = currentUser else { return }
        updatedUser.name = name
        updatedUser.bio = bio
        
        isLoading = true
        errorMessage = nil
        do {
            try await authService.updateProfile(updatedUser)
            currentUser = updatedUser
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
