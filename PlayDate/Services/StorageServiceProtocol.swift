import Foundation

protocol StorageServiceProtocol {
    /// Uploads image data to the specified path in Firebase Storage.
    /// - Parameters:
    ///   - data: The image data to upload.
    ///   - path: The destination path (e.g., "profile_images/user123.jpg").
    /// - Returns: The download URL of the uploaded image.
    func uploadImage(_ data: Data, path: String) async throws -> URL
    
    /// Deletes an image at the specified path.
    /// - Parameter path: The path of the image to delete.
    func deleteImage(path: String) async throws
}
