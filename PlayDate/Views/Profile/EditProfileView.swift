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

                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .fontWeight(.heavy)
                        .disabled(!isValid)
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
        PhotosPicker(selection: $photoItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image = displayImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        defaultAvatar
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay { Circle().strokeBorder(.white, lineWidth: 4) }
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

                Circle()
                    .fill(Theme.brandGradient)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .overlay { Circle().strokeBorder(Theme.bg, lineWidth: 3) }
            }
            .padding(.vertical, 8)
        }
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

    private func save() {
        session.updateProfile(name: name, location: location, bio: bio, image: pickedImage)
        dismiss()
    }
}

#Preview {
    let s = AuthSession()
    s.signIn(email: "x", password: "x")
    return EditProfileView().environment(s)
}
