import Foundation
import FirebaseStorage

class FirebaseStorageService: StorageServiceProtocol {
    private let storage = Storage.storage().reference()
    
    func uploadImage(_ data: Data, path: String) async throws -> URL {
        let fileRef = storage.child(path)
        
        // Metadata can be added here if needed (e.g., content type)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await fileRef.putDataAsync(data, metadata: metadata)
        let url = try await fileRef.downloadURL()
        return url
    }
    
    func deleteImage(path: String) async throws {
        let fileRef = storage.child(path)
        try await fileRef.delete()
    }
}
