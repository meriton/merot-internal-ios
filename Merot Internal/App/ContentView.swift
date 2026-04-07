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
                        Label("Service Agreements", systemImage: "handshake.fill").foregroundColor(.white)
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

struct EmployeePayrollView: View {
    var body: some View {
        NavigationStack {
            PayrollListView()
        }
    }
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
    var body: some View {
        NavigationStack {
            TimeOffRequestsView()
        }
    }
}

struct EmployeeProfileView: View {
    var body: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
