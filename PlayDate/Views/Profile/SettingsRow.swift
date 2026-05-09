import SwiftUI

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let subtitle: String?
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.textMain)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textLight)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(16)
            .contentShape(Rectangle())

            if !isLast {
                Divider()
                    .padding(.leading, 70)
                    .opacity(0.5)
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsRow(
            icon: "person.crop.circle.fill",
            iconColor: .purple,
            iconBg: .purple.opacity(0.15),
            title: "Edit Profile",
            subtitle: "Update your info and photos",
            isLast: false
        )
        SettingsRow(
            icon: "rectangle.portrait.and.arrow.right",
            iconColor: .red,
            iconBg: .red.opacity(0.15),
            title: "Log Out",
            subtitle: nil,
            isLast: true
        )
    }
    .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 20))
    .padding()
    .background(Theme.bg)
}
