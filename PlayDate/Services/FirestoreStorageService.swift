import Foundation
import FirebaseFirestore

class FirestoreStorageService: StorageServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let collectionName = "media_storage"
    
    func uploadImage(_ data: Data, path: String) async throws -> URL {
        // Firestore has a 1MB limit per document. 
        // We should ideally compress the image here if it's too large.
        // For this implementation, we assume the data is already optimized or small enough.
        
        if data.count > 1_000_000 {
            throw NSError(domain: "FirestoreStorage", code: 413, userInfo: [NSLocalizedDescriptionKey: "Image too large for Firestore (max 1MB)"])
        }
        
        let base64String = data.base64EncodedString()
        let dataUri = "data:image/jpeg;base64,\(base64String)"
        
        // Use the provided path as the document ID (replacing slashes with underscores or similar)
        let docId = path.replacingOccurrences(of: "/", with: "_")
        
        try await db.collection(collectionName).document(docId).setData([
            "data": base64String,
            "contentType": "image/jpeg",
            "updatedAt": FieldValue.serverTimestamp()
        ])
        
        guard let url = URL(string: dataUri) else {
            throw NSError(domain: "FirestoreStorage", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to create Data URI"])
        }
        
        return url
    }
    
    func deleteImage(path: String) async throws {
        let docId = path.replacingOccurrences(of: "/", with: "_")
        try await db.collection(collectionName).document(docId).delete()
    }
}
