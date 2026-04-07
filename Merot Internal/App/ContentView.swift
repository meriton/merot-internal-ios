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
            EmployerMoreView()
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
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
            EmployeeMoreView()
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(.white)
        .toolbarBackground(Color.brand, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Employee More View

struct EmployeeMoreView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { EmployeeVerificationView() } label: {
                        Label("Verification Letters", systemImage: "doc.text.magnifyingglass").foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.white.opacity(0.08))

                Section {
                    NavigationLink { EmployeeProfileView() } label: {
                        Label("Profile", systemImage: "person.circle.fill").foregroundColor(.white)
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
                    NavigationLink { EmploymentVerificationView() } label: {
                        Label("Employment Verification", systemImage: "checkmark.seal.fill").foregroundColor(.white)
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
