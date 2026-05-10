import SwiftUI

struct ChildDetailView: View {
    let child: Child
    var chatSession: ChatSession? = nil
    @Environment(AuthSession.self) private var session
    @State private var photoIndex: Int = 0
    @State private var eventsViewModel = EventsViewModel()

    private var photoCount: Int { max(child.imageUrls.count, 1) }
    private var hasPhotos: Bool { !child.imageUrls.isEmpty }
    private var parentEvents: [Event] { eventsViewModel.upcomingEvents(joinedBy: child.parentId) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                VStack(alignment: .leading, spacing: 24) {
                    nameAge
                    if let bio = child.bio, !bio.isEmpty {
                        bioSection(bio)
                    }
                    interestsSection
                    parentSection
                    if !parentEvents.isEmpty {
                        upcomingEventsSection
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
        .background(Theme.bg)
        .navigationTitle(child.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            if let chatSession {
                NavigationLink {
                    ChatDetailView(session: chatSession)
                } label: {
                    Text("Start Chatting")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.primary, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)
            }
        }
        .task {
            let service: DataServiceProtocol = AppEnvironment.isPreview
                ? MockDataService()
                : FirestoreDataService(currentUserId: session.currentUser?.id)
            eventsViewModel.attach(service: service, userId: session.currentUser?.id)
            await eventsViewModel.load()
        }
    }

    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Going to")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            VStack(spacing: 12) {
                ForEach(parentEvents) { event in
                    NavigationLink {
                        EventDetailView(
                            event: event,
                            isJoined: eventsViewModel.isJoined(event),
                            onToggleJoin: { eventsViewModel.toggleJoin(event) }
                        )
                    } label: {
                        EventCard(
                            event: event,
                            isJoined: eventsViewModel.isJoined(event),
                            onJoin: { eventsViewModel.toggleJoin(event) }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var hero: some View {
        if hasPhotos {
            ZStack(alignment: .bottom) {
                TabView(selection: $photoIndex) {
                    ForEach(Array(child.imageUrls.enumerated()), id: \.offset) { index, urlString in
                        AsyncImage(url: URL(string: urlString)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .empty:
                                placeholderHero.overlay { ProgressView().tint(.white) }
                            case .failure:
                                placeholderHero
                            @unknown default:
                                placeholderHero
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 320)
                .clipped()

                if photoCount > 1 {
                    HStack(spacing: 4) {
                        ForEach(0..<photoCount, id: \.self) { i in
                            Capsule()
                                .fill(i == photoIndex ? Color.white : Color.white.opacity(0.5))
                                .frame(width: i == photoIndex ? 24 : 16, height: 4)
                                .animation(.easeInOut(duration: 0.2), value: photoIndex)
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
        } else {
            placeholderHero.frame(height: 320)
        }
    }

    private var parentAvatarPlaceholder: some View {
        LinearGradient(
            colors: Theme.palette(for: child.parentName ?? child.parentId),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "person.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var placeholderHero: some View {
        LinearGradient(
            colors: Theme.palette(for: child.id),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "figure.child.circle.fill")
                .font(.system(size: 140))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var nameAge: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(child.name), \(child.age)")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            if let distance = child.distanceKm {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11, weight: .bold))
                    Text(String(format: "%.1f km away", distance))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Theme.textLight)
            }
        }
    }

    private func bioSection(_ bio: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            Text(bio)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.textLight)
                .lineSpacing(4)
        }
    }

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interests")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            FlowLayout(spacing: 8) {
                ForEach(child.interests, id: \.self) { interest in
                    Text(interest)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Theme.brandGradient, in: Capsule())
                }
            }
        }
    }

    private var parentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parent")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            HStack(spacing: 12) {
                Group {
                    if let urlString = child.parentImageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                parentAvatarPlaceholder
                            }
                        }
                    } else {
                        parentAvatarPlaceholder
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(child.parentName ?? "")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.textMain)

                        if child.parentVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.blue)
                        }
                    }

                    Text(child.parentVerified ? "Verified parent" : "Parent")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textLight)
                }

                Spacer()
            }
            .padding(14)
            .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    return NavigationStack {
        ChildDetailView(child: Child.mockChildren[0])
            .environment(s)
    }
}
