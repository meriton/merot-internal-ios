import SwiftUI

struct EmployerProfileView: View {
    @State private var profileData: EmployerProfileData?
    @State private var isLoading = true
    @State private var errorMessage = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading profile...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !errorMessage.isEmpty {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                loadProfile()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else if let profile = profileData {
                        VStack(alignment: .leading, spacing: 20) {
                            // Company Information Section
                            ProfileSectionCard(title: "Company Information") {
                                ProfileInfoRow(label: "Company Name", value: profile.employer.name ?? "N/A")
                                if let legalName = profile.employer.legal_name, !legalName.isEmpty {
                                    ProfileInfoRow(label: "Legal Name", value: legalName)
                                }
                                if let email = profile.employer.email, !email.isEmpty {
                                    ProfileInfoRow(label: "Email", value: email)
                                }
                                if let primaryEmail = profile.employer.primary_email, !primaryEmail.isEmpty {
                                    ProfileInfoRow(label: "Primary Email", value: primaryEmail)
                                }
                                if let billingEmail = profile.employer.billing_email, !billingEmail.isEmpty {
                                    ProfileInfoRow(label: "Billing Email", value: billingEmail)
                                }
                                if let contactEmail = profile.employer.contact_email, !contactEmail.isEmpty {
                                    ProfileInfoRow(label: "Contact Email", value: contactEmail)
                                }
                            }
                            
                            // Address Section
                            if hasAddressInfo(profile.employer) {
                                ProfileSectionCard(title: "Company Address") {
                                    if let address1 = profile.employer.address_line1, !address1.isEmpty {
                                        ProfileInfoRow(label: "Address", value: address1)
                                    }
                                    if let city = profile.employer.address_city, !city.isEmpty {
                                        ProfileInfoRow(label: "City", value: city)
                                    }
                                    if let state = profile.employer.address_state, !state.isEmpty {
                                        ProfileInfoRow(label: "State", value: state)
                                    }
                                    if let zip = profile.employer.address_zip, !zip.isEmpty {
                                        ProfileInfoRow(label: "ZIP Code", value: zip)
                                    }
                                    if let fullAddress = profile.employer.full_address, !fullAddress.isEmpty {
                                        ProfileInfoRow(label: "Full Address", value: fullAddress)
                                    }
                                }
                            }
                            
                            // User Information Section
                            ProfileSectionCard(title: "User Information") {
                                ProfileInfoRow(label: "Name", value: profile.employer_user.full_name ?? "N/A")
                                ProfileInfoRow(label: "Email", value: profile.employer_user.email ?? "N/A")
                                if let firstName = profile.employer_user.first_name, !firstName.isEmpty {
                                    ProfileInfoRow(label: "First Name", value: firstName)
                                }
                                if let lastName = profile.employer_user.last_name, !lastName.isEmpty {
                                    ProfileInfoRow(label: "Last Name", value: lastName)
                                }
                            }
                            
                            // Company Statistics Section
                            ProfileSectionCard(title: "Company Statistics") {
                                ProfileInfoRow(label: "Total Employees", value: "\(profile.employer.total_employees ?? 0)")
                                ProfileInfoRow(label: "Active Employees", value: "\(profile.profile_stats.total_active_employees)")
                                ProfileInfoRow(label: "Inactive Employees", value: "\(profile.profile_stats.total_inactive_employees)")
                                ProfileInfoRow(label: "Pending Time Off Requests", value: "\(profile.profile_stats.pending_time_off_requests)")
                                ProfileInfoRow(label: "Approved Requests This Month", value: "\(profile.profile_stats.approved_time_off_requests_this_month)")
                                ProfileInfoRow(label: "Total Payroll Records", value: "\(profile.profile_stats.total_payroll_records)")
                            }
                            
                            // Financial Information Section
                            ProfileSectionCard(title: "Financial Information") {
                                if let outstanding = profile.employer.total_outstanding_amount {
                                    ProfileInfoRow(label: "Outstanding Amount", value: String(format: "$%.2f", outstanding))
                                }
                                if let paid = profile.employer.total_paid_amount {
                                    ProfileInfoRow(label: "Total Paid Amount", value: String(format: "$%.2f", paid))
                                }
                                ProfileInfoRow(label: "Recent Invoices", value: "\(profile.profile_stats.recent_invoices_count)")
                                ProfileInfoRow(label: "Outstanding Invoices", value: "\(profile.profile_stats.outstanding_invoices_count)")
                            }
                            
                            // Company Officers Section
                            if hasOfficerInfo(profile.employer) {
                                ProfileSectionCard(title: "Company Officers") {
                                    if let rep = profile.employer.authorized_representative_name, !rep.isEmpty {
                                        ProfileInfoRow(label: "Authorized Representative", value: rep)
                                    }
                                    if let officer = profile.employer.authorized_officer_name, !officer.isEmpty {
                                        ProfileInfoRow(label: "Authorized Officer", value: officer)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                loadProfile()
            }
        }
        .onAppear {
            loadProfile()
        }
    }
    
    private func hasAddressInfo(_ employer: EmployerData) -> Bool {
        return ![employer.address_line1, employer.address_city, employer.address_state, employer.address_zip]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .isEmpty == false
    }
    
    private func hasOfficerInfo(_ employer: EmployerData) -> Bool {
        return ![employer.authorized_representative_name, employer.authorized_officer_name]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .isEmpty == false
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        return dateString
    }
    
    private func loadProfile() {
        isLoading = true
        errorMessage = ""
        
        APIService.shared.fetchEmployerProfile { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let profile):
                    self.profileData = profile
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct ProfileSectionCard<Content: View>: View {
    let title: String
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.merotBlue)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: 120, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}

// Models are now defined in Models.swift


#Preview {
    EmployerProfileView()
}