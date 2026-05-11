import SwiftUI

struct LoginView: View {
    @Environment(AuthSession.self) private var session
    @State private var step: Step = .email
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var showPassword = false
    @FocusState private var focusedField: Field?

    private enum Step { case email, password }
    private enum Field { case email, password }

    private var emailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        return trimmed.contains("@") && trimmed.count >= 5
    }

    private var passwordValid: Bool {
        password.count >= 6
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.top, 8)

                Spacer().frame(height: 64)

                Text("Sign In")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)

                Spacer().frame(height: 40)

                fieldSection

                Spacer().frame(height: 24)

                primaryButton

                if step == .password {
                    backButton
                        .padding(.top, 12)
                }

                Spacer()

                if step == .email {
                    signupPrompt
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $showSignup) {
            SignupView()
        }
        .onAppear { focusedField = .email }
    }

    private var topBar: some View {
        HStack {
            Text("PlayDate")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(Theme.brandGradient)

            Spacer()
        }
    }

    @ViewBuilder
    private var fieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(step == .email ? "Email" : "Password")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textLight)

            switch step {
            case .email:
                emailField
            case .password:
                passwordField
            }

            if let error = session.errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)
                    .padding(.top, 4)
            }
        }
    }

    private var emailField: some View {
        TextField("", text: $email)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textContentType(.emailAddress)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { advance() }
            .font(.system(size: 17, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.textMain)
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var passwordField: some View {
        HStack(spacing: 12) {
            ZStack {
                TextField("", text: $password)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .opacity(showPassword ? 1 : 0)
                SecureField("", text: $password)
                    .textContentType(.password)
                    .opacity(showPassword ? 0 : 1)
            }
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit(signIn)
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

    private var primaryButton: some View {
        let enabled = step == .email ? emailValid : passwordValid
        return Button {
            if step == .email { advance() } else { signIn() }
        } label: {
            Group {
                if session.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(step == .email ? "Next" : "Sign In")
                }
            }
            .font(.system(size: 17, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(enabled ? Theme.primary : Theme.primary.opacity(0.4),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!enabled || session.isLoading)
    }

    private var backButton: some View {
        Button {
            withAnimation(.snappy) {
                step = .email
                session.errorMessage = nil
                focusedField = .email
            }
        } label: {
            Text("Back")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textMain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var signupPrompt: some View {
        Button {
            showSignup = true
        } label: {
            HStack(spacing: 6) {
                Text("New to PlayDate?")
                    .foregroundStyle(Theme.textLight)
                Text("Sign Up")
                    .foregroundStyle(Theme.primary)
                    .fontWeight(.heavy)
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .buttonStyle(.plain)
    }

    private func advance() {
        guard emailValid else { return }
        focusedField = nil
        session.errorMessage = nil
        withAnimation(.snappy) {
            step = .password
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            focusedField = .password
        }
    }

    private func signIn() {
        focusedField = nil
        Task { await session.signIn(email: email, password: password) }
    }
}

struct AuthField: View {
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var contentType: UITextContentType? = nil

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled(keyboard == .emailAddress)
            }
        }
        .textContentType(contentType)
        .font(.system(size: 16, weight: .medium, design: .rounded))
        .foregroundStyle(Theme.textMain)
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.black.opacity(0.15), lineWidth: 1)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthSession())
}
