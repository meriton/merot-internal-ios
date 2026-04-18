import SwiftUI

struct EmployeeProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var profile: EmpProfile?
    @State private var isLoading = true
    @State private var showEditProfile = false
    @State private var showChangePassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading && profile == nil {
                    LoadingView()
                } else {
                    VStack(spacing: 16) {
                        // Profile Card
                        CardView {
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 64, height: 64)
                                    .overlay(
                                        Text(initials)
                                            .font(.title2).bold()
                                            .foregroundColor(.accent)
                                    )
                                Text(profile?.full_name ?? auth.user?.displayName ?? "")
                                    .font(.title3).bold().foregroundColor(.white)
                                Text(profile?.title ?? "")
                                    .font(.subheadline).foregroundColor(.accent)
                                if let emp = profile?.employment {
                                    Text(emp.employer?.name ?? "")
                                        .font(.caption).foregroundColor(.white.opacity(0.4))
                                }
                                if let status = profile?.status {
                                    StatusBadge(status: status)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Employment Details
                        if let emp = profile?.employment {
                            CardView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Employment").font(.headline).foregroundColor(.white.opacity(0.7))
                                    InfoRow(icon: "briefcase.fill", label: "Position", value: emp.position ?? "-")
                                    InfoRow(icon: "building.2.fill", label: "Company", value: emp.employer?.name ?? "-")
                                    InfoRow(icon: "calendar", label: "Start Date", value: formatDate(emp.start_date))
                                    if let dept = profile?.department {
                                        InfoRow(icon: "person.3.fill", label: "Department", value: dept)
                                    }
                                    if let empId = profile?.employee_id {
                                        InfoRow(icon: "number", label: "Employee ID", value: empId)
                                    }
                                }
                            }
                        }

                        // Contact Details
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Contact Info").font(.headline).foregroundColor(.white.opacity(0.7))
                                InfoRow(icon: "envelope.fill", label: "Email", value: profile?.email ?? "-")
                                InfoRow(icon: "phone.fill", label: "Phone", value: profile?.phone_number ?? "-")
                                if let pe = profile?.personal_email, !pe.isEmpty {
                                    InfoRow(icon: "envelope", label: "Personal Email", value: pe)
                                }
                                if let addr = profile?.address, !addr.isEmpty {
                                    InfoRow(icon: "mappin.circle.fill", label: "Address", value: addr)
                                }
                                if let city = profile?.city, !city.isEmpty {
                                    InfoRow(icon: "building.fill", label: "City", value: city)
                                }
                                if let country = profile?.country, !country.isEmpty {
                                    InfoRow(icon: "globe", label: "Country", value: country.replacingOccurrences(of: "_", with: " ").capitalized)
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
                                InfoRow(icon: "globe", label: "API", value: "api.outsourcing.merot.com")
                                InfoRow(icon: "building.2", label: "Platform", value: "Merot")
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Profile")
            .brandNavBar()
            .refreshable { await loadProfile() }
            .task { await loadProfile() }
            .sheet(isPresented: $showEditProfile) {
                EmployeeEditProfileSheet(isPresented: $showEditProfile, profile: profile) {
                    Task { await loadProfile() }
                }
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordSheet(isPresented: $showChangePassword)
            }
        }
    }

    private var initials: String {
        let f = (profile?.first_name ?? auth.user?.first_name ?? "").prefix(1)
        let l = (profile?.last_name ?? auth.user?.last_name ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }

    private func loadProfile() async {
        isLoading = true
        do {
            let res: EmpProfileResponse = try await APIService.shared.request("GET", "/employees/profile")
            profile = res.data?.profile
            // Also update auth user for consistency
            if let u = res.data?.user {
                auth.user = u
            }
        } catch {
            #if DEBUG
            print("[EmpProfile] \(error)")
            #endif
        }
        isLoading = false
    }
}

// MARK: - Employee Edit Profile Sheet

struct EmployeeEditProfileSheet: View {
    @Binding var isPresented: Bool
    let profile: EmpProfile?
    var onSaved: () -> Void

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var personalEmail = ""
    @State private var address = ""
    @State private var city = ""
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
                    editField("Personal Email", text: $personalEmail, icon: "envelope", keyboard: .emailAddress)
                    editField("Address", text: $address, icon: "mappin.circle.fill")
                    editField("City", text: $city, icon: "building.fill")

                    if let err = error {
                        Text(err).font(.caption).foregroundColor(.red)
                    }
                    if success {
                        Text("Profile updated").font(.caption).foregroundColor(.green)
                    }

                    Button {
                        Task { await saveProfile() }
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
                firstName = profile?.first_name ?? ""
                lastName = profile?.last_name ?? ""
                phoneNumber = profile?.phone_number ?? ""
                personalEmail = profile?.personal_email ?? ""
                address = profile?.address ?? ""
                city = profile?.city ?? ""
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

    private func saveProfile() async {
        saving = true
        error = nil

        var body: [String: Any] = [:]
        if firstName != (profile?.first_name ?? "") { body["first_name"] = firstName }
        if lastName != (profile?.last_name ?? "") { body["last_name"] = lastName }
        if phoneNumber != (profile?.phone_number ?? "") { body["phone_number"] = phoneNumber }
        if personalEmail != (profile?.personal_email ?? "") { body["personal_email"] = personalEmail }
        if address != (profile?.address ?? "") { body["address"] = address }
        if city != (profile?.city ?? "") { body["city"] = city }

        guard !body.isEmpty else {
            saving = false
            isPresented = false
            return
        }

        do {
            let _: EmpProfileResponse = try await APIService.shared.request("PUT", "/employees/profile", body: body)
            success = true
            onSaved()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isPresented = false
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to update profile"
        }
        saving = false
    }
}
