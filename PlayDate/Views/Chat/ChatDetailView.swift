import SwiftUI

struct ChatDetailView: View {
    let session: ChatSession
    @Environment(AuthSession.self) private var auth
    @State private var messages: [ChatMessage] = []
    @State private var draftText = ""
    @FocusState private var inputFocused: Bool

    private var currentUserId: String { auth.currentUser?.id ?? "user-current" }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        MessageBubble(
                            message: message,
                            isMine: message.senderId == currentUserId,
                            showsTail: showsTail(at: index)
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.bg)
            .onChange(of: messages.count) {
                guard let last = messages.last else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onAppear {
                messages = ChatMessage.mockMessages(for: session.id)
                if let last = messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            inputBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                principalTitle
            }
        }
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(Theme.primary)
    }

    private var principalTitle: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(LinearGradient(
                    colors: Theme.palette(for: session.id),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.75))
                }

            VStack(alignment: .leading, spacing: 0) {
                Text(session.parentName ?? "")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)
                if session.isOnline {
                    Text("Online")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 34/255, green: 197/255, blue: 94/255))
                } else if let context = session.childContext {
                    Text(context)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textLight)
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message", text: $draftText, axis: .vertical)
                .lineLimit(1...5)
                .focused($inputFocused)
                .font(.system(size: 16, design: .rounded))
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                }

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(canSend ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Color.gray.opacity(0.3)), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .animation(.snappy, value: canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var canSend: Bool {
        !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func send() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let message = ChatMessage(senderId: currentUserId, content: trimmed, timestamp: Date(), type: .text)
        messages.append(message)
        draftText = ""
    }

    private func showsTail(at index: Int) -> Bool {
        guard index < messages.count else { return false }
        let current = messages[index]
        let next = index + 1 < messages.count ? messages[index + 1] : nil
        return next?.senderId != current.senderId
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let isMine: Bool
    let showsTail: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isMine { Spacer(minLength: 60) }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(isMine ? .white : Theme.textMain)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background {
                        if isMine {
                            Theme.brandGradient
                        } else {
                            Color.white
                        }
                    }
                    .clipShape(BubbleShape(isMine: isMine, showsTail: showsTail))
                    .shadow(color: .black.opacity(isMine ? 0.0 : 0.05), radius: 4, y: 2)

                if showsTail {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                        .padding(.horizontal, 6)
                }
            }

            if !isMine { Spacer(minLength: 60) }
        }
    }
}

private struct BubbleShape: Shape {
    let isMine: Bool
    let showsTail: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        let small: CGFloat = showsTail ? 6 : 18

        let topLeft: CGFloat = radius
        let topRight: CGFloat = radius
        let bottomLeft: CGFloat = isMine ? radius : small
        let bottomRight: CGFloat = isMine ? small : radius

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
                    radius: topRight, startAngle: .degrees(-90), endAngle: .zero, clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                    radius: bottomRight, startAngle: .zero, endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                    radius: bottomLeft, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                    radius: topLeft, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        return path
    }
}

#Preview {
    NavigationStack {
        ChatDetailView(session: ChatSession.mockSessions[0])
            .environment({ let s = AuthSession(); s.signIn(email: "x", password: "x"); return s }())
    }
}
