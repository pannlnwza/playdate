import SwiftUI
import PhotosUI

struct AddChildView: View {
    @Environment(AuthSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var age = 4
    @State private var selectedHobbies: Set<String> = []
    @State private var photoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?

    private let hobbyOptions = [
        "Soccer", "Lego", "Art", "Music", "Dance",
        "Reading", "Outdoors", "Swimming", "Science", "Crafts"
    ]

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
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

                Section("Details") {
                    TextField("Child's name", text: $name)
                        .textContentType(.givenName)

                    Stepper(value: $age, in: 1...18) {
                        HStack {
                            Text("Age")
                            Spacer()
                            Text("\(age) years")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Hobbies & interests") {
                    FlowLayout(spacing: 8) {
                        ForEach(hobbyOptions, id: \.self) { hobby in
                            HobbyChip(
                                label: hobby,
                                isSelected: selectedHobbies.contains(hobby)
                            ) {
                                toggle(hobby)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", action: save)
                        .fontWeight(.heavy)
                        .disabled(!isValid)
                }
            }
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
                    if let image = pickedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        defaultAvatar
                    }
                }
                .frame(width: 88, height: 88)
                .clipShape(Circle())

                Circle()
                    .fill(Theme.brandGradient)
                    .frame(width: 28, height: 28)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .overlay { Circle().strokeBorder(Theme.bg, lineWidth: 3) }
            }
            .padding(.vertical, 8)
        }
    }

    private var defaultAvatar: some View {
        LinearGradient(
            colors: Theme.palette(for: name.isEmpty ? "new" : name),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "figure.child.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func toggle(_ hobby: String) {
        if selectedHobbies.contains(hobby) {
            selectedHobbies.remove(hobby)
        } else {
            selectedHobbies.insert(hobby)
        }
    }

    private func save() {
        let hobbies = hobbyOptions.filter { selectedHobbies.contains($0) }
        session.addChild(name: name, age: age, hobbies: hobbies, image: pickedImage)
        dismiss()
    }
}

private struct HobbyChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(isSelected ? .white : Theme.textLight)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule().fill(Theme.brandGradient)
                    } else {
                        Capsule().fill(Color.white)
                            .overlay {
                                Capsule().strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                            }
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let s = AuthSession()
    s.signIn(email: "x", password: "x")
    return AddChildView().environment(s)
}
