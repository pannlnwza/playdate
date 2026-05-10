import SwiftUI
import PhotosUI

struct AddChildView: View {
    @Environment(AuthSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    let editing: Child?

    init(editing: Child? = nil) {
        self.editing = editing
    }

    private var isEditing: Bool { editing != nil }

    @State private var name = ""
    @State private var age = 4
    @State private var bio = ""
    @State private var selectedHobbies: Set<String> = []
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var pickedImages: [UIImage] = []
    @State private var keptImageUrls: [String] = []
    @State private var showDeleteConfirm = false

    private let maxImages = 5
    private let hobbyOptions = [
        "Soccer", "Lego", "Art", "Music", "Dance",
        "Reading", "Outdoors", "Swimming", "Science", "Crafts"
    ]

    private var totalPhotoCount: Int { keptImageUrls.count + pickedImages.count }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    galleryPicker
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } footer: {
                    Text("Add up to \(maxImages) photos. The first one is the main photo.")
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

                    TextField("About", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
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

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Child")
                                    .fontWeight(.heavy)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.cardBg)
            .navigationTitle(isEditing ? "Edit Child" : "Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if session.isLoading {
                        ProgressView()
                    } else {
                        Button(isEditing ? "Save" : "Add", action: save)
                            .fontWeight(.heavy)
                            .disabled(!isValid)
                    }
                }
            }
            .onAppear(perform: loadEditingState)
            .onChange(of: photoItems) { _, newItems in
                Task { await loadPickedImages(from: newItems) }
            }
            .confirmationDialog(
                "Delete \(name)?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive, action: delete)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes this child profile.")
            }
        }
    }

    private var galleryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(keptImageUrls.enumerated()), id: \.offset) { index, url in
                    existingThumbnail(url: url, slotIndex: index)
                }
                ForEach(Array(pickedImages.enumerated()), id: \.offset) { index, image in
                    pickedThumbnail(image: image, slotIndex: keptImageUrls.count + index, pickedIndex: index)
                }
                if totalPhotoCount < maxImages {
                    addPhotoTile
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func existingThumbnail(url: String, slotIndex: Int) -> some View {
        Color.gray.opacity(0.15)
            .frame(width: 110, height: 147)
            .overlay {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Color.clear
                    }
                }
                .frame(width: 110, height: 147)
                .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(alignment: .topLeading) {
                if slotIndex == 0 { mainBadge }
            }
            .overlay(alignment: .topTrailing) {
                removeButton { keptImageUrls.remove(at: slotIndex) }
            }
    }

    private func pickedThumbnail(image: UIImage, slotIndex: Int, pickedIndex: Int) -> some View {
        Color.gray.opacity(0.15)
            .frame(width: 110, height: 147)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 147)
                    .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(alignment: .topLeading) {
                if slotIndex == 0 { mainBadge }
            }
            .overlay(alignment: .topTrailing) {
                removeButton {
                    pickedImages.remove(at: pickedIndex)
                    if photoItems.indices.contains(pickedIndex) {
                        photoItems.remove(at: pickedIndex)
                    }
                }
            }
    }

    private var mainBadge: some View {
        Text("MAIN")
            .font(.system(size: 9, weight: .heavy, design: .rounded))
            .tracking(1)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Theme.primary, in: Capsule())
            .padding(6)
    }

    private func removeButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white, .black.opacity(0.55))
        }
        .buttonStyle(.plain)
        .padding(4)
    }

    private var addPhotoTile: some View {
        PhotosPicker(
            selection: $photoItems,
            maxSelectionCount: maxImages - keptImageUrls.count,
            matching: .images
        ) {
            VStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .regular))
                Text("Add")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Theme.textLight)
            .frame(width: 110, height: 147)
            .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func loadEditingState() {
        guard let editing else { return }
        name = editing.name
        age = editing.age
        bio = editing.bio ?? ""
        selectedHobbies = Set(editing.hobbies)
        keptImageUrls = editing.imageUrls
    }

    private func loadPickedImages(from items: [PhotosPickerItem]) async {
        let availableSlots = max(0, maxImages - keptImageUrls.count)
        var images: [UIImage] = []
        for item in items.prefix(availableSlots) {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        pickedImages = images
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
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let bioToSave = trimmedBio.isEmpty ? nil : trimmedBio
        Task {
            if let editing {
                await session.updateChild(
                    editing,
                    name: name,
                    age: age,
                    bio: bioToSave,
                    hobbies: hobbies,
                    newImages: pickedImages,
                    keptImageUrls: keptImageUrls
                )
            } else {
                await session.addChild(name: name, age: age, bio: bioToSave, hobbies: hobbies, images: pickedImages)
            }
            if session.errorMessage == nil {
                dismiss()
            }
        }
    }

    private func delete() {
        guard let editing else { return }
        Task {
            await session.deleteChild(editing)
            if session.errorMessage == nil {
                dismiss()
            }
        }
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
    s.currentUser = .mockCurrentUser
    s.ownChildren = Parent.mockOwnChildren
    return AddChildView().environment(s)
}
