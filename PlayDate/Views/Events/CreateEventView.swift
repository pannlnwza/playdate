import SwiftUI
import PhotosUI
import MapKit

struct CreateEventView: View {
    @Environment(AuthSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    let onCreated: (Event) -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var locationName = ""
    @State private var pickedLatitude: Double?
    @State private var pickedLongitude: Double?
    @State private var locationSearch = LocationSearchService()
    @State private var dateTime: Date = Date().addingTimeInterval(60 * 60 * 24 * 3)
    @State private var endDateTime: Date = Date().addingTimeInterval(60 * 60 * 24 * 3 + 60 * 60 * 2)
    @State private var minAge: Int = 3
    @State private var maxAge: Int = 8
    @State private var category: EventCategory = .outdoors
    @State private var photoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        pickedLatitude != nil && pickedLongitude != nil &&
        endDateTime > dateTime &&
        minAge <= maxAge
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    coverPicker
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                } footer: {
                    Text("Add a cover photo so people know what to expect.")
                }

                Section("Basics") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Category", selection: $category) {
                        ForEach(EventCategory.allCases) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                }

                Section {
                    TextField("Search for a place", text: $locationName, prompt: Text("e.g. Central Park"))
                        .onChange(of: locationName) { _, newValue in
                            if pickedLatitude != nil { pickedLatitude = nil; pickedLongitude = nil }
                            locationSearch.query = newValue
                        }

                    if pickedLatitude != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.secondary)
                            Text("Location set")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.textLight)
                        }
                    } else {
                        ForEach(locationSearch.suggestions, id: \.self) { suggestion in
                            Button {
                                selectLocation(suggestion)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Theme.textMain)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Theme.textLight)
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("Location")
                } footer: {
                    if pickedLatitude == nil && !locationSearch.suggestions.isEmpty {
                        Text("Pick a suggestion to set the location.")
                    }
                }

                Section("When") {
                    DatePicker("Starts", selection: $dateTime)
                    DatePicker("Ends", selection: $endDateTime, in: dateTime...)
                }

                Section("Ages") {
                    Stepper("Minimum age: \(minAge)", value: $minAge, in: 0...18)
                    Stepper("Maximum age: \(maxAge)", value: $maxAge, in: minAge...18)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.cardBg)
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Create", action: save)
                            .fontWeight(.heavy)
                            .disabled(!isValid)
                    }
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

    @ViewBuilder
    private var coverPicker: some View {
        if let pickedImage {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: pickedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    self.pickedImage = nil
                    photoItem = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white, .black.opacity(0.55))
                }
                .buttonStyle(.plain)
                .padding(8)
            }
        } else {
            PhotosPicker(selection: $photoItem, matching: .images) {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 26, weight: .regular))
                    Text("Add cover photo")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Theme.textLight)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private func selectLocation(_ suggestion: MKLocalSearchCompletion) {
        Task {
            guard let result = await locationSearch.resolve(suggestion) else { return }
            locationName = result.1
            pickedLatitude = result.0.latitude
            pickedLongitude = result.0.longitude
            locationSearch.clear()
        }
    }

    private func save() {
        guard let userId = session.currentUser?.id,
              let lat = pickedLatitude, let lon = pickedLongitude else { return }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                var imageUrl: String?
                if let pickedImage,
                   let imageData = pickedImage.compressedJPEGUnderBudget(700_000) {
                    let storage: StorageServiceProtocol = AppEnvironment.isPreview
                        ? FirestoreStorageService()
                        : FirestoreStorageService()
                    let url = try await storage.uploadImage(imageData, path: "events/\(UUID().uuidString).jpg")
                    imageUrl = url.absoluteString
                }

                let event = Event(
                    title: title,
                    description: description,
                    locationName: locationName,
                    latitude: lat,
                    longitude: lon,
                    dateTime: dateTime,
                    organizerId: userId,
                    participantIds: [userId],
                    endDateTime: endDateTime,
                    minAge: minAge,
                    maxAge: maxAge,
                    category: category,
                    attendingFamilyCount: 1,
                    isFeatured: false,
                    imageUrl: imageUrl
                )

                let service: DataServiceProtocol = AppEnvironment.isPreview
                    ? MockDataService()
                    : FirestoreDataService(currentUserId: userId)
                try await service.createEvent(event)
                onCreated(event)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    return CreateEventView(onCreated: { _ in }).environment(s)
}
