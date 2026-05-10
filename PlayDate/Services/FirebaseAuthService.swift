import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseAuthService: AuthServiceProtocol {
    private lazy var auth = Auth.auth()
    private lazy var db = Firestore.firestore()
    private let storage: StorageServiceProtocol
    private let parentsCollection = "parents"
    private let childrenCollection = "children"

    init(storage: StorageServiceProtocol = FirestoreStorageService()) {
        self.storage = storage
    }

    var currentUserId: String? { auth.currentUser?.uid }
    var currentUserEmail: String? { auth.currentUser?.email }

    func signIn(email: String, password: String) async throws -> Parent {
        let result = try await auth.signIn(withEmail: email, password: password)
        let uid = result.user.uid
        if let existing = try await loadParent(id: uid) {
            return existing
        }
        let parent = Parent(id: uid, name: "", email: result.user.email ?? email)
        return try await saveParent(parent, profileImage: nil)
    }

    func signUp(name: String, email: String, password: String) async throws -> Parent {
        let result = try await auth.createUser(withEmail: email, password: password)
        let parent = Parent(id: result.user.uid, name: name, email: email)
        return try await saveParent(parent, profileImage: nil)
    }

    func signOut() throws {
        try auth.signOut()
    }

    func loadParent(id: String) async throws -> Parent? {
        let snapshot = try await db.collection(parentsCollection).document(id).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: Parent.self)
    }

    func saveParent(_ parent: Parent, profileImage: Data?) async throws -> Parent {
        var updated = parent
        if let image = profileImage {
            let url = try await storage.uploadImage(image, path: "parents/\(parent.id).jpg")
            updated.profileImageUrl = url.absoluteString
        }
        try db.collection(parentsCollection).document(updated.id).setData(from: updated, merge: true)
        return updated
    }

    func saveChild(_ child: Child, images: [Data]) async throws -> Child {
        var updated = child
        if !images.isEmpty {
            updated.imageUrls = try await uploadImages(images, prefix: child.id)
        }
        try db.collection(childrenCollection).document(updated.id).setData(from: updated, merge: true)
        return updated
    }

    func updateChild(_ child: Child, newImages: [Data], keptImageUrls: [String]) async throws -> Child {
        var updated = child
        let newUrls = newImages.isEmpty
            ? []
            : try await uploadImages(newImages, prefix: "\(child.id)_\(Int(Date().timeIntervalSince1970))")
        updated.imageUrls = keptImageUrls + newUrls
        try db.collection(childrenCollection).document(updated.id).setData(from: updated, merge: true)
        return updated
    }

    func deleteChild(_ child: Child, parent: Parent) async throws -> Parent {
        try await db.collection(childrenCollection).document(child.id).delete()
        var updatedParent = parent
        updatedParent.childrenIds.removeAll { $0 == child.id }
        try db.collection(parentsCollection).document(updatedParent.id).setData(from: updatedParent, merge: true)
        return updatedParent
    }

    func fetchChildren(ids: [String]) async throws -> [Child] {
        guard !ids.isEmpty else { return [] }
        var results: [Child] = []
        for id in ids {
            if let child = try? await db.collection(childrenCollection).document(id).getDocument().data(as: Child.self) {
                results.append(child)
            }
        }
        return results
    }

    private func uploadImages(_ images: [Data], prefix: String) async throws -> [String] {
        var urls: [String] = []
        for (index, data) in images.enumerated() {
            let url = try await storage.uploadImage(data, path: "children/\(prefix)_\(index).jpg")
            urls.append(url.absoluteString)
        }
        return urls
    }
}
