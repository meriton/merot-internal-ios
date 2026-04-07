import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Color.brand.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                LogoView(height: 60)

                Text("Internal Admin")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(2)

                VStack(spacing: 16) {
                    if let error = auth.error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        TextField("", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        SecureField("", text: $password)
                            .textContentType(.password)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    Button {
                        Task { await auth.login(email: email, password: password) }
                    } label: {
                        Group {
                            if auth.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty || auth.isLoading)
                    .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                }
                .padding(24)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 24)

                Spacer()

                Text("internal.merot.com")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.bottom, 16)
            }
        }
    }
}
