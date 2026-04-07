import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.isCheckingSession {
                splashView
            } else if auth.isAuthenticated {
                switch auth.userType {
                case "employer":
                    EmployerTabView()
                case "employee":
                    EmployeeTabView()
                default:
                    AdminTabView()
                }
            } else {
                LoginView()
            }
        }
        .task {
            await auth.checkExistingSession()
        }
    }

    private var splashView: some View {
        ZStack {
            Color.brand.ignoresSafeArea()
            VStack(spacing: 16) {
                LogoView(height: 50)
                ProgressView()
                    .tint(.white)
            }
        }
    }
}

// MARK: - Admin Tab View

struct AdminTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            EmployeesListView()
                .tabItem { Label("Employees", systemImage: "person.3.fill") }
            InvoicesListView()
                .tabItem { Label("Invoices", systemImage: "doc.text.fill") }
            HiringTabView()
                .tabItem { Label("Hiring", systemImage: "briefcase.fill") }
            AdminMoreView()
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(.white)
        .toolbarBackground(Color.brand, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Employer Tab View

struct EmployerTabView: View {
    var body: some View {
        TabView {
            EmployerDashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            EmployerEmployeesView()
                .tabItem { Label("Employees", systemImage: "person.3.fill") }
            EmployerInvoicesView()
                .tabItem { Label("Invoices", systemImage: "doc.text.fill") }
            EmployerTimeOffView()
                .tabItem { Label("Time Off", systemImage: "calendar.badge.clock") }
            EmployerProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle.fill") }
        }
        .tint(.white)
        .toolbarBackground(Color.brand, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Employee Tab View

struct EmployeeTabView: View {
    var body: some View {
        TabView {
            EmployeeDashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            EmployeePayrollView()
                .tabItem { Label("Payroll", systemImage: "banknote.fill") }
            EmployeeTimeTrackingView()
                .tabItem { Label("Clock", systemImage: "clock.fill") }
            EmployeeTimeOffView()
                .tabItem { Label("Time Off", systemImage: "calendar.badge.clock") }
            EmployeeProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle.fill") }
        }
        .tint(.white)
        .toolbarBackground(Color.brand, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Admin Hiring Tab

struct HiringTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Postings").tag(0)
                    Text("Applications").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                if selectedTab == 0 {
                    JobPostingsListContent()
                } else {
                    JobApplicationsListContent()
                }
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Hiring")
            .brandNavBar()
        }
    }
}

// MARK: - Admin More View

struct AdminMoreView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { EmployersListView() } label: {
                        Label("Employers", systemImage: "building.2.fill").foregroundColor(.white)
                    }
                    NavigationLink { PayrollListView() } label: {
                        Label("Payroll", systemImage: "banknote.fill").foregroundColor(.white)
                    }
                    NavigationLink { TimeOffRequestsView() } label: {
                        Label("Time Off Requests", systemImage: "calendar.badge.clock").foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.white.opacity(0.08))

                Section {
                    NavigationLink { EmployeeAgreementsListView() } label: {
                        Label("Employee Agreements", systemImage: "doc.text.fill").foregroundColor(.white)
                    }
                    NavigationLink { ServiceAgreementsListView() } label: {
                        Label("Service Agreements", systemImage: "signature").foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.white.opacity(0.08))

                Section {
                    NavigationLink { PersonalInfoRequestsView() } label: {
                        Label("Personal Info Requests", systemImage: "person.text.rectangle.fill").foregroundColor(.white)
                    }
                    NavigationLink { ContactRequestsView() } label: {
                        Label("Contact Requests", systemImage: "envelope.fill").foregroundColor(.white)
                    }
                    NavigationLink { HolidaysView() } label: {
                        Label("Holidays", systemImage: "calendar").foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.white.opacity(0.08))

                Section {
                    NavigationLink { SettingsView() } label: {
                        Label("Settings", systemImage: "gearshape.fill").foregroundColor(.white)
                    }
                    Button(role: .destructive) { auth.logout() } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                .listRowBackground(Color.white.opacity(0.08))
            }
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("More")
            .brandNavBar()
        }
    }
}

// MARK: - Employer Portal Views (Placeholder)

struct EmployerDashboardView: View {
    @EnvironmentObject var auth: AuthViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Welcome, \(auth.user?.full_name ?? "")")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .brandNavBar()
        }
    }
}

struct EmployerEmployeesView: View {
    var body: some View {
        NavigationStack {
            EmployeesListView()
        }
    }
}

struct EmployerInvoicesView: View {
    var body: some View {
        NavigationStack {
            InvoicesListView()
        }
    }
}

struct EmployerTimeOffView: View {
    var body: some View {
        NavigationStack {
            TimeOffRequestsView()
        }
    }
}

struct EmployerProfileView: View {
    var body: some View {
        NavigationStack {
            SettingsView()
        }
    }
}

// MARK: - Employee Portal Views (Placeholder)

struct EmployeeDashboardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var data: EmployeeDashData?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading && data == nil {
                    LoadingView()
                } else if let d = data {
                    VStack(spacing: 12) {
                        // Welcome
                        CardView {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome, \(d.employee?.full_name ?? auth.user?.full_name ?? "")")
                                    .font(.headline).foregroundColor(.white)
                                if let emp = d.employment {
                                    Text(emp.position ?? "")
                                        .font(.caption).foregroundColor(.accent)
                                    if let name = emp.employer?.name {
                                        Text(name)
                                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                                    }
                                }
                            }
                        }

                        // Stats row
                        HStack(spacing: 10) {
                            StatCard(icon: "clock", title: "Hours/Week", value: String(format: "%.1f", d.time_tracking?.total_hours_this_week ?? 0))
                            StatCard(icon: "calendar", title: "Hours/Month", value: String(format: "%.1f", d.time_tracking?.total_hours_this_month ?? 0))
                            StatCard(icon: "sun.max", title: "Days Off", value: "\(Int(d.time_off?.available_days ?? 0))")
                        }

                        // Clock status
                        if let tt = d.time_tracking {
                            CardView {
                                HStack {
                                    Image(systemName: tt.currently_clocked_in == true ? "clock.badge.checkmark.fill" : "clock")
                                        .foregroundColor(tt.currently_clocked_in == true ? .green : .white.opacity(0.4))
                                    Text(tt.currently_clocked_in == true ? "Currently Clocked In" : "Not Clocked In")
                                        .font(.subheadline).foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }

                        // Last Paystub
                        if let pay = d.last_paystub {
                            CardView {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Last Paystub").font(.caption).foregroundColor(.white.opacity(0.4))
                                    HStack {
                                        Text(formatMoney(pay.net_salary, currency: pay.currency))
                                            .font(.title3).bold().foregroundColor(.accent)
                                        Spacer()
                                        Text("gross: \(formatMoney(pay.gross_salary, currency: pay.currency))")
                                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                                    }
                                    if let period = pay.period {
                                        Text(period).font(.caption2).foregroundColor(.white.opacity(0.3))
                                    }
                                }
                            }
                        }

                        // Next Holiday
                        if let h = d.next_holiday {
                            CardView {
                                HStack {
                                    Image(systemName: "calendar").foregroundColor(.accent)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(h.name ?? "Holiday").font(.subheadline).foregroundColor(.white)
                                        Text("\(h.date ?? "") - \(h.day_of_week ?? "")")
                                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    if let days = h.days_until {
                                        Text(days == 0 ? "Today" : "\(days)d")
                                            .font(.caption).bold().foregroundColor(.accent)
                                    }
                                }
                            }
                        }

                        // Pending Time Off
                        if let pending = d.time_off?.pending_requests, !pending.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Pending Time Off").font(.caption).foregroundColor(.white.opacity(0.4))
                                    ForEach(pending, id: \.id) { req in
                                        HStack {
                                            Text("\(req.start_date?.prefix(10) ?? "") - \(req.end_date?.prefix(10) ?? "")")
                                                .font(.caption).foregroundColor(.white)
                                            Spacer()
                                            Text("\(req.days ?? 0) days")
                                                .font(.caption2).foregroundColor(.accent)
                                            StatusBadge(status: req.approval_status ?? "pending")
                                        }
                                    }
                                }
                            }
                        }

                        // Leave Balances
                        if let balances = d.time_off?.balances, !balances.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Leave Balances").font(.caption).foregroundColor(.white.opacity(0.4))
                                    ForEach(balances, id: \.id) { b in
                                        HStack {
                                            Text((b.leave_type ?? "").replacingOccurrences(of: "_", with: " ").capitalized)
                                                .font(.caption).foregroundColor(.white)
                                            Spacer()
                                            Text("\(Int(b.balance ?? 0))/\(Int(b.days ?? 0))")
                                                .font(.caption).bold().foregroundColor(.accent)
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
            .navigationTitle("Dashboard")
            .brandNavBar()
            .refreshable { await loadDashboard() }
            .task { await loadDashboard() }
        }
    }

    private func loadDashboard() async {
        isLoading = true
        do {
            let res: APIResponse<EmployeeDashData> = try await APIService.shared.request("GET", "/employees/dashboard")
            data = res.data
        } catch {
            #if DEBUG
            print("[EmpDash] Error: \(error)")
            #endif
        }
        isLoading = false
    }
}

// MARK: - Employee Dashboard Models

struct EmployeeDashData: Codable {
    let employee: EmployeeDashEmployee?
    let employment: EmployeeDashEmployment?
    let time_tracking: EmployeeDashTimeTracking?
    let time_off: EmployeeDashTimeOff?
    let next_holiday: EmployeeDashHoliday?
    let last_paystub: EmployeeDashPaystub?
}

struct EmployeeDashEmployee: Codable {
    let id: Int?
    let full_name: String?
    let employee_id: String?
    let department: String?
}

struct EmployeeDashEmployment: Codable {
    let id: Int?
    let position: String?
    let employer: EmployeeDashEmployer?
}

struct EmployeeDashEmployer: Codable {
    let id: Int?
    let name: String?
}

struct EmployeeDashTimeTracking: Codable {
    let currently_clocked_in: Bool?
    let total_hours_this_week: Double?
    let total_hours_this_month: Double?
}

struct EmployeeDashTimeOff: Codable {
    let available_days: Double?
    let pending_requests_count: Int?
    let pending_requests: [EmployeeDashPendingReq]?
    let balances: [EmployeeDashBalance]?
}

struct EmployeeDashPendingReq: Codable {
    let id: Int
    let start_date: String?
    let end_date: String?
    let days: Int?
    let approval_status: String?
}

struct EmployeeDashBalance: Codable {
    let id: Int
    let name: String?
    let leave_type: String?
    let days: Double?
    let balance: Double?
}

struct EmployeeDashHoliday: Codable {
    let id: Int?
    let name: String?
    let date: String?
    let day_of_week: String?
    let days_until: Int?
}

struct EmployeeDashPaystub: Codable {
    let id: Int?
    let period: String?
    let net_salary: Double?
    let gross_salary: Double?
    let currency: String?
}

struct EmployeePayrollView: View {
    @State private var records: [EmpPayrollRecord] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List {
                if let error {
                    ErrorBanner(message: error).listRowBackground(Color.clear)
                }
                if records.isEmpty && !isLoading {
                    EmptyStateView(icon: "banknote", title: "No payroll records").listRowBackground(Color.clear)
                }
                ForEach(records) { r in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(r.period_label ?? r.period ?? "Payroll")
                                .font(.subheadline).bold().foregroundColor(.white)
                            Spacer()
                            Text(r.currency ?? "MKD")
                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Net").font(.caption2).foregroundColor(.white.opacity(0.4))
                                Text(formatMoney(r.net_pay)).font(.headline).foregroundColor(.accent)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Gross").font(.caption2).foregroundColor(.white.opacity(0.4))
                                Text(formatMoney(r.gross_pay)).font(.subheadline).foregroundColor(.white.opacity(0.7))
                            }
                        }
                        if r.overtime_hours ?? 0 > 0 {
                            Text("OT: \(String(format: "%.1f", r.overtime_hours ?? 0))h")
                                .font(.caption2).foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.white.opacity(0.06))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Payroll")
            .brandNavBar()
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            let res: EmpPayrollResponse = try await APIService.shared.request("GET", "/employees/payroll_records", query: ["per_page": "50"])
            records = res.data?.payroll_records ?? []
        } catch {
            self.error = "Failed to load payroll"
            #if DEBUG
            print("[EmpPayroll] \(error)")
            #endif
        }
        isLoading = false
    }
}

struct EmpPayrollRecord: Codable, Identifiable {
    let id: Int
    let employee_id: String?
    let gross_pay: Double?
    let net_pay: Double?
    let base_salary: Double?
    let overtime_hours: Double?
    let overtime_pay: Double?
    let currency: String?
    let period: String?
    let period_label: String?
    let created_at: String?
}

struct EmpPayrollResponse: Codable {
    let data: EmpPayrollData?
    let success: Bool?
}

struct EmpPayrollData: Codable {
    let payroll_records: [EmpPayrollRecord]
}

struct EmployeeTimeTrackingView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var isClockedIn = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: isClockedIn ? "clock.badge.checkmark.fill" : "clock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isClockedIn ? .brandGreen : .white.opacity(0.5))

                Text(isClockedIn ? "Clocked In" : "Clocked Out")
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(.white)

                Button {
                    Task {
                        isLoading = true
                        let endpoint = isClockedIn ? "/employees/clock_out" : "/employees/clock_in"
                        let _: APIResponse<String>? = try? await APIService.shared.request("POST", endpoint)
                        isClockedIn.toggle()
                        isLoading = false
                    }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(isClockedIn ? "Clock Out" : "Clock In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(width: 200)
                    .padding(.vertical, 16)
                    .background(isClockedIn ? Color.red.opacity(0.8) : Color.brandGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                Spacer()
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Time Tracking")
            .brandNavBar()
            .task {
                if let res: APIResponse<[String: Bool]> = try? await APIService.shared.request("GET", "/employees/time_tracking/status") {
                    isClockedIn = res.data?["clocked_in"] ?? false
                }
            }
        }
    }
}

struct EmployeeTimeOffView: View {
    @State private var requests: [EmpTimeOffReq] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List {
                if let error {
                    ErrorBanner(message: error).listRowBackground(Color.clear)
                }
                if requests.isEmpty && !isLoading {
                    EmptyStateView(icon: "calendar.badge.clock", title: "No time off requests").listRowBackground(Color.clear)
                }
                ForEach(requests) { r in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(r.time_off_record?.name ?? "Time Off")
                                .font(.subheadline).foregroundColor(.white)
                            Text("\(r.start_date?.prefix(10) ?? "") - \(r.end_date?.prefix(10) ?? "")")
                                .font(.caption2).foregroundColor(.white.opacity(0.4))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            StatusBadge(status: r.approval_status ?? "pending")
                            Text("\(r.days ?? 0) days")
                                .font(.caption2).foregroundColor(.accent)
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.white.opacity(0.06))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Time Off")
            .brandNavBar()
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            let res: EmpTimeOffResponse = try await APIService.shared.request("GET", "/employees/time_off_requests")
            requests = res.data?.time_off_requests ?? []
        } catch {
            self.error = "Failed to load time off"
            #if DEBUG
            print("[EmpTimeOff] \(error)")
            #endif
        }
        isLoading = false
    }
}

struct EmpTimeOffReq: Codable, Identifiable {
    let id: Int
    let start_date: String?
    let end_date: String?
    let days: Int?
    let approval_status: String?
    let time_off_record: EmpTimeOffRecord?
    let created_at: String?
}

struct EmpTimeOffRecord: Codable {
    let id: Int?
    let name: String?
    let leave_type: String?
}

struct EmpTimeOffResponse: Codable {
    let data: EmpTimeOffData?
    let success: Bool?
}

struct EmpTimeOffData: Codable {
    let time_off_requests: [EmpTimeOffReq]
}

struct EmployeeProfileView: View {
    var body: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
