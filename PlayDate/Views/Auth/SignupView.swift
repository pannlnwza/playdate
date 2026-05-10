import SwiftUI

struct SignupView: View {
    @Environment(AuthSession.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field { case name, email, password }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        AuthField(placeholder: "Your name", text: $name, contentType: .name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }

                        AuthField(placeholder: "Email", text: $email, keyboard: .emailAddress, contentType: .emailAddress)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }

                        AuthField(placeholder: "Password (min. 6 characters)", text: $password, isSecure: true, contentType: .newPassword)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit(signUp)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Button(action: signUp) {
                        Text("Create Account")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? AnyShapeStyle(Theme.brandGradient) : AnyShapeStyle(Color.gray.opacity(0.4)), in: Capsule())
                            .shadow(color: isValid ? Theme.primary.opacity(0.3) : .clear, radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isValid)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { focusedField = .name }
        }
    }

    private func signUp() {
        guard isValid else { return }
        session.signUp(name: name, email: email, password: password)
        dismiss()
    }
}

#Preview {
    SignupView()
        .environment(AuthSession())
}
