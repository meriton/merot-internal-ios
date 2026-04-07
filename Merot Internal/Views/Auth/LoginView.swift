import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var userType: UserType = .admin

    enum UserType: String, CaseIterable {
        case admin = "admin"
        case employer = "employer"
        case employee = "employee"

        var label: String {
            switch self {
            case .admin: return "Admin"
            case .employer: return "Employer"
            case .employee: return "Employee"
            }
        }

        var icon: String {
            switch self {
            case .admin: return "shield.fill"
            case .employer: return "building.2.fill"
            case .employee: return "person.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            Color.brand.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                LogoView(height: 60)

                Text("Merot Internal")
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

                    // User type selector
                    HStack(spacing: 0) {
                        ForEach(UserType.allCases, id: \.self) { type in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { userType = type }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 14))
                                    Text(type.label)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(userType == type ? Color.brandGreen : Color.clear)
                                .foregroundColor(userType == type ? .white : .white.opacity(0.4))
                            }
                        }
                    }
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)

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
                        Task { await auth.login(email: email, password: password, userType: userType.rawValue) }
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
