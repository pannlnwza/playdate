import SwiftUI

struct SignupView: View {
    @Environment(AuthSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @FocusState private var focusedField: Field?

    private enum Field { case name, email, password }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.top, 8)

                Spacer().frame(height: 40)

                Text("Sign Up")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)

                Spacer().frame(height: 32)

                fields

                if let error = session.errorMessage {
                    Text(error)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.red)
                        .padding(.top, 12)
                }

                Spacer().frame(height: 24)

                primaryButton

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear { focusedField = .name }
    }

    private var topBar: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textLight)

            Spacer()
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 18) {
            labeledField("Name") {
                TextField("", text: $name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
                    .modifier(FlatFieldStyle())
            }

            labeledField("Email") {
                TextField("", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .modifier(FlatFieldStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                labeledField("Password") {
                    HStack(spacing: 12) {
                        ZStack {
                            TextField("", text: $password)
                                .textContentType(.newPassword)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .opacity(showPassword ? 1 : 0)
                            SecureField("", text: $password)
                                .textContentType(.newPassword)
                                .opacity(showPassword ? 0 : 1)
                        }
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(signUp)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMain)

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.textMuted)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 24)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 18)
                    .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Text("Must be at least 6 characters")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
                    .padding(.leading, 4)
            }
        }
    }

    @ViewBuilder
    private func labeledField<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textLight)
            content()
        }
    }

    private var primaryButton: some View {
        Button(action: signUp) {
            Group {
                if session.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Create Account")
                }
            }
            .font(.system(size: 17, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isValid ? Theme.primary : Theme.primary.opacity(0.4),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isValid || session.isLoading)
    }

    private func signUp() {
        guard isValid else { return }
        Task {
            await session.signUp(name: name, email: email, password: password)
            if session.errorMessage == nil {
                dismiss()
            }
        }
    }
}

private struct FlatFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.textMain)
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    SignupView()
        .environment(AuthSession())
}
