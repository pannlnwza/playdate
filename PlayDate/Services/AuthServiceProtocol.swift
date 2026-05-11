import Foundation

protocol AuthServiceProtocol {
    var currentUserId: String? { get }
    var currentUserEmail: String? { get }

    func signIn(email: String, password: String) async throws -> Parent
    func signUp(name: String, email: String, password: String) async throws -> Parent
    func signOut() throws
    func loadParent(id: String) async throws -> Parent?
    func saveParent(_ parent: Parent, profileImage: Data?) async throws -> Parent
    func saveChild(_ child: Child, images: [Data]) async throws -> Child
    func updateChild(_ child: Child, newImages: [Data], keptImageUrls: [String]) async throws -> Child
    func deleteChild(_ child: Child, parent: Parent) async throws -> Parent
    func fetchChildren(ids: [String]) async throws -> [Child]
}
