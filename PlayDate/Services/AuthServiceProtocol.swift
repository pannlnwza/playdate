import Foundation

protocol AuthServiceProtocol {
    var currentUser: Parent? { get }
    func signIn() async throws -> Parent
    func signOut() throws
    func updateProfile(_ parent: Parent) async throws
}
