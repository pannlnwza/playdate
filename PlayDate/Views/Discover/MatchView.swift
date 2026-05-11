import SwiftUI

struct MatchView: View {
    let child: Child
    let ownChild: Child?
    var onSendMessage: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @State private var iconPulse: Bool = false

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [Theme.primary.opacity(0.25), .black.opacity(0.85)],
                center: .center,
                startRadius: 80,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                title
                avatars
                actions

                Spacer()
            }
            .padding(36)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                iconPulse = true
            }
        }
    }

    private var title: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("It's a ")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("PlayDate!")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accent, Theme.orange, Theme.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Text("\(child.name) and your child both want to play together!")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var avatars: some View {
        HStack(spacing: -16) {
            avatar(
                name: ownChild?.name ?? "Your child",
                imageUrl: ownChild?.imageUrls.first,
                paletteSeed: ownChild?.id ?? "own"
            )

            Image(systemName: "party.popper.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [Theme.accent, Theme.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )
                .overlay { Circle().strokeBorder(.white.opacity(0.9), lineWidth: 3) }
                .shadow(color: Theme.accent.opacity(0.5), radius: 16, y: 4)
                .scaleEffect(iconPulse ? 1.15 : 1.0)
                .zIndex(1)

            avatar(
                name: child.name,
                imageUrl: child.imageUrls.first,
                paletteSeed: child.id
            )
        }
    }

    private func avatar(name: String, imageUrl: String?, paletteSeed: String) -> some View {
        ZStack(alignment: .bottom) {
            Group {
                if let urlString = imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            placeholder(seed: paletteSeed)
                        }
                    }
                } else {
                    placeholder(seed: paletteSeed)
                }
            }
            .frame(width: 110, height: 110)
            .clipShape(Circle())
            .overlay { Circle().strokeBorder(.white.opacity(0.9), lineWidth: 4) }
            .shadow(color: .black.opacity(0.3), radius: 16, y: 8)

            Text(name)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .offset(y: 24)
        }
    }

    private func placeholder(seed: String) -> some View {
        LinearGradient(
            colors: Theme.palette(for: seed),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "person.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                onSendMessage()
            } label: {
                Text("Send a Message")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.primary, in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                dismiss()
            } label: {
                Text("Keep Swiping")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white.opacity(0.1), in: Capsule())
                    .overlay { Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1.5) }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MatchView(child: Child.mockChildren[0], ownChild: Parent.mockOwnChildren[0])
}
