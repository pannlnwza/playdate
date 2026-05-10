import Foundation
import Observation
import UIKit

@Observable
final class AuthSession {
    var currentUser: Parent?
    var ownChildren: [Child] = []
    var needsOnboarding: Bool = false
    var profileImage: UIImage?
    var childImages: [String: UIImage] = [:]

    var isLoading: Bool = false
    var errorMessage: String?

    private let authService: AuthServiceProtocol

    var isAuthenticated: Bool { currentUser != nil }

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? (AppEnvironment.isPreview ? MockAuthService() : FirebaseAuthService())
    }

    func bootstrap() async {
        guard currentUser == nil, let uid = authService.currentUserId else { return }
        currentUser = Parent(id: uid, name: "", email: authService.currentUserEmail ?? "")
        await refreshCurrentUser()
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            needsOnboarding = false
            ownChildren = (try? await authService.fetchChildren(ids: user.childrenIds)) ?? []
            await MockSeeder.seedUserDataIfNeeded(userId: user.id)
        } catch {
            logAuthError("signIn", error: error)
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authService.signUp(name: name, email: email, password: password)
            currentUser = user
            ownChildren = []
            needsOnboarding = true
            await MockSeeder.seedUserDataIfNeeded(userId: user.id)
        } catch {
            logAuthError("signUp", error: error)
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func logAuthError(_ context: String, error: Error) {
        let ns = error as NSError
        print("=== AuthSession.\(context) failed ===")
        print("domain: \(ns.domain)  code: \(ns.code)")
        print("description: \(ns.localizedDescription)")
        for (key, value) in ns.userInfo {
            print("  \(key): \(value)")
        }
        if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError {
            print("underlying: \(underlying.domain) \(underlying.code) — \(underlying.localizedDescription)")
        }
        print("===")
    }

    func signOut() {
        do {
            try authService.signOut()
            currentUser = nil
            ownChildren = []
            needsOnboarding = false
            profileImage = nil
            childImages = [:]
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissOnboarding() {
        needsOnboarding = false
    }

    func updateProfile(name: String, location: String?, bio: String?,
                       latitude: Double? = nil, longitude: Double? = nil,
                       image: UIImage? = nil) async {
        guard var user = currentUser else { return }
        user.name = name
        user.location = location?.isEmpty == false ? location : nil
        user.bio = bio?.isEmpty == false ? bio : nil
        if let latitude { user.latitude = latitude }
        if let longitude { user.longitude = longitude }

        if let image { profileImage = image }
        let imageData = image?.compressedJPEGUnderBudget(700_000)

        isLoading = true
        errorMessage = nil
        do {
            currentUser = try await authService.saveParent(user, profileImage: imageData)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addChild(name: String, age: Int, bio: String? = nil, hobbies: [String], images: [UIImage] = []) async {
        guard let user = currentUser else { return }
        let child = Child(parentId: user.id, name: name, age: age, bio: bio, hobbies: hobbies,
                          parentName: user.name, parentImageUrl: user.profileImageUrl,
                          parentVerified: user.isVerified)

        if let first = images.first { childImages[child.id] = first }
        let imageData = images.compactMap { $0.compressedJPEGUnderBudget(700_000) }

        isLoading = true
        errorMessage = nil
        do {
            let saved = try await authService.saveChild(child, images: imageData)
            ownChildren.append(saved)
            var updatedUser = user
            updatedUser.childrenIds.append(saved.id)
            currentUser = try await authService.saveParent(updatedUser, profileImage: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updateChild(_ child: Child, name: String, age: Int, bio: String? = nil, hobbies: [String],
                     newImages: [UIImage], keptImageUrls: [String]) async {
        guard let user = currentUser else { return }
        var updated = child
        updated.name = name
        updated.age = age
        updated.bio = bio
        updated.hobbies = hobbies
        updated.parentName = user.name
        updated.parentImageUrl = user.profileImageUrl
        updated.parentVerified = user.isVerified

        if let first = newImages.first { childImages[child.id] = first }
        let imageData = newImages.compactMap { $0.compressedJPEGUnderBudget(700_000) }

        isLoading = true
        errorMessage = nil
        do {
            let saved = try await authService.updateChild(updated, newImages: imageData, keptImageUrls: keptImageUrls)
            if let index = ownChildren.firstIndex(where: { $0.id == saved.id }) {
                ownChildren[index] = saved
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteChild(_ child: Child) async {
        guard let user = currentUser else { return }
        isLoading = true
        errorMessage = nil
        do {
            currentUser = try await authService.deleteChild(child, parent: user)
            ownChildren.removeAll { $0.id == child.id }
            childImages.removeValue(forKey: child.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func refreshCurrentUser() async {
        guard let uid = authService.currentUserId else { return }
        if let parent = try? await authService.loadParent(id: uid) {
            currentUser = parent
            ownChildren = (try? await authService.fetchChildren(ids: parent.childrenIds)) ?? []
        }
    }
}
