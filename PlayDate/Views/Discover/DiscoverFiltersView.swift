import SwiftUI

struct DiscoverFiltersView: View {
    @Environment(AuthSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: DiscoverViewModel

    @State private var events: [Event] = []
    @State private var isLoadingEvents = true

    private let hobbyOptions = [
        "Soccer", "Lego", "Art", "Music", "Dance",
        "Reading", "Outdoors", "Swimming", "Science", "Crafts",
        "Basketball", "Coding", "Books", "Animals", "Painting"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Age") {
                    Stepper("Minimum: \(viewModel.minAge)", value: $viewModel.minAge, in: 0...18)
                    Stepper("Maximum: \(viewModel.maxAge)", value: $viewModel.maxAge, in: viewModel.minAge...18)
                }

                Section("Hobbies") {
                    FlowLayout(spacing: 8) {
                        ForEach(hobbyOptions, id: \.self) { hobby in
                            FilterChip(
                                label: hobby,
                                isSelected: viewModel.selectedHobbies.contains(hobby)
                            ) {
                                toggle(hobby)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }

                Section("Going to event") {
                    if isLoadingEvents {
                        ProgressView()
                    } else if events.isEmpty {
                        Text("No upcoming events").foregroundStyle(.secondary)
                    } else {
                        Picker("Event", selection: $viewModel.eventFilterId) {
                            Text("Any").tag(String?.none)
                            ForEach(events) { event in
                                Text(event.title).tag(Optional(event.id))
                            }
                        }
                        .onChange(of: viewModel.eventFilterId) { _, newId in
                            if let event = events.first(where: { $0.id == newId }) {
                                viewModel.eventFilterParentIds = Set(event.participantIds)
                            } else {
                                viewModel.eventFilterParentIds = []
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") { viewModel.clearFilters() }
                        .disabled(!viewModel.hasActiveFilters)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.heavy)
                }
            }
            .task {
                let service: DataServiceProtocol = AppEnvironment.isPreview
                    ? MockDataService()
                    : FirestoreDataService(currentUserId: session.currentUser?.id)
                let fetched = (try? await service.fetchEvents()) ?? []
                events = fetched.filter { $0.dateTime >= Date() }.sorted { $0.dateTime < $1.dateTime }
                isLoadingEvents = false
            }
        }
    }

    private func toggle(_ hobby: String) {
        if viewModel.selectedHobbies.contains(hobby) {
            viewModel.selectedHobbies.remove(hobby)
        } else {
            viewModel.selectedHobbies.insert(hobby)
        }
    }
}

private struct FilterChip: View {
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
    return DiscoverFiltersView(viewModel: DiscoverViewModel()).environment(s)
}
