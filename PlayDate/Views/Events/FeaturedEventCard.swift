import SwiftUI

struct FeaturedEventCard: View {
    let event: Event
    @Environment(AuthSession.self) private var session
    @State private var participants: [Parent] = []

    private var familyCount: Int { max(event.participantIds.count, participants.count) }
    private var extras: Int { max(0, familyCount - participants.count) }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            background
            bottomGradient
            content
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
        .task(id: event.id) {
            await loadParticipants()
        }
    }

    @ViewBuilder
    private var background: some View {
        if let urlString = event.imageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholderBackground
                }
            }
        } else {
            placeholderBackground
        }
    }

    private var placeholderBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 102/255, green: 126/255, blue: 234/255),
                Color(red: 118/255, green: 75/255, blue: 162/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .trailing) {
            Image(systemName: categoryIcon)
                .font(.system(size: 90))
                .foregroundStyle(.white.opacity(0.18))
                .padding(.trailing, 30)
        }
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.2), .black.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(featuredLabel)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))

            Text(event.title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("\(event.location)  •  Ages \(event.minAge)-\(event.maxAge)  •  \(event.startTime)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            if familyCount > 0 {
                attendees
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }

    private var attendees: some View {
        HStack(spacing: -8) {
            ForEach(Array(participants.prefix(3).enumerated()), id: \.element.id) { _, parent in
                avatar(for: parent)
            }

            if extras > 0 {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Text("+\(extras)")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
            }

            Text("\(familyCount) \(familyCount == 1 ? "family" : "families") going")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.leading, 12)
        }
    }

    private func avatar(for parent: Parent) -> some View {
        Group {
            if let urlString = parent.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        avatarPlaceholder(seed: parent.id)
                    }
                }
            } else {
                avatarPlaceholder(seed: parent.id)
            }
        }
        .frame(width: 28, height: 28)
        .clipShape(Circle())
        .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
    }

    private func avatarPlaceholder(seed: String) -> some View {
        LinearGradient(
            colors: Theme.palette(for: seed),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "person.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private func loadParticipants() async {
        guard !event.participantIds.isEmpty else {
            participants = []
            return
        }
        let service: DataServiceProtocol = AppEnvironment.isPreview
            ? MockDataService()
            : FirestoreDataService(currentUserId: session.currentUser?.id)
        var loaded: [Parent] = []
        for id in event.participantIds.prefix(3) {
            if let parent = try? await service.loadParent(id: id) {
                loaded.append(parent)
            }
        }
        participants = loaded
    }

    private var featuredLabel: String {
        let calendar = Calendar.current
        let daysFromNow = calendar.dateComponents([.day], from: Date(), to: event.date).day ?? 0

        if daysFromNow <= 0 {
            return "TODAY"
        } else if daysFromNow == 1 {
            return "TOMORROW"
        } else if daysFromNow <= 7 {
            let weekday = event.date.formatted(.dateTime.weekday(.wide))
            return "THIS \(weekday.uppercased())"
        } else {
            return event.date.formatted(.dateTime.month(.abbreviated).day()).uppercased()
        }
    }

    private var categoryIcon: String {
        switch event.category {
        case .outdoors: return "leaf.fill"
        case .sports: return "soccerball"
        case .arts: return "paintpalette.fill"
        case .music: return "music.note"
        case .storytime: return "book.fill"
        }
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    return FeaturedEventCard(event: Event.mockEvents[0])
        .padding()
        .background(Theme.bg)
        .environment(s)
}
