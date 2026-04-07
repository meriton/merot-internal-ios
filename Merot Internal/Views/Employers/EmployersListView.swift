import SwiftUI

struct EmployersListView: View {
    @StateObject private var vm = EmployersViewModel()
    @State private var showCreateForm = false

    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                TextField("Search employers...", text: $vm.searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .onSubmit { Task { await vm.search() } }
            }
            .padding(10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView {
                if let error = vm.error {
                    ErrorBanner(message: error)
                }
                if vm.employers.isEmpty && !vm.isLoading {
                    EmptyStateView(icon: "building.2", title: "No employers found")
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.employers) { employer in
                            NavigationLink(destination: EmployerDetailView(employerId: employer.id)) {
                                employerRow(employer)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle("Employers")
        .brandNavBar()
        .refreshable { await vm.load() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showCreateForm = true } label: {
                    Image(systemName: "plus").foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showCreateForm) {
            EmployerFormView(employer: nil) { Task { await vm.load() } }
        }
        .task { await vm.load() }
    }

    private func employerRow(_ e: Employer) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String((e.name ?? "?").prefix(2)).uppercased())
                        .font(.caption).bold()
                        .foregroundColor(.accent)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(e.name ?? "Unknown")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                if let city = e.address_city {
                    Text(city)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: e.status ?? "unknown")
                Text("\(e.employee_count ?? 0) employees")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct EmployerDetailView: View {
    let employerId: Int
    @StateObject private var vm = EmployerDetailViewModel()
    @State private var showEditForm = false

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.detail == nil {
                LoadingView()
            } else if let detail = vm.detail {
                VStack(spacing: 16) {
                    // Header
                    CardView {
                        VStack(spacing: 12) {
                            Text(detail.employer.name ?? "Unknown")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            if let legal = detail.employer.legal_name {
                                Text(legal)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            HStack(spacing: 16) {
                                VStack {
                                    Text("\(detail.employee_count ?? 0)")
                                        .font(.title2).bold()
                                        .foregroundColor(.accent)
                                    Text("Employees")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                VStack {
                                    Text(formatMoney(detail.total_invoiced))
                                        .font(.title2).bold()
                                        .foregroundColor(.accent)
                                    Text("Total Invoiced")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Contact
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contact").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "envelope.fill", label: "Primary Email", value: detail.employer.primary_email ?? "-")
                            InfoRow(icon: "envelope.fill", label: "Billing Email", value: detail.employer.billing_email ?? "-")
                            InfoRow(icon: "phone.fill", label: "Phone", value: detail.employer.phone ?? "-")
                            InfoRow(icon: "globe", label: "Website", value: detail.employer.website ?? "-")
                        }
                    }

                    // Address
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Address").font(.headline).foregroundColor(.white.opacity(0.7))
                            if let a = detail.employer.address_line1 { InfoRow(icon: "mappin", label: "Address", value: a) }
                            InfoRow(icon: "building.fill", label: "City", value: detail.employer.address_city ?? "-")
                            InfoRow(icon: "globe", label: "Country", value: detail.employer.address_country ?? "-")
                        }
                    }

                    // Business
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Business").font(.headline).foregroundColor(.white.opacity(0.7))
                            InfoRow(icon: "number", label: "Tax Number", value: detail.employer.tax_number ?? "-")
                            InfoRow(icon: "doc.text", label: "Registration", value: detail.employer.registration_number ?? "-")
                            InfoRow(icon: "briefcase.fill", label: "Industry", value: detail.employer.industry ?? "-")
                        }
                    }

                    // Active Employments
                    if let emps = detail.active_employments, !emps.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Active Employees").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(emps) { emp in
                                    HStack {
                                        Text(emp.employee_name ?? "Unknown")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(formatDate(emp.start_date))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle(vm.detail?.employer.name ?? "Employer")
        .brandNavBar()
        .refreshable { await vm.load(id: employerId) }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showEditForm = true } label: {
                    Image(systemName: "pencil").foregroundColor(.white)
                }
                .disabled(vm.detail == nil)
            }
        }
        .sheet(isPresented: $showEditForm) {
            if let emp = vm.detail?.employer {
                EmployerFormView(employer: emp) { Task { await vm.load(id: employerId) } }
            }
        }
        .task { await vm.load(id: employerId) }
    }
}
