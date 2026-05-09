import SwiftUI

struct MatchView: View {
    let child: Child
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
            avatar(name: "Lily", colors: [Theme.purple, Theme.blue])

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

            avatar(name: child.name, colors: Theme.palette(for: child.id))
        }
    }

    private func avatar(name: String, colors: [Color]) -> some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 110, height: 110)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .overlay { Circle().strokeBorder(.white.opacity(0.9), lineWidth: 4) }
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)

            Text(name)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .offset(y: 24)
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Text("Send a Message")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.brandGradient, in: Capsule())
                    .shadow(color: Theme.primary.opacity(0.4), radius: 16, y: 6)
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
    MatchView(child: Child.mockChildren[0])
}
