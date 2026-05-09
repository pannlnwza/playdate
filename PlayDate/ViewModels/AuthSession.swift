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

    var isAuthenticated: Bool { currentUser != nil }

    func signIn(email: String, password: String) {
        currentUser = .mockCurrentUser
        ownChildren = Parent.mockOwnChildren
        needsOnboarding = false
    }

    func signUp(name: String, email: String, password: String) {
        currentUser = Parent(name: name, email: email)
        ownChildren = []
        needsOnboarding = true
    }

    func signOut() {
        currentUser = nil
        ownChildren = []
        needsOnboarding = false
        profileImage = nil
        childImages = [:]
    }

    func dismissOnboarding() {
        needsOnboarding = false
    }

    func updateProfile(name: String, location: String?, bio: String?, image: UIImage? = nil) {
        guard var user = currentUser else { return }
        user.name = name
        user.location = location?.isEmpty == false ? location : nil
        user.bio = bio?.isEmpty == false ? bio : nil
        currentUser = user
        if let image { profileImage = image }
    }

    func addChild(name: String, age: Int, hobbies: [String], image: UIImage? = nil) {
        guard let parentId = currentUser?.id else { return }
        let child = Child(parentId: parentId, name: name, age: age, hobbies: hobbies)
        ownChildren.append(child)
        currentUser?.childrenIds.append(child.id)
        if let image { childImages[child.id] = image }
    }
}
