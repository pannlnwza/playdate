import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(spacing: 20) {
                            profileHero
                            statsRow
                            childrenSection
                            settingsSection
                        }
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textMain)

            Spacer()

            Button {
                // settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.textMain)
                    .frame(width: 42, height: 42)
                    .glassEffect(.regular.interactive(), in: Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var profileHero: some View {
        VStack(spacing: 0) {
            cover
                .padding(.horizontal, 20)
                .overlay(alignment: .bottom) {
                    avatar.offset(y: 44)
                }
                .padding(.bottom, 44)

            Text(viewModel.profile.name)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)
                .padding(.top, 12)

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 11, weight: .bold))
                Text(viewModel.profile.location)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Theme.textLight)
            .padding(.top, 2)

            if viewModel.profile.isVerified {
                verifiedBadge
                    .padding(.top, 8)
            }
        }
    }

    private var cover: some View {
        LinearGradient(
            colors: [Theme.primary, Theme.purple, Theme.secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 120)
        .overlay {
            RadialGradient(
                colors: [.white.opacity(0.15), .clear],
                center: UnitPoint(x: 0.3, y: 0.5),
                startRadius: 0,
                endRadius: 120
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var avatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: Theme.palette(for: viewModel.profile.id),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 88, height: 88)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .overlay { Circle().strokeBorder(Theme.bg, lineWidth: 4) }
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private var verifiedBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12, weight: .bold))
            Text("Verified Parent")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(Color(red: 59/255, green: 130/255, blue: 246/255))
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color(red: 239/255, green: 246/255, blue: 1.0), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(viewModel.profile.matchesCount)", label: "MATCHES")
            divider
            statItem(value: "\(viewModel.profile.playdatesCount)", label: "PLAYDATES")
            divider
            statItem(value: String(format: "%.1f", viewModel.profile.rating), label: "RATING")
        }
        .padding(.vertical, 8)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textMain)
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.textMuted.opacity(0.25))
            .frame(width: 1, height: 32)
    }

    private var childrenSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Children")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)

                Spacer()

                Button {
                    // add child
                } label: {
                    Text("+ Add Child")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.profile.children) { child in
                        ChildSummaryCard(child: child)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 12) {
            settingsGroup {
                SettingsRow(
                    icon: "person.crop.circle.fill",
                    iconColor: Color(red: 139/255, green: 92/255, blue: 246/255),
                    iconBg: Color(red: 237/255, green: 233/255, blue: 254/255),
                    title: "Edit Profile",
                    subtitle: "Update your info and photos",
                    isLast: false
                )
                SettingsRow(
                    icon: "lock.shield.fill",
                    iconColor: Color(red: 16/255, green: 185/255, blue: 129/255),
                    iconBg: Color(red: 209/255, green: 250/255, blue: 229/255),
                    title: "Privacy & Safety",
                    subtitle: "Manage your safety preferences",
                    isLast: false
                )
                SettingsRow(
                    icon: "bell.fill",
                    iconColor: Color(red: 239/255, green: 68/255, blue: 68/255),
                    iconBg: Color(red: 254/255, green: 226/255, blue: 226/255),
                    title: "Notifications",
                    subtitle: "Match alerts, messages, events",
                    isLast: true
                )
            }

            settingsGroup {
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    iconColor: Color(red: 59/255, green: 130/255, blue: 246/255),
                    iconBg: Color(red: 219/255, green: 234/255, blue: 254/255),
                    title: "Help & Support",
                    subtitle: "FAQs, contact us, report",
                    isLast: false
                )
                SettingsRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    iconColor: Color(red: 245/255, green: 158/255, blue: 11/255),
                    iconBg: Color(red: 254/255, green: 243/255, blue: 199/255),
                    title: "Log Out",
                    subtitle: nil,
                    isLast: true
                )
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func settingsGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    ProfileView()
}
