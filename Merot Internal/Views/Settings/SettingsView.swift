import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showEditProfile = false
    @State private var showChangePassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Profile card
                if let user = auth.user {
                    CardView {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Text(user.initials)
                                        .font(.title2).bold()
                                        .foregroundColor(.accent)
                                )
                            Text(user.displayName)
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                            if let roles = user.roles, !roles.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(roles, id: \.self) { role in
                                        Text(role.capitalized)
                                            .font(.caption2).bold()
                                            .foregroundColor(.accent)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.accent.opacity(0.15))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Details
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Profile Details").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "envelope.fill", label: "Email", value: user.email)
                            InfoRow(icon: "phone.fill", label: "Phone", value: user.phone_number ?? "-")
                            if let dept = user.department {
                                InfoRow(icon: "building.2.fill", label: "Department", value: dept)
                            }
                            InfoRow(icon: "person.badge.shield.checkmark", label: "Super Admin", value: user.super_admin == true ? "Yes" : "No")
                        }
                    }
                }

                // Actions
                CardView {
                    VStack(spacing: 10) {
                        Button { showEditProfile = true } label: {
                            HStack { Image(systemName: "pencil"); Text("Edit Profile") }
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(10)
                        }

                        Button { showChangePassword = true } label: {
                            HStack { Image(systemName: "lock.rotation"); Text("Change Password") }
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange.opacity(0.8))
                                .cornerRadius(10)
                        }

                        Button { auth.logout() } label: {
                            HStack { Image(systemName: "rectangle.portrait.and.arrow.right"); Text("Logout") }
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                }

                // App info
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("App Info").font(.headline).foregroundColor(.white.opacity(0.7))
                        InfoRow(icon: "info.circle", label: "Version", value: "2.0.0")
                        InfoRow(icon: "globe", label: "API", value: "internal.merot.com")
                        InfoRow(icon: "building.2", label: "Platform", value: "Merot Internal")
                    }
                }
            }
            .padding()
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Settings")
        .brandNavBar()
        .sheet(isPresented: $showEditProfile) { editProfileSheet }
        .sheet(isPresented: $showChangePassword) { changePasswordSheet }
    }

    // MARK: - Edit Profile Sheet

    private var editProfileSheet: some View {
        EditProfileSheet(isPresented: $showEditProfile)
    }

    // MARK: - Change Password Sheet

    private var changePasswordSheet: some View {
        ChangePasswordSheet(isPresented: $showChangePassword)
    }
}

struct EditProfileSheet: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var isPresented: Bool
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var saving = false
    @State private var error: String?
    @State private var success = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    editField("First Name", text: $firstName, icon: "person.fill")
                    editField("Last Name", text: $lastName, icon: "person.fill")
                    editField("Phone Number", text: $phoneNumber, icon: "phone.fill", keyboard: .phonePad)

                    if let err = error {
                        Text(err).font(.caption).foregroundColor(.red)
                    }
                    if success {
                        Text("Profile updated").font(.caption).foregroundColor(.green)
                    }

                    Button {
                        saving = true
                        Task {
                            let result = await auth.updateProfile(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
                            saving = false
                            if result {
                                success = true
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                isPresented = false
                            } else {
                                error = auth.error
                            }
                        }
                    } label: {
                        HStack {
                            if saving { ProgressView().tint(.white) }
                            else { Text("Save").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(saving)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }.foregroundColor(.white)
                }
            }
            .onAppear {
                firstName = auth.user?.first_name ?? ""
                lastName = auth.user?.last_name ?? ""
                phoneNumber = auth.user?.phone_number ?? ""
            }
        }
    }

    private func editField(_ label: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundColor(.white.opacity(0.5))
            HStack(spacing: 8) {
                Image(systemName: icon).font(.caption).foregroundColor(.white.opacity(0.3)).frame(width: 20)
                TextField("", text: text)
                    .foregroundColor(.white)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding(12).background(Color.white.opacity(0.08)).cornerRadius(10)
        }
    }
}

struct ChangePasswordSheet: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var isPresented: Bool
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var saving = false
    @State private var error: String?
    @State private var success = false

    var passwordsMatch: Bool { !newPassword.isEmpty && newPassword == confirmPassword }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("New Password").font(.caption).foregroundColor(.white.opacity(0.5))
                        SecureField("", text: $newPassword)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password").font(.caption).foregroundColor(.white.opacity(0.5))
                        SecureField("", text: $confirmPassword)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }

                    if !newPassword.isEmpty && !confirmPassword.isEmpty && !passwordsMatch {
                        Text("Passwords do not match").font(.caption).foregroundColor(.red)
                    }
                    if newPassword.count > 0 && newPassword.count < 6 {
                        Text("Password must be at least 6 characters").font(.caption).foregroundColor(.orange)
                    }
                    if let err = error {
                        Text(err).font(.caption).foregroundColor(.red)
                    }
                    if success {
                        Text("Password changed successfully").font(.caption).foregroundColor(.green)
                    }

                    Button {
                        saving = true
                        Task {
                            let result = await auth.changePassword(current: "", newPassword: newPassword, confirmation: confirmPassword)
                            saving = false
                            if result {
                                success = true
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                isPresented = false
                            } else {
                                error = auth.error
                            }
                        }
                    } label: {
                        HStack {
                            if saving { ProgressView().tint(.white) }
                            else { Text("Change Password").fontWeight(.semibold) }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(passwordsMatch && newPassword.count >= 6 ? Color.brandGreen : Color.brandGreen.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(saving || !passwordsMatch || newPassword.count < 6)
                }
                .padding()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }.foregroundColor(.white)
                }
            }
        }
    }
}
