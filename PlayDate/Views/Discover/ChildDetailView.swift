import SwiftUI

struct ChildDetailView: View {
    let child: Child

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
    }

    private var hero: some View {
        LinearGradient(
            colors: Theme.palette(for: child.id),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 320)
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
                Circle()
                    .fill(LinearGradient(
                        colors: Theme.palette(for: child.parentName ?? child.parentId),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.8))
                    }

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
    NavigationStack {
        ChildDetailView(child: Child.mockChildren[0])
    }
}
