import SwiftUI

struct LoginView: View {
    @Environment(AuthSession.self) private var session
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    logo
                        .padding(.top, 80)
                        .padding(.bottom, 60)

                    VStack(spacing: 14) {
                        AuthField(
                            placeholder: "Email",
                            text: $email,
                            keyboard: .emailAddress,
                            contentType: .emailAddress
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        AuthField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            contentType: .password
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit(signIn)
                    }
                    .padding(.horizontal, 24)

                    Button(action: signIn) {
                        Text("Sign In")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.brandGradient, in: Capsule())
                            .shadow(color: Theme.primary.opacity(0.3), radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    HStack(spacing: 4) {
                        Text("New to PlayDate?")
                            .foregroundStyle(Theme.textLight)
                        Button("Sign Up") { showSignup = true }
                            .foregroundStyle(Theme.primary)
                            .fontWeight(.heavy)
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .padding(.top, 20)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .sheet(isPresented: $showSignup) {
            SignupView()
        }
    }

    private var logo: some View {
        VStack(spacing: 12) {

            Text("PlayDate")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(Theme.brandGradient)

            Text("Find playmates for your kids")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textLight)
        }
    }

    private func signIn() {
        focusedField = nil
        session.signIn(email: email, password: password)
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
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthSession())
}
