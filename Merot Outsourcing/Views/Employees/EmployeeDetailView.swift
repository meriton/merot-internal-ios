import SwiftUI

struct EmployeeDetailView: View {
    let employeeId: Int
    @StateObject private var vm = EmployeeDetailViewModel()
    @State private var showEditForm = false
    @State private var showShareSheet = false
    @State private var confirmAction: String?

    var body: some View {
        ScrollView {
            if vm.isLoading && vm.detail == nil {
                LoadingView()
            } else if let error = vm.error, vm.detail == nil {
                ErrorBanner(message: error)
            } else if let detail = vm.detail {
                VStack(spacing: 16) {
                    if let msg = vm.successMessage {
                        SuccessBanner(message: msg)
                    }
                    if let err = vm.error {
                        ErrorBanner(message: err)
                    }

                    // Header card
                    headerCard(detail.employee)

                    // Actions card
                    actionsCard(detail.employee)

                    // Personal info
                    personalInfoCard(detail.employee)

                    // Salary
                    if let salary = detail.salary_detail {
                        salaryCard(salary)
                    }

                    // Employments
                    if let employments = detail.employments, !employments.isEmpty {
                        employmentsCard(employments)
                    }

                    // Agreements
                    if let agreements = detail.employee_agreements, !agreements.isEmpty {
                        agreementsCard(agreements)
                    }

                    // Recent payroll
                    if let records = detail.recent_payroll_records, !records.isEmpty {
                        payrollCard(records)
                    }

                    // ID Photos
                    idPhotosCard(detail.employee)
                }
                .padding()
            }
        }
        .background(Color.brand.ignoresSafeArea())
        .navigationTitle(vm.detail?.employee.displayName ?? "Employee")
        .brandNavBar()
        .refreshable { await vm.load(id: employeeId) }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showEditForm = true } label: {
                    Image(systemName: "pencil").foregroundColor(.white)
                }
                .disabled(vm.detail == nil)
            }
        }
        .sheet(isPresented: $showEditForm) {
            if let emp = vm.detail?.employee {
                EmployeeFormView(employee: emp) { Task { await vm.load(id: employeeId) } }
            }
        }
        .alert("Confirm", isPresented: Binding(
            get: { confirmAction != nil },
            set: { if !$0 { confirmAction = nil } }
        )) {
            Button("Cancel", role: .cancel) { confirmAction = nil }
            Button("Confirm") {
                if let action = confirmAction {
                    Task {
                        switch action {
                        case "welcome_email": await vm.sendWelcomeEmail(id: employeeId)
                        case "regenerate_id": await vm.regenerateId(id: employeeId)
                        case "personal_info": await vm.sendPersonalInfoRequest(employeeUserId: employeeId)
                        default: break
                        }
                    }
                }
                confirmAction = nil
            }
        } message: {
            Text(confirmActionMessage)
        }
        .task { await vm.load(id: employeeId) }
    }

    private var confirmActionMessage: String {
        switch confirmAction {
        case "welcome_email": return "Send welcome email to this employee?"
        case "regenerate_id": return "Regenerate the employee ID? The old ID will no longer be valid."
        case "personal_info": return "Send a personal info request to this employee?"
        default: return "Are you sure?"
        }
    }

    // MARK: - Actions

    private func actionsCard(_ emp: EmployeeFullJSON) -> some View {
        CardView {
            VStack(spacing: 10) {
                Text("Actions").font(.headline).foregroundColor(.white.opacity(0.7)).frame(maxWidth: .infinity, alignment: .leading)

                employeeActionButton("Send Welcome Email", icon: "envelope.fill", color: .blue) {
                    confirmAction = "welcome_email"
                }
                employeeActionButton("Regenerate ID", icon: "arrow.triangle.2.circlepath", color: .orange) {
                    confirmAction = "regenerate_id"
                }
                employeeActionButton("Request Personal Info", icon: "person.text.rectangle", color: .purple) {
                    confirmAction = "personal_info"
                }
            }
        }
    }

    private func employeeActionButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if vm.isActioning {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: icon)
                    Text(label)
                }
            }
            .font(.subheadline).fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.8))
            .cornerRadius(10)
        }
        .disabled(vm.isActioning)
    }

    // MARK: - Header

    private func headerCard(_ emp: EmployeeFullJSON) -> some View {
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
                    .font(.title3).bold()
                    .foregroundColor(.white)
                if let title = emp.title {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
                HStack(spacing: 8) {
                    StatusBadge(status: emp.status ?? "unknown")
                    if let type = emp.employee_type {
                        StatusBadge(status: type)
                    }
                }
                if let eid = emp.employee_id {
                    Text("ID: \(eid)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Personal Info

    private func personalInfoCard(_ emp: EmployeeFullJSON) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Personal Information")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                InfoRow(icon: "envelope.fill", label: "Email", value: emp.email ?? "-")
                InfoRow(icon: "phone.fill", label: "Phone", value: emp.phone_number ?? "-")
                InfoRow(icon: "building.2.fill", label: "Department", value: emp.department_name ?? emp.department ?? "-")
                InfoRow(icon: "mappin.circle.fill", label: "Location", value: emp.location ?? "-")
                InfoRow(icon: "globe", label: "Country", value: emp.country_name ?? emp.country ?? "-")
                if let city = emp.city { InfoRow(icon: "building.fill", label: "City", value: city) }
                if let address = emp.address { InfoRow(icon: "house.fill", label: "Address", value: address) }
                if let pid = emp.personal_id_number { InfoRow(icon: "creditcard.fill", label: "ID Number", value: pid) }
            }
        }
    }

    // MARK: - Salary

    private func salaryCard(_ salary: SalaryDetail) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Salary Details")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                        Text(formatMoney(salary.net_salary, currency: salary.currency))
                            .font(.title3).bold()
                            .foregroundColor(.accent)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Gross")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                        Text(formatMoney(salary.gross_salary, currency: salary.currency))
                            .font(.title3).bold()
                            .foregroundColor(.white)
                    }
                }
                if let bank = salary.bank_name {
                    InfoRow(icon: "building.columns.fill", label: "Bank", value: bank)
                }
                if let acc = salary.bank_account_number {
                    InfoRow(icon: "creditcard.fill", label: "Account", value: acc)
                }
                if let type = salary.employment_type {
                    InfoRow(icon: "briefcase.fill", label: "Type", value: type.replacingOccurrences(of: "_", with: " ").capitalized)
                }
            }
        }
    }

    // MARK: - Employments

    private func employmentsCard(_ employments: [EmploymentRecord]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Employments")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                ForEach(employments) { emp in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(emp.employer_name ?? "Unknown")
                                .font(.subheadline).bold()
                                .foregroundColor(.white)
                            Text("\(formatDate(emp.start_date)) - \(emp.end_date != nil ? formatDate(emp.end_date) : "Present")")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        Spacer()
                        StatusBadge(status: emp.employment_status ?? "unknown")
                    }
                    if emp.id != employments.last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }

    // MARK: - Agreements

    private func agreementsCard(_ agreements: [EmployeeAgreementBrief]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Agreements")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                ForEach(agreements) { a in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Agreement #\(a.id)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text(formatDate(a.created_at))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            StatusBadge(status: a.contract_status ?? "unknown")
                            StatusBadge(status: a.signature_status ?? "unknown")
                        }
                    }
                    if a.id != agreements.last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }

    // MARK: - Payroll

    private func payrollCard(_ records: [RecentPayrollRecord]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent Payroll")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                ForEach(records) { r in
                    HStack {
                        Text(r.period ?? "-")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatMoney(r.net_salary))
                                .font(.subheadline).bold()
                                .foregroundColor(.accent)
                            Text("gross: \(formatMoney(r.gross_salary))")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    if r.id != records.last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }

    // MARK: - ID Photos

    private func idPhotosCard(_ emp: EmployeeFullJSON) -> some View {
        Group {
            if emp.id_front_photo_url != nil || emp.id_back_photo_url != nil {
                CardView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ID Photos")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        HStack(spacing: 12) {
                            if let front = emp.id_front_photo_url, let url = URL(string: front) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView().tint(.white)
                                }
                                .frame(maxHeight: 120)
                                .cornerRadius(8)
                            }
                            if let back = emp.id_back_photo_url, let url = URL(string: back) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView().tint(.white)
                                }
                                .frame(maxHeight: 120)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
}
