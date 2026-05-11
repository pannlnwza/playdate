import SwiftUI

struct OnboardingView: View {
    @Environment(AuthSession.self) private var session

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "figure.2.and.child.holdinghands")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.primary)

                VStack(spacing: 8) {
                    Text("Welcome to PlayDate!")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.textMain)
                        .multilineTextAlignment(.center)

                    Text("Let's set up your account")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textLight)
                }

                VStack(alignment: .leading, spacing: 20) {
                    OnboardingBullet(
                        icon: "hand.thumbsup.fill",
                        iconColor: Theme.primary,
                        text: "Match with families nearby"
                    )
                    OnboardingBullet(
                        icon: "calendar",
                        iconColor: Theme.purple,
                        text: "Discover local events for kids"
                    )
                    OnboardingBullet(
                        icon: "message.fill",
                        iconColor: Theme.secondary,
                        text: "Chat safely with verified parents"
                    )
                }
                .padding(.horizontal, 36)
                .padding(.top, 8)

                Spacer()
                Spacer()
            }

            Button {
                session.dismissOnboarding()
            } label: {
                Text("Get Started")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.brandGradient, in: Capsule())
                    .shadow(color: Theme.primary.opacity(0.3), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .background(Theme.bg.ignoresSafeArea())
        .interactiveDismissDisabled()
    }
}

private struct OnboardingBullet: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.15), in: Circle())

            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textMain)

            Spacer()
        }
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    s.needsOnboarding = true
    return OnboardingView().environment(s)
}
