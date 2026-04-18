import SwiftUI

struct EmployerProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var profile: EmployerProfileData?
    @State private var isLoading = true
    @State private var error: String?
    @State private var showChangePassword = false

    var body: some View {
        ScrollView {
            if isLoading && profile == nil {
                LoadingView()
            } else if let error {
                VStack(spacing: 16) {
                    ErrorBanner(message: error)
                    Button("Retry") { Task { await loadProfile() } }
                        .foregroundColor(.accent)
                }
                .padding(.top, 40)
            } else if let p = profile {
                VStack(spacing: 12) {
                    // User card
                    if let user = p.user {
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
                                    .font(.title3).bold().foregroundColor(.white)
                                if let email = user.email {
                                    Text(email)
                                        .font(.subheadline).foregroundColor(.white.opacity(0.5))
                                }
                                if let status = user.status {
                                    StatusBadge(status: status)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Company info
                    if let company = p.employer {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Company").font(.headline).foregroundColor(.white.opacity(0.7))
                                InfoRow(icon: "building.2.fill", label: "Name", value: company.name ?? "-")
                                if let legal = company.legal_name {
                                    InfoRow(icon: "doc.text", label: "Legal Name", value: legal)
                                }
                                if let status = company.status {
                                    InfoRow(icon: "circle.fill", label: "Status", value: status.capitalized)
                                }
                                if let count = company.employee_count {
                                    InfoRow(icon: "person.3", label: "Employees", value: "\(count)")
                                }
                            }
                        }

                        // Address
                        if company.address_line1 != nil || company.address_city != nil {
                            CardView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Address").font(.headline).foregroundColor(.white.opacity(0.7))
                                    if let addr = company.address_line1 {
                                        InfoRow(icon: "mappin", label: "Address", value: addr)
                                    }
                                    if let city = company.address_city {
                                        InfoRow(icon: "map", label: "City", value: city)
                                    }
                                    if let state = company.address_state {
                                        InfoRow(icon: "globe.americas", label: "State", value: state)
                                    }
                                    if let zip = company.address_zip {
                                        InfoRow(icon: "number", label: "ZIP", value: zip)
                                    }
                                }
                            }
                        }

                        // Contact emails
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Contact").font(.headline).foregroundColor(.white.opacity(0.7))
                                if let email = company.primary_email {
                                    InfoRow(icon: "envelope.fill", label: "Primary Email", value: email)
                                }
                                if let email = company.billing_email {
                                    InfoRow(icon: "creditcard", label: "Billing Email", value: email)
                                }
                                if let email = company.contact_email {
                                    InfoRow(icon: "envelope", label: "Contact Email", value: email)
                                }
                            }
                        }

                        // Member since
                        if let created = company.created_at {
                            CardView {
                                InfoRow(icon: "clock", label: "Member Since", value: formatDate(created))
                            }
                        }
                    }

                    // Actions
                    CardView {
                        VStack(spacing: 10) {
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
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordSheet(isPresented: $showChangePassword)
        }
    }

    private func loadProfile() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerProfileResponse = try await APIService.shared.request("GET", "/employers/profile")
            profile = res.data
        } catch {
            self.error = "Failed to load profile"
            #if DEBUG
            print("[EmployerProfile] \(error)")
            #endif
        }
        isLoading = false
    }
}
