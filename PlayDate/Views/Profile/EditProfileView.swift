import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(AuthSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var pickedLatitude: Double?
    @State private var pickedLongitude: Double?
    @State private var isLocating = false
    @State private var locationError: String?
    @State private var locationService = LocationService()

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var displayImage: UIImage? {
        pickedImage ?? session.profileImage
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        avatarPicker
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section("About you") {
                    TextField("Name", text: $name)
                        .textContentType(.name)

                    TextField("Location", text: $location, prompt: Text("e.g. Brooklyn, NY"))
                        .textContentType(.addressCity)

                    Button(action: useCurrentLocation) {
                        HStack {
                            if isLocating {
                                ProgressView()
                            } else {
                                Image(systemName: "location.fill")
                            }
                            Text(isLocating ? "Locating…" : "Use my current location")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .disabled(isLocating)

                    if let locationError {
                        Text(locationError)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.red)
                    }

                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.cardBg)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if session.isLoading {
                        ProgressView()
                    } else {
                        Button("Save", action: save)
                            .fontWeight(.heavy)
                            .disabled(!isValid)
                    }
                }
            }
            .onAppear(perform: load)
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        pickedImage = image
                    }
                }
            }
        }
    }

    private var avatarPicker: some View {
        VStack(spacing: 10) {
            Group {
                if let image = displayImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let urlString = session.currentUser?.profileImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            defaultAvatar
                        }
                    }
                } else {
                    defaultAvatar
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())

            PhotosPicker(selection: $photoItem, matching: .images) {
                Text(displayImage == nil && session.currentUser?.profileImageUrl == nil ? "Add Photo" : "Change Photo")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.primary)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }

    private var defaultAvatar: some View {
        LinearGradient(
            colors: Theme.palette(for: session.currentUser?.id ?? "u"),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "person.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func load() {
        guard let user = session.currentUser else { return }
        name = user.name
        location = user.location ?? ""
        bio = user.bio ?? ""
    }

    private func useCurrentLocation() {
        locationError = nil
        isLocating = true
        Task {
            do {
                let coord = try await locationService.requestCurrentLocation()
                pickedLatitude = coord.coordinate.latitude
                pickedLongitude = coord.coordinate.longitude
                if let placeName = await locationService.reverseGeocode(coord) {
                    location = placeName
                }
            } catch {
                locationError = error.localizedDescription
            }
            isLocating = false
        }
    }

    private func save() {
        Task {
            await session.updateProfile(
                name: name,
                location: location,
                bio: bio,
                latitude: pickedLatitude,
                longitude: pickedLongitude,
                image: pickedImage
            )
            if session.errorMessage == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    s.ownChildren = Parent.mockOwnChildren
    return EditProfileView().environment(s)
}
