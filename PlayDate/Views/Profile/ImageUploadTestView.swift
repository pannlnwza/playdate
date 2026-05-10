import SwiftUI
import PhotosUI

struct ImageUploadTestView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var uploadedURL: URL?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let storageService: StorageServiceProtocol = FirestoreStorageService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Image Preview
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.gray)
                        }
                }
                
                // Photos Picker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Select Photo", systemName: "photo.badge.plus")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            uploadedURL = nil // Reset previous upload
                        }
                    }
                }
                
                // Upload Button
                if let data = selectedImageData {
                    Button(action: uploadImage) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Upload to Firestore")
                        }
                    }
                    .disabled(isLoading)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLoading ? Color.gray : Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Results
                if let url = uploadedURL {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Upload Success!")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        Text("URL (Data URI):")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ScrollView(.horizontal) {
                            Text(url.absoluteString)
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Upload Test")
            .padding()
        }
    }
    
    private func uploadImage() {
        guard let data = selectedImageData else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let path = "test/image_\(UUID().uuidString).jpg"
                let url = try await storageService.uploadImage(data, path: path)
                uploadedURL = url
                isLoading = false
            } catch {
                errorMessage = "Upload failed: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

#Preview {
    ImageUploadTestView()
}
