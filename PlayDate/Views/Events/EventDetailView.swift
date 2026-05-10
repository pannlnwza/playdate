import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    let isJoined: Bool
    let onToggleJoin: () -> Void

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
    }

    private var isPast: Bool { event.dateTime < Date() }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    infoCards
                    aboutSection
                    mapSection
                }
                .padding(20)
                .padding(.bottom, 80)
            }
        }
        .scrollIndicators(.hidden)
        .background(Theme.bg)
        .safeAreaInset(edge: .bottom) {
            joinButton
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var hero: some View {
        heroBackground
            .frame(height: 240)
            .clipped()
    }

    @ViewBuilder
    private var heroBackground: some View {
        if let urlString = event.imageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholderHero
                }
            }
        } else {
            placeholderHero
        }
    }

    private var placeholderHero: some View {
        LinearGradient(
            colors: [
                Color(red: 102/255, green: 126/255, blue: 234/255),
                Color(red: 118/255, green: 75/255, blue: 162/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .center) {
            Image(systemName: categoryIcon)
                .font(.system(size: 110))
                .foregroundStyle(.white.opacity(0.25))
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 11, weight: .bold))
                Text(event.locationName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Theme.textLight)
        }
    }

    private var infoCards: some View {
        VStack(spacing: 10) {
            InfoRow(icon: "calendar", title: "Date",
                    value: event.dateTime.formatted(date: .complete, time: .omitted))
            InfoRow(icon: "clock", title: "Time",
                    value: "\(event.startTime) – \(event.endTime)")
            InfoRow(icon: "figure.2.and.child.holdinghands", title: "Ages",
                    value: "\(event.minAge)–\(event.maxAge) years")
            InfoRow(icon: "person.3", title: "Attending",
                    value: "\(event.participantIds.count) \(event.participantIds.count == 1 ? "family" : "families")")
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            Text(event.description)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.textLight)
                .lineSpacing(4)
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 600,
                longitudinalMeters: 600
            ))) {
                Marker(event.title, coordinate: coordinate)
                    .tint(Theme.primary)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .allowsHitTesting(false)
        }
    }

    private var joinButton: some View {
        Button {
            withAnimation(.snappy) { onToggleJoin() }
        } label: {
            HStack(spacing: 8) {
                if isJoined && !isPast {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .heavy))
                }
                Text(isPast ? "Event ended" : (isJoined ? "Going" : "Join Event"))
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isPast ? Color.gray.opacity(0.5) : (isJoined ? Theme.secondary : Theme.primary),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .disabled(isPast)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
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

private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.textLight)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Theme.textMuted)
                Text(value)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)
            }

            Spacer()
        }
        .padding(14)
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: Event.mockEvents[0], isJoined: false, onToggleJoin: {})
    }
}
