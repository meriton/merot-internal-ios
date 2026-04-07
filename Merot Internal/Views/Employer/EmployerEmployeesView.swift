import SwiftUI

struct EmployerEmployeesView: View {
    @State private var employees: [EmployerEmployee] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var searchText = ""

    private var filtered: [EmployerEmployee] {
        if searchText.isEmpty { return employees }
        return employees.filter {
            ($0.full_name ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.employee_id ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.department ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if let error {
                    ErrorBanner(message: error)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                if filtered.isEmpty && !isLoading {
                    EmptyStateView(icon: "person.3", title: "No employees found")
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                ForEach(filtered) { emp in
                    NavigationLink(value: emp.id) {
                        employeeRow(emp)
                    }
                    .listRowBackground(Color.white.opacity(0.06))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Employees")
            .brandNavBar()
            .searchable(text: $searchText, prompt: "Search employees")
            .refreshable { await loadEmployees() }
            .task { await loadEmployees() }
            .navigationDestination(for: Int.self) { id in
                EmployerEmployeeDetailView(employeeId: id)
            }
            .overlay {
                if isLoading && employees.isEmpty {
                    LoadingView()
                }
            }
        }
    }

    private func employeeRow(_ emp: EmployerEmployee) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(emp.initials)
                        .font(.caption).bold()
                        .foregroundColor(.accent)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(emp.displayName)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    if let pos = emp.employment?.position {
                        Text(pos)
                            .font(.caption2).foregroundColor(.white.opacity(0.5))
                    }
                    if let dept = emp.department {
                        Text(dept)
                            .font(.caption2).foregroundColor(.white.opacity(0.3))
                    }
                }
                if let eid = emp.employee_id {
                    Text(eid)
                        .font(.caption2).foregroundColor(.white.opacity(0.25))
                }
            }
            Spacer()
            StatusBadge(status: emp.status ?? "active")
        }
        .padding(.vertical, 4)
    }

    private func loadEmployees() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerEmployeesResponse = try await APIService.shared.request("GET", "/employers/employees", query: ["per_page": "100"])
            employees = res.data?.employees ?? []
        } catch {
            self.error = "Failed to load employees"
            #if DEBUG
            print("[EmployerEmployees] \(error)")
            #endif
        }
        isLoading = false
    }
}

// MARK: - Employee Detail

struct EmployerEmployeeDetailView: View {
    let employeeId: Int
    @State private var employee: EmployerEmployeeDetail?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ScrollView {
            if isLoading && employee == nil {
                LoadingView()
            } else if let error {
                VStack(spacing: 16) {
                    ErrorBanner(message: error)
                    Button("Retry") { Task { await load() } }
                        .foregroundColor(.accent)
                }
                .padding(.top, 40)
            } else if let emp = employee {
                VStack(spacing: 12) {
                    // Header
                    CardView {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Text(emp.initials)
                                        .font(.title2).bold()
                                        .foregroundColor(.accent)
                                )
                            Text(emp.displayName)
                                .font(.title3).bold().foregroundColor(.white)
                            if let title = emp.title {
                                Text(title)
                                    .font(.subheadline).foregroundColor(.white.opacity(0.5))
                            }
                            StatusBadge(status: emp.status ?? "active")
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Contact
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contact").font(.headline).foregroundColor(.white.opacity(0.7))
                            if let email = emp.email {
                                InfoRow(icon: "envelope.fill", label: "Email", value: email)
                            }
                            if let personalEmail = emp.personal_email {
                                InfoRow(icon: "envelope", label: "Personal Email", value: personalEmail)
                            }
                            if let phone = emp.phone {
                                InfoRow(icon: "phone.fill", label: "Phone", value: phone)
                            }
                        }
                    }

                    // Work Info
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Work Info").font(.headline).foregroundColor(.white.opacity(0.7))
                            if let eid = emp.employee_id {
                                InfoRow(icon: "number", label: "Employee ID", value: eid)
                            }
                            if let dept = emp.department {
                                InfoRow(icon: "building.2", label: "Department", value: dept)
                            }
                            if let position = emp.employment?.position {
                                InfoRow(icon: "briefcase.fill", label: "Position", value: position)
                            }
                            if let country = emp.country {
                                InfoRow(icon: "globe", label: "Country", value: country.replacingOccurrences(of: "_", with: " ").capitalized)
                            }
                            if let location = emp.location {
                                InfoRow(icon: "mappin", label: "Location", value: location)
                            }
                            if let city = emp.city {
                                InfoRow(icon: "map", label: "City", value: city)
                            }
                        }
                    }

                    // Employment History
                    if let employments = emp.employments, !employments.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Employment History").font(.headline).foregroundColor(.white.opacity(0.7))
                                ForEach(employments) { record in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(record.position ?? "Position")
                                                .font(.subheadline).foregroundColor(.white)
                                            Spacer()
                                            StatusBadge(status: record.status ?? "active")
                                        }
                                        if let dept = record.department {
                                            Text(dept)
                                                .font(.caption2).foregroundColor(.white.opacity(0.4))
                                        }
                                        HStack(spacing: 4) {
                                            Text(formatDate(record.start_date))
                                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                                            if let end = record.end_date {
                                                Text("-")
                                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                                                Text(formatDate(end))
                                                    .font(.caption2).foregroundColor(.white.opacity(0.3))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    if record.id != employments.last?.id {
                                        Divider().overlay(Color.white.opacity(0.1))
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
        .navigationTitle("Employee")
        .brandNavBar()
        .refreshable { await load() }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            let res: EmployerEmployeeDetailResponse = try await APIService.shared.request("GET", "/employers/employees/\(employeeId)")
            employee = res.data?.employee
        } catch {
            self.error = "Failed to load employee details"
            #if DEBUG
            print("[EmployerEmpDetail] \(error)")
            #endif
        }
        isLoading = false
    }
}
