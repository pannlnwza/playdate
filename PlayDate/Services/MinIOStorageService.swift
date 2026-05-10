import Foundation

class MinIOStorageService: StorageServiceProtocol {
    private let baseUrl: String
    private let bucketName: String
    
    init(baseUrl: String = "http://localhost:9000", bucketName: String = "playdate-media") {
        self.baseUrl = baseUrl
        self.bucketName = bucketName
    }
    
    func uploadImage(_ data: Data, path: String) async throws -> URL {
        let urlString = "\(baseUrl)/\(bucketName)/\(path)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "MinIO", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        // Note: For a private MinIO bucket, you would need to add AWS Signature V4 headers here.
        // For development, we assume the bucket has a 'Public' or 'Custom' policy allowing PUT requests.
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "MinIO", code: 500, userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
        }
        
        return url
    }
    
    func deleteImage(path: String) async throws {
        let urlString = "\(baseUrl)/\(bucketName)/\(path)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "MinIO", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "MinIO", code: 500, userInfo: [NSLocalizedDescriptionKey: "Delete failed"])
        }
    }
}
