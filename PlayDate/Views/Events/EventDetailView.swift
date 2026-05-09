import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    @State private var isJoined = false

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
    }

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
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 102/255, green: 126/255, blue: 234/255),
                    Color(red: 118/255, green: 75/255, blue: 162/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 240)
            .overlay(alignment: .center) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 110))
                    .foregroundStyle(.white.opacity(0.25))
            }

            if event.isFeatured {
                Text("FEATURED")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    .padding(20)
            }
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
            InfoRow(
                icon: "calendar",
                iconColor: Color(red: 99/255, green: 102/255, blue: 241/255),
                title: "Date",
                value: event.dateTime.formatted(date: .complete, time: .omitted)
            )
            InfoRow(
                icon: "clock.fill",
                iconColor: Color(red: 245/255, green: 158/255, blue: 11/255),
                title: "Time",
                value: "\(event.startTime) – \(event.endTime)"
            )
            InfoRow(
                icon: "figure.2.and.child.holdinghands",
                iconColor: Color(red: 16/255, green: 185/255, blue: 129/255),
                title: "Ages",
                value: "\(event.minAge)–\(event.maxAge) years"
            )
            InfoRow(
                icon: "person.3.fill",
                iconColor: Theme.primary,
                title: "Attending",
                value: "\(event.attendingFamilyCount) families"
            )
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
            withAnimation(.snappy) { isJoined.toggle() }
        } label: {
            HStack(spacing: 8) {
                if isJoined {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .heavy))
                }
                Text(isJoined ? "Going" : "Join Event")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isJoined ? AnyShapeStyle(Theme.likeGradient) : AnyShapeStyle(Theme.brandGradient), in: Capsule())
            .shadow(color: (isJoined ? Theme.secondary : Theme.primary).opacity(0.35), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
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
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

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
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: Event.mockEvents[0])
    }
}
