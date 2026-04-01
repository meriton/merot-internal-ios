import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Admin Dashboard Tab
            AdminHomeView()
                .environmentObject(authService)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }
                .tag(0)
            
            // Hiring Tab - This is the new tab for job postings
            HiringView()
                .tabItem {
                    Image(systemName: "briefcase")
                    Text("Hiring")
                }
                .tag(1)
            
            // Invoices Tab
            InvoicesView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Invoices")
                }
                .tag(2)
            
            // Employees Tab
            AdminEmployeesView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Employees")
                }
                .tag(3)
            
            // Employers Tab
            AdminEmployersView()
                .tabItem {
                    Image(systemName: "building.2")
                    Text("Employers")
                }
                .tag(4)
            
            // Settings Tab
            AdminSettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(5)
        }
    }
}

// Placeholder views for admin functionality
struct AdminHomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var cachedAPIService = CachedAPIService()
    @State private var dashboardData: AdminDashboardData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var currentTask: Task<Void, Never>?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading dashboard...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let errorMessage = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            
                            Text("Error Loading Dashboard")
                                .font(.headline)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Retry") {
                                Task {
                                    await loadAdminDashboard()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding()
                    } else if let dashboardData = dashboardData {
                        AdminDashboardStatsView(stats: dashboardData.stats)
                        
                        RecentEmployersView(employers: dashboardData.recentEmployers)
                        
                        SystemAlertsView(alerts: dashboardData.systemAlerts)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadAdminDashboard(forceRefresh: true)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await authService.logout()
                        }
                    }) {
                        Image(systemName: "power")
                    }
                }
            }
        }
        .onAppear {
            currentTask = Task {
                await loadAdminDashboard(forceRefresh: false)
            }
        }
        .onDisappear {
            currentTask?.cancel()
            Task {
                await cachedAPIService.cancelAllRequests()
            }
        }
    }
    
    private func loadAdminDashboard(forceRefresh: Bool = false) async {
        // Cancel any existing task
        currentTask?.cancel()
        await cachedAPIService.cancelAdminDashboardRequest()
        
        isLoading = true
        errorMessage = nil
        
        print("AdminDashboardView: Starting loadAdminDashboard with forceRefresh: \(forceRefresh)")
        
        currentTask = Task {
            do {
                // Check if task was cancelled before starting
                try Task.checkCancellation()
                
                dashboardData = try await cachedAPIService.getAdminDashboard(forceRefresh: forceRefresh)
                
                // Check if task was cancelled after network call
                try Task.checkCancellation()
                
                await MainActor.run {
                    print("AdminDashboardView: Successfully loaded dashboard data")
                }
            } catch is CancellationError {
                await MainActor.run {
                    print("AdminDashboardView: Task was cancelled")
                    // Don't show error message for cancelled requests
                    isLoading = false
                }
                return
            } catch let networkError as NetworkManager.NetworkError {
                await MainActor.run {
                    print("AdminDashboardView: NetworkManager error: \(networkError)")
                    switch networkError {
                    case .decodingError:
                        errorMessage = "Failed to load dashboard data. Please try again later."
                        print("Admin Dashboard Decoding Error: \(networkError)")
                        
                        // If decoding fails and we were trying to use cache, try to clear cache and fetch fresh
                        if !forceRefresh {
                            print("AdminDashboardView: Clearing cache and retrying with fresh data")
                            cachedAPIService.invalidateAdminCache()
                            
                            // Schedule retry with force refresh
                            Task {
                                do {
                                    let freshData = try await cachedAPIService.getAdminDashboard(forceRefresh: true)
                                    await MainActor.run {
                                        dashboardData = freshData
                                        errorMessage = nil
                                        print("AdminDashboardView: Successfully loaded fresh data after cache clear")
                                    }
                                } catch {
                                    await MainActor.run {
                                        print("AdminDashboardView: Failed even after clearing cache: \(error)")
                                        errorMessage = "Failed to load dashboard data. Please check your connection and try again."
                                    }
                                }
                            }
                        }
                    case .authenticationError:
                        errorMessage = "Authentication failed. Please log in again."
                    case .networkError(let underlyingError):
                        // Handle cancellation specifically
                        if let nsError = underlyingError as NSError?,
                           nsError.domain == NSURLErrorDomain,
                           nsError.code == NSURLErrorCancelled {
                            print("AdminDashboardView: Network request was cancelled - this is normal for pull-to-refresh")
                            // Don't show error message for cancelled requests
                        } else {
                            errorMessage = "Network error: \(underlyingError.localizedDescription)"
                        }
                    case .serverError(let message):
                        errorMessage = "Server error: \(message)"
                    default:
                        errorMessage = networkError.localizedDescription
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Unexpected error: \(error.localizedDescription)"
                    print("Admin Dashboard Unexpected Error: \(error)")
                    
                    // If there's an unexpected error and we haven't force refreshed yet, try clearing cache
                    if !forceRefresh {
                        print("AdminDashboardView: Clearing cache due to unexpected error and retrying")
                        cachedAPIService.invalidateAdminCache()
                    }
                }
            }
        }
        
        await currentTask?.value
        
        await MainActor.run {
            isLoading = false
            print("AdminDashboardView: Finished loadAdminDashboard")
        }
    }
}

struct AdminDashboardStatsView: View {
    let stats: AdminStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                AdminStatCard(
                    title: "Total Employers",
                    value: "\(stats.totalEmployers)",
                    icon: "building.2",
                    color: .blue
                )
                
                AdminStatCard(
                    title: "Active Employees",
                    value: "\(stats.activeEmployees)",
                    icon: "person.3",
                    color: .green
                )
                
                AdminStatCard(
                    title: "Active Invoices",
                    value: "\(stats.activeInvoices ?? 0)",
                    icon: "doc.text",
                    color: .purple
                )
                
                AdminStatCard(
                    title: "Monthly Revenue",
                    value: "$\(String(format: "%.0f", stats.monthlyRevenue ?? 0))",
                    icon: "dollarsign.circle",
                    color: .green
                )
            }
        }
    }
}

struct AdminStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentEmployersView: View {
    let employers: [RecentEmployer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Employers")
                .font(.headline)
            
            if employers.isEmpty {
                Text("No recent employer registrations")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(employers) { employer in
                    RecentEmployerRow(employer: employer)
                }
            }
        }
    }
}

struct RecentEmployerRow: View {
    let employer: RecentEmployer
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(employer.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(employer.employeeCount) employees")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Registered \(employer.createdAt, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            StatusBadge(status: employer.status)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SystemAlertsView: View {
    let alerts: [SystemAlert]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("System Alerts")
                .font(.headline)
            
            if alerts.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("All systems operational")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                ForEach(alerts) { alert in
                    SystemAlertRow(alert: alert)
                }
            }
        }
    }
}

struct SystemAlertRow: View {
    let alert: SystemAlert
    
    var alertColor: Color {
        switch alert.type {
        case "warning":
            return .orange
        case "error":
            return .red
        case "info":
            return .blue
        default:
            return .gray
        }
    }
    
    var alertIcon: String {
        switch alert.type {
        case "warning":
            return "exclamationmark.triangle"
        case "error":
            return "xmark.circle"
        case "info":
            return "info.circle"
        default:
            return "bell"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: alertIcon)
                .foregroundColor(alertColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(alert.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(alertColor.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AdminEmployersView: View {
    @StateObject private var cachedAPIService = CachedAPIService()
    @State private var employers: [Employer] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var currentPage = 1
    @State private var hasMorePages = true
    @State private var selectedEmployer: Employer?
    
    var filteredEmployers: [Employer] {
        if searchText.isEmpty {
            return employers
        } else {
            return employers.filter { employer in
                employer.name?.localizedCaseInsensitiveContains(searchText) == true ||
                employer.primaryEmail?.localizedCaseInsensitiveContains(searchText) == true ||
                employer.contactEmail?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search employers", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                if isLoading && employers.isEmpty {
                    Spacer()
                    ProgressView("Loading employers...")
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await loadEmployers(reset: true)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else if filteredEmployers.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "building.2")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No employers found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        if !searchText.isEmpty {
                            Text("Try adjusting your search")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredEmployers) { employer in
                            EmployerRow(employer: employer, onTap: {
                                selectedEmployer = employer
                            })
                        }
                        
                        if hasMorePages && searchText.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .onAppear {
                                Task {
                                    await loadEmployers(reset: false, forceRefresh: false)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Employers")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadEmployers(reset: true, forceRefresh: true)
            }
        }
        .onAppear {
            if employers.isEmpty {
                Task {
                    await loadEmployers(reset: true, forceRefresh: false)
                }
            }
        }
        .sheet(item: $selectedEmployer) { employer in
            EmployerDetailView(employer: employer)
        }
    }
    
    private func loadEmployers(reset: Bool, forceRefresh: Bool = false) async {
        if reset {
            currentPage = 1
            hasMorePages = true
            employers.removeAll()
        }
        
        if !hasMorePages { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await cachedAPIService.getAllEmployers(
                page: currentPage,
                search: searchText.isEmpty ? nil : searchText,
                forceRefresh: forceRefresh
            )
            
            if reset {
                employers = response.employers
            } else {
                employers.append(contentsOf: response.employers)
            }
            
            hasMorePages = response.pagination.currentPage < response.pagination.totalPages
            currentPage += 1
        } catch let networkError as NetworkManager.NetworkError {
            switch networkError {
            case .decodingError:
                errorMessage = "Failed to load employers data. Please try again later."
                print("Employers Decoding Error: \(networkError)")
            case .authenticationError:
                errorMessage = "Authentication failed. Please log in again."
            case .serverError(let message):
                errorMessage = "Server error: \(message)"
            case .networkError(let underlyingError):
                errorMessage = "Network error: \(underlyingError.localizedDescription)"
            default:
                errorMessage = networkError.localizedDescription
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            print("Employers Unexpected Error: \(error)")
        }
        
        isLoading = false
    }
    
}

struct EmployerRow: View {
    let employer: Employer
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(employer.name ?? "Unnamed Employer")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if let email = employer.primaryEmail {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("ID: \(employer.id ?? 0)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let createdAt = employer.createdAt {
                            Text("Created \(createdAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let legalName = employer.legalName, legalName != employer.name {
                    HStack {
                        Image(systemName: "building")
                            .foregroundColor(.secondary)
                        Text("Legal: \(legalName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct EmployerDetailView: View {
    let employer: Employer
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiService = APIService()
    @State private var detailedEmployerInfo: DetailedEmployerResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Failed to Load Details")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            Task { await loadEmployerDetails() }
                        }
                        .buttonStyle(MerotButtonStyle())
                    }
                    .padding()
                } else if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading employer details...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if let detailedInfo = detailedEmployerInfo {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Section
                        EmployerHeaderCard(employer: detailedInfo.employer)
                        
                        // Statistics Overview
                        EmployerStatisticsCard(statistics: detailedInfo.statistics)
                        
                        // Contact Information
                        EmployerContactCard(employer: detailedInfo.employer)
                        
                        // Representatives
                        if !detailedInfo.representatives.isEmpty {
                            EmployerRepresentativesCard(representatives: detailedInfo.representatives)
                        }
                        
                        // Recent Employees
                        if !detailedInfo.recentEmployees.isEmpty {
                            RecentEmployeesCard(employees: detailedInfo.recentEmployees)
                        }
                        
                        // Recent Invoices (Including Unpaid)
                        if !detailedInfo.recentInvoices.isEmpty {
                            RecentInvoicesCard(invoices: detailedInfo.recentInvoices)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Employer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task { await loadEmployerDetails() }
        }
    }
    
    private func loadEmployerDetails() async {
        guard let employerId = employer.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let details = try await apiService.getDetailedEmployer(id: employerId)
            await MainActor.run {
                detailedEmployerInfo = details
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Employer Detail Cards

struct EmployerHeaderCard: View {
    let employer: Employer
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(employer.name ?? "Unnamed Employer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let legalName = employer.legalName, legalName != employer.name {
                        Text("Legal: \(legalName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "building.2")
                    .font(.system(size: 32))
                    .foregroundColor(.merotBlue)
            }
            
            if let createdAt = employer.createdAt {
                Text("Client since \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

struct EmployerStatisticsCard: View {
    let statistics: EmployerStatistics
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatisticTile(
                    title: "Total Employees",
                    value: "\(statistics.totalEmployees)",
                    subtitle: "\(statistics.activeEmployees) active",
                    icon: "person.3",
                    color: .blue
                )
                
                StatisticTile(
                    title: "Unpaid Invoices",
                    value: "\(statistics.unpaidInvoicesCount)",
                    subtitle: String(format: "$%.0f", statistics.unpaidInvoicesTotal),
                    icon: "doc.text.fill",
                    color: statistics.unpaidInvoicesCount > 0 ? .orange : .green
                )
                
                if statistics.overdueInvoicesCount > 0 {
                    StatisticTile(
                        title: "Overdue Invoices",
                        value: "\(statistics.overdueInvoicesCount)",
                        subtitle: String(format: "$%.0f", statistics.overdueInvoicesTotal),
                        icon: "exclamationmark.triangle.fill",
                        color: .red
                    )
                }
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

struct StatisticTile: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct EmployerContactCard: View {
    let employer: Employer
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                if let primaryEmail = employer.primaryEmail {
                    ContactRow(label: "Primary Email", value: primaryEmail, icon: "envelope.fill")
                }
                
                if let billingEmail = employer.billingEmail, billingEmail != employer.primaryEmail {
                    ContactRow(label: "Billing Email", value: billingEmail, icon: "envelope.badge.fill")
                }
                
                if let contactEmail = employer.contactEmail, contactEmail != employer.primaryEmail {
                    ContactRow(label: "Contact Email", value: contactEmail, icon: "envelope")
                }
            }
            
            // Address Section
            if hasAddress {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.merotBlue)
                        Text("Address")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let line1 = employer.addressLine1 {
                            Text(line1)
                        }
                        if let line2 = employer.addressLine2 {
                            Text(line2)
                        }
                        
                        HStack {
                            if let city = employer.addressCity {
                                Text(city)
                            }
                            if let state = employer.addressState {
                                Text(state)
                            }
                            if let zip = employer.addressZip {
                                Text(zip)
                            }
                        }
                        
                        if let country = employer.addressCountry {
                            Text(country)
                                .fontWeight(.medium)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var hasAddress: Bool {
        employer.addressLine1 != nil || 
        employer.addressCity != nil || 
        employer.addressState != nil || 
        employer.addressCountry != nil
    }
}

struct ContactRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.merotBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct EmployerRepresentativesCard: View {
    let representatives: [EmployerRepresentative]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Representatives (\(representatives.count))")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(representatives) { rep in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.merotBlue)
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rep.name.isEmpty ? "No Name" : rep.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(rep.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("Member since \(formatDate(rep.createdAt))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    if rep.id != representatives.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
        return dateString
    }
}

struct RecentEmployeesCard: View {
    let employees: [EmployerRecentEmployee]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Employees (\(employees.count))")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(employees) { employee in
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(employee.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(employee.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            if let department = employee.department {
                                Text(department)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            if let position = employee.position {
                                Text(position)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if employee.id != employees.last?.id {
                        Divider()
                    }
                }
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

struct RecentInvoicesCard: View {
    let invoices: [EmployerRecentInvoice]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Invoices (\(invoices.count))")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(invoices) { invoice in
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(invoice.overdue ? .red : statusColor(invoice.status))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(invoice.invoiceNumber)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                InvoiceStatusBadge(status: invoice.status, isOverdue: invoice.overdue)
                                
                                if let dueDate = invoice.dueDate {
                                    Text("Due: \(formatDate(dueDate))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text(String(format: "$%.0f", invoice.totalAmount))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(invoice.overdue ? .red : .primary)
                    }
                    
                    if invoice.id != invoices.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "paid": return .green
        case "sent", "processing": return .blue
        case "draft": return .orange
        default: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
        return dateString
    }
}

struct AdminEmployeesView: View {
    @StateObject private var cachedAPIService = CachedAPIService()
    @State private var employees: [Employee] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var currentPage = 1
    @State private var hasMorePages = true
    @State private var selectedEmployee: Employee?
    @State private var selectedStatus = "active" // Default to active
    
    let statusOptions = ["active", "pending", "terminated"]
    
    var filteredEmployees: [Employee] {
        if searchText.isEmpty {
            return employees
        } else {
            return employees.filter { employee in
                employee.firstName?.localizedCaseInsensitiveContains(searchText) == true ||
                employee.lastName?.localizedCaseInsensitiveContains(searchText) == true ||
                employee.email.localizedCaseInsensitiveContains(searchText) ||
                employee.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                searchBar
                statusFilter
                contentView
            }
            .navigationTitle("Employees")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadEmployees(reset: true, forceRefresh: true)
            }
        }
        .onAppear {
            if employees.isEmpty {
                Task {
                    await loadEmployees(reset: true, forceRefresh: false)
                }
            }
        }
        .onChange(of: searchText) { _, _ in
            Task {
                await loadEmployees(reset: true, forceRefresh: true)
            }
        }
        .sheet(item: $selectedEmployee) { employee in
            AdminEmployeeDetailView(employee: employee)
                .onDisappear {
                    // Refresh the employee list when the detail view is dismissed
                    Task {
                        await loadEmployees(reset: true, forceRefresh: true)
                    }
                }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search employees", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var statusFilter: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Text("Filter:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(employees.count) employees")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            statusButtons
        }
        .padding(.top, 12)
    }
    
    private var statusButtons: some View {
        HStack(spacing: 0) {
            ForEach(Array(statusOptions.enumerated()), id: \.offset) { index, status in
                Button(action: {
                    selectedStatus = status
                    Task {
                        await loadEmployees(reset: true, forceRefresh: true)
                    }
                }) {
                    Text(status.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedStatus == status ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedStatus == status ? 
                                Color.blue : Color.clear
                        )
                        .clipShape(
                            RoundedCorner(
                                radius: 10,
                                corners: corners(for: index, total: statusOptions.count)
                            )
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
        )
        .padding(.horizontal)
    }
    
    private var contentView: some View {
        Group {
            if isLoading && employees.isEmpty {
                Spacer()
                ProgressView("Loading employees...")
                Spacer()
            } else if let errorMessage = errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text("Error")
                        .font(.headline)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        Task {
                            await loadEmployees(reset: true)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                Spacer()
            } else if filteredEmployees.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "person.3")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No employees found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    if !searchText.isEmpty {
                        Text("Try adjusting your search")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            } else {
                List {
                    ForEach(filteredEmployees) { employee in
                        AdminEmployeeRow(employee: employee) {
                            selectedEmployee = employee
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.visible)
                    }
                    
                    if hasMorePages && searchText.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .onAppear {
                            Task {
                                await loadEmployees(reset: false, forceRefresh: false)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .environment(\.defaultMinListRowHeight, 0)
            }
        }
    }
    
    private func loadEmployees(reset: Bool, forceRefresh: Bool = false) async {
        if reset {
            currentPage = 1
            hasMorePages = true
            employees.removeAll()
        }
        
        if !hasMorePages { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await cachedAPIService.getAllEmployees(
                page: currentPage,
                search: searchText.isEmpty ? nil : searchText,
                status: selectedStatus,
                forceRefresh: forceRefresh
            )
            
            if reset {
                employees = response.employees
            } else {
                employees.append(contentsOf: response.employees)
            }
            
            hasMorePages = response.pagination.currentPage < response.pagination.totalPages
            currentPage += 1
        } catch let networkError as NetworkManager.NetworkError {
            switch networkError {
            case .decodingError:
                errorMessage = "Failed to load employees data. Please try again later."
                print("Employees Decoding Error: \(networkError)")
            case .authenticationError:
                errorMessage = "Authentication failed. Please log in again."
            case .serverError(let message):
                errorMessage = "Server error: \(message)"
            case .networkError(let underlyingError):
                errorMessage = "Network error: \(underlyingError.localizedDescription)"
            default:
                errorMessage = networkError.localizedDescription
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            print("Employees Unexpected Error: \(error)")
        }
        
        isLoading = false
    }
    
    private func corners(for index: Int, total: Int) -> UIRectCorner {
        if index == 0 {
            return [.topLeft, .bottomLeft]
        } else if index == total - 1 {
            return [.topRight, .bottomRight]
        } else {
            return []
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct AdminEmployeeRow: View {
    let employee: Employee
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar placeholder
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(employee.fullName.prefix(1))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
                
                // Main content
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(employee.fullName)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Status badge
                        Text(employee.status.capitalized)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.15))
                            .foregroundColor(statusColor)
                            .cornerRadius(4)
                    }
                    
                    Text(employee.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        if let department = employee.department {
                            HStack(spacing: 4) {
                                Image(systemName: "building.2")
                                    .font(.caption2)
                                Text(formatDepartmentName(department))
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        if let employeeId = employee.employeeId {
                            HStack(spacing: 4) {
                                Image(systemName: "number")
                                    .font(.caption2)
                                Text(employeeId)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let salaryDetail = employee.salaryDetail, let gross = salaryDetail.grossSalary {
                            Text("$\(Int(gross))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch employee.status {
        case "active": return .green
        case "pending": return .orange
        case "terminated": return .red
        default: return .gray
        }
    }
    
    private func formatDepartmentName(_ department: String) -> String {
        switch department {
        case "business_development": return "Business Dev"
        case "customer_service": return "Customer Service"
        case "human_resources": return "HR"
        case "social_media": return "Social Media"
        default: return department.capitalized
        }
    }
}

struct AdminEmployeeDetailView: View {
    let employee: Employee
    @Environment(\.dismiss) private var dismiss
    @State private var detailedEmployee: Employee?
    @State private var isLoadingDetails = false
    @StateObject private var cachedAPIService = CachedAPIService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(employee.fullName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Label(employee.email, systemImage: "envelope")
                            .foregroundColor(.secondary)
                        
                        if let phone = employee.phoneNumber {
                            Label(phone, systemImage: "phone")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Employment Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Employment")
                            .font(.headline)
                        
                        DetailRow(label: "Status", value: employee.status.capitalized)
                        
                        if let employment = employee.employment {
                            if let position = employment.employmentPosition {
                                DetailRow(label: "Position", value: position)
                            }
                            
                            if let startDate = employment.startDate {
                                DetailRow(label: "Start Date", value: startDate.formatted(date: .abbreviated, time: .omitted))
                            }
                            
                            if let endDate = employment.endDate {
                                DetailRow(label: "End Date", value: endDate.formatted(date: .abbreviated, time: .omitted))
                            }
                        }
                        
                        if let department = employee.department {
                            DetailRow(label: "Department", value: department)
                        }
                        
                        if let title = employee.title {
                            DetailRow(label: "Title", value: title)
                        }
                    }
                    
                    Divider()
                    
                    // Salary Details
                    if let salaryDetail = employee.salaryDetail {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Salary Information")
                                .font(.headline)
                            
                            DetailRow(label: "Gross Salary", value: "$\(Int(salaryDetail.grossSalary ?? 0))")
                            DetailRow(label: "Net Salary", value: "$\(Int(salaryDetail.netSalary ?? 0))")
                            
                        }
                        
                        Divider()
                    }
                    
                    // Personal Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Information")
                            .font(.headline)
                        
                        DetailRow(label: "Employee ID", value: employee.employeeId ?? "N/A")
                        
                        if let location = employee.location {
                            DetailRow(label: "Location", value: location)
                        }
                        
                        if let country = employee.country {
                            DetailRow(label: "Country", value: country)
                        }
                        
                        DetailRow(label: "Account Created", value: employee.createdAt.formatted(date: .abbreviated, time: .shortened))
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Divider()
                        
                        Button(action: {
                            Task {
                                await loadDetailedEmployeeData()
                            }
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Employee")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Employee Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isLoadingDetails {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Button("Edit") {
                            Task {
                                await loadDetailedEmployeeData()
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $detailedEmployee) { detailedEmp in
            AdminEmployeeEditView(employee: detailedEmp) { updatedEmployee in
                // Handle successful update - the parent view will refresh
                detailedEmployee = nil  // This will dismiss the sheet
                dismiss()
            }
        }
    }
    
    private func loadDetailedEmployeeData() async {
        await MainActor.run {
            isLoadingDetails = true
        }
        
        do {
            let detailed = try await cachedAPIService.getAdminEmployee(id: employee.id, forceRefresh: true)
            await MainActor.run {
                print("Successfully loaded detailed employee data")
                print("  ID: \(detailed.id)")
                print("  Name: \(detailed.fullName)")
                print("  Phone: \(detailed.phoneNumber ?? "nil")")
                print("  Address: \(detailed.address ?? "nil")")
                print("  City: \(detailed.city ?? "nil")")
                
                detailedEmployee = detailed  // This will trigger the sheet
                isLoadingDetails = false
            }
        } catch {
            print("Failed to load detailed employee data: \(error)")
            print("Error details: \(error.localizedDescription)")
            if let networkError = error as? NetworkManager.NetworkError {
                print("Network error: \(networkError)")
            }
            await MainActor.run {
                // Use basic data as fallback
                detailedEmployee = employee  // This will trigger the sheet
                isLoadingDetails = false
            }
        }
    }
}

struct AdminSettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var cachedAPIService = CachedAPIService()
    @State private var showingCacheSettings = false
    @State private var showingSystemInfo = false
    @State private var showingDataExport = false
    @State private var showingUserManagement = false
    @State private var showingSecuritySettings = false
    @State private var showingNotificationSettings = false
    @State private var showingLogout = false
    @State private var isLoggingOut = false
    
    // Settings state
    @State private var enablePushNotifications = true
    @State private var enableEmailNotifications = true
    @State private var enableAutoBackup = true
    @State private var dataRetentionDays = 90
    @State private var enableDebugLogging = false
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section("Account") {
                    Button(action: {
                        showingUserManagement = true
                    }) {
                        HStack {
                            Label("User Management", systemImage: "person.2.circle")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        showingSecuritySettings = true
                    }) {
                        HStack {
                            Label("Security Settings", systemImage: "lock.shield")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button(action: {
                        showingDataExport = true
                    }) {
                        HStack {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Label("Data Retention", systemImage: "calendar.badge.clock")
                        Spacer()
                        Picker("Days", selection: $dataRetentionDays) {
                            Text("30 days").tag(30)
                            Text("90 days").tag(90)
                            Text("180 days").tag(180)
                            Text("1 year").tag(365)
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Toggle(isOn: $enableAutoBackup) {
                        Label("Auto Backup", systemImage: "icloud.and.arrow.up")
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle(isOn: $enablePushNotifications) {
                        Label("Push Notifications", systemImage: "bell")
                    }
                    
                    Toggle(isOn: $enableEmailNotifications) {
                        Label("Email Notifications", systemImage: "envelope")
                    }
                    
                    Button(action: {
                        showingNotificationSettings = true
                    }) {
                        HStack {
                            Label("Notification Preferences", systemImage: "bell.badge")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // Performance Section
                Section("Performance") {
                    Button(action: {
                        showingCacheSettings = true
                    }) {
                        HStack {
                            Label("Cache Settings", systemImage: "externaldrive")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Toggle(isOn: $enableDebugLogging) {
                        Label("Debug Logging", systemImage: "doc.text.magnifyingglass")
                    }
                }
                
                // System Section
                Section("System") {
                    Button(action: {
                        showingSystemInfo = true
                    }) {
                        HStack {
                            Label("System Information", systemImage: "info.circle")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await clearAllCaches()
                        }
                    }) {
                        Label("Clear All Data", systemImage: "trash")
                            .foregroundColor(.orange)
                    }
                }
                
                // Account Actions Section
                Section("Account Actions") {
                    Button(action: {
                        showingLogout = true
                    }) {
                        HStack {
                            if isLoggingOut {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Logging out...")
                            } else {
                                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                        .foregroundColor(.red)
                    }
                    .disabled(isLoggingOut)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingCacheSettings) {
            CacheSettingsView()
        }
        .sheet(isPresented: $showingSystemInfo) {
            SystemInfoView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
        .sheet(isPresented: $showingSecuritySettings) {
            SecuritySettingsView()
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .alert("Logout", isPresented: $showingLogout) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                Task {
                    await performLogout()
                }
            }
        } message: {
            Text("Are you sure you want to logout? Any unsaved changes will be lost.")
        }
    }
    
    private func clearAllCaches() async {
        await cachedAPIService.cancelAllRequests()
        cachedAPIService.invalidateAllCache()
    }
    
    private func performLogout() async {
        await MainActor.run {
            isLoggingOut = true
        }
        
        // Clear caches and cancel requests
        await clearAllCaches()
        
        // Perform logout
        await authService.logout()
        
        await MainActor.run {
            isLoggingOut = false
        }
    }
}

struct AdminEmployeeEditView: View {
    let employee: Employee
    let onSave: (Employee) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cachedAPIService = CachedAPIService()
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var phoneNumber: String
    @State private var personalEmail: String
    @State private var department: String
    @State private var status: String
    @State private var employeeType: String
    @State private var title: String
    @State private var location: String
    @State private var address: String
    @State private var city: String
    @State private var country: String
    @State private var postcode: String
    @State private var personalIdNumber: String
    @State private var fullNameCyr: String
    @State private var cityCyr: String
    @State private var addressCyr: String
    @State private var countryCyr: String
    
    // Salary Detail Fields
    @State private var baseSalary: String
    @State private var hourlySalary: String
    @State private var variableSalary: String
    @State private var deductions: String
    @State private var netSalary: String
    @State private var grossSalary: String
    @State private var seniority: String
    @State private var bankName: String
    @State private var bankAccountNumber: String
    @State private var onMaternity: Bool
    @State private var merotFee: String
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var isLookingUpBank = false
    
    let statusOptions = ["pending", "active", "terminated"]
    let employeeTypeOptions = ["internal", "external"]
    let countryOptions = ["north_macedonia", "kosovo", "albania", "bulgaria", "serbia", "montenegro"]
    let departmentOptions = ["executive", "management", "sales", "marketing", "business_development", "technology", "customer_service", "human_resources", "finance", "accounting", "social_media", "operations", "construction", "other"]
    
    init(employee: Employee, onSave: @escaping (Employee) -> Void) {
        self.employee = employee
        self.onSave = onSave
        
        print("AdminEmployeeEditView init with employee: \(employee.id)")
        print("  firstName: \(employee.firstName ?? "nil")")
        print("  lastName: \(employee.lastName ?? "nil")")
        print("  email: \(employee.email)")
        print("  phoneNumber: \(employee.phoneNumber ?? "nil")")
        print("  address: \(employee.address ?? "nil")")
        print("  city: \(employee.city ?? "nil")")
        print("  salaryDetail: \(employee.salaryDetail != nil ? "present" : "nil")")
        
        _firstName = State(initialValue: employee.firstName ?? "")
        _lastName = State(initialValue: employee.lastName ?? "")
        _email = State(initialValue: employee.email)
        _phoneNumber = State(initialValue: employee.phoneNumber ?? "")
        _personalEmail = State(initialValue: employee.personalEmail ?? "")
        _department = State(initialValue: employee.department ?? "")
        _status = State(initialValue: employee.status)
        _employeeType = State(initialValue: employee.employeeType ?? "internal")
        _title = State(initialValue: employee.title ?? "")
        _location = State(initialValue: employee.location ?? "")
        _address = State(initialValue: employee.address ?? "")
        _city = State(initialValue: employee.city ?? "")
        _country = State(initialValue: employee.country ?? "")
        _postcode = State(initialValue: employee.postcode ?? "")
        _personalIdNumber = State(initialValue: employee.personalIdNumber ?? "")
        _fullNameCyr = State(initialValue: employee.fullNameCyr ?? "")
        _cityCyr = State(initialValue: employee.cityCyr ?? "")
        _addressCyr = State(initialValue: employee.addressCyr ?? "")
        _countryCyr = State(initialValue: employee.countryCyr ?? "")
        
        // Initialize salary detail fields
        _baseSalary = State(initialValue: employee.salaryDetail?.baseSalary.map { String($0) } ?? "")
        _hourlySalary = State(initialValue: employee.salaryDetail?.hourlySalary.map { String($0) } ?? "")
        _variableSalary = State(initialValue: employee.salaryDetail?.variableSalary.map { String($0) } ?? "")
        _deductions = State(initialValue: employee.salaryDetail?.deductions.map { String($0) } ?? "")
        _netSalary = State(initialValue: employee.salaryDetail?.netSalary.map { String($0) } ?? "")
        _grossSalary = State(initialValue: employee.salaryDetail?.grossSalary.map { String($0) } ?? "")
        _seniority = State(initialValue: employee.salaryDetail?.seniority.map { String($0) } ?? "")
        _bankName = State(initialValue: employee.salaryDetail?.bankName ?? "")
        _bankAccountNumber = State(initialValue: employee.salaryDetail?.bankAccountNumber ?? "")
        _onMaternity = State(initialValue: employee.salaryDetail?.onMaternity ?? false)
        _merotFee = State(initialValue: employee.salaryDetail?.merotFee.map { String($0) } ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    HStack {
                        Text("First Name")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $firstName)
                            .autocapitalization(.words)
                    }
                    
                    HStack {
                        Text("Last Name")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $lastName)
                            .autocapitalization(.words)
                    }
                    
                    HStack {
                        Text("Email")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    HStack {
                        Text("Personal Email")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $personalEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    HStack {
                        Text("Phone Number")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }
                    
                    HStack {
                        Text("ID Number")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $personalIdNumber)
                    }
                }
                
                Section("Employment") {
                    Picker("Status", selection: $status) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status.capitalized).tag(status)
                        }
                    }
                    
                    Picker("Employee Type", selection: $employeeType) {
                        ForEach(employeeTypeOptions, id: \.self) { type in
                            Text(type.capitalized).tag(type)
                        }
                    }
                    
                    Picker("Department", selection: $department) {
                        ForEach(departmentOptions, id: \.self) { dept in
                            Text(formatDepartmentName(dept)).tag(dept)
                        }
                    }
                    
                    HStack {
                        Text("Title")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $title)
                            .autocapitalization(.words)
                    }
                    
                }
                
                Section("Location & Address") {
                    HStack {
                        Text("Location")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $location)
                            .autocapitalization(.words)
                    }
                    
                    HStack {
                        Text("Address")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $address)
                            .autocapitalization(.words)
                    }
                    
                    HStack {
                        Text("City")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $city)
                            .autocapitalization(.words)
                    }
                    
                    Picker("Country", selection: $country) {
                        ForEach(countryOptions, id: \.self) { countryCode in
                            Text(formatCountryName(countryCode)).tag(countryCode)
                        }
                    }
                    
                    HStack {
                        Text("Postcode")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $postcode)
                            .autocapitalization(.allCharacters)
                    }
                }
                
                if country == "north_macedonia" {
                    Section("Cyrillic Information") {
                        HStack {
                            Text("Full Name (Cyr)")
                                .frame(width: 120, alignment: .leading)
                                .foregroundColor(.secondary)
                            TextField("", text: $fullNameCyr)
                        }
                        
                        HStack {
                            Text("Address (Cyr)")
                                .frame(width: 120, alignment: .leading)
                                .foregroundColor(.secondary)
                            TextField("", text: $addressCyr)
                        }
                        
                        HStack {
                            Text("City (Cyr)")
                                .frame(width: 120, alignment: .leading)
                                .foregroundColor(.secondary)
                            TextField("", text: $cityCyr)
                        }
                        
                        HStack {
                            Text("Country (Cyr)")
                                .frame(width: 120, alignment: .leading)
                                .foregroundColor(.secondary)
                            TextField("", text: $countryCyr)
                        }
                    }
                }
                
                Section("Salary Details") {
                    HStack {
                        Text("Base Salary")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $baseSalary)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Hourly Salary")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $hourlySalary)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Variable Salary")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $variableSalary)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Deductions")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $deductions)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Net Salary")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $netSalary)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Gross Salary")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $grossSalary)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Seniority")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $seniority)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Merot Fee")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $merotFee)
                            .keyboardType(.decimalPad)
                    }
                    
                    Toggle("On Maternity", isOn: $onMaternity)
                }
                
                Section("Banking Information") {
                    HStack {
                        Text("Account Number")
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(.secondary)
                        TextField("", text: $bankAccountNumber)
                            .keyboardType(.numberPad)
                            .onChange(of: bankAccountNumber) { _, newValue in
                                Task {
                                    await lookupBankName(for: newValue)
                                }
                            }
                        
                        if isLookingUpBank {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    HStack {
                        Text("Bank Name")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(bankName.isEmpty ? "Auto-detected" : bankName)
                            .foregroundColor(bankName.isEmpty ? .secondary : .primary)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Employee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveEmployee()
                        }
                    }
                    .disabled(isLoading || firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                }
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func saveEmployee() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let updateRequest = AdminEmployeeUpdateRequest(
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            email: email.isEmpty ? nil : email,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            personalEmail: personalEmail.isEmpty ? nil : personalEmail,
            department: department.isEmpty ? nil : department,
            status: status,
            employeeType: employeeType.isEmpty ? nil : employeeType,
            title: title.isEmpty ? nil : title,
            location: location.isEmpty ? nil : location,
            address: address.isEmpty ? nil : address,
            city: city.isEmpty ? nil : city,
            country: country.isEmpty ? nil : country,
            postcode: postcode.isEmpty ? nil : postcode,
            personalIdNumber: personalIdNumber.isEmpty ? nil : personalIdNumber,
            fullNameCyr: fullNameCyr.isEmpty ? nil : fullNameCyr,
            cityCyr: cityCyr.isEmpty ? nil : cityCyr,
            addressCyr: addressCyr.isEmpty ? nil : addressCyr,
            countryCyr: countryCyr.isEmpty ? nil : countryCyr,
            salaryDetail: createSalaryDetail()
        )
        
        do {
            let updatedEmployee = try await cachedAPIService.updateAdminEmployee(id: employee.id, employee: updateRequest)
            
            await MainActor.run {
                isLoading = false
                onSave(updatedEmployee)
                dismiss()
            }
        } catch let networkError as NetworkManager.NetworkError {
            await MainActor.run {
                isLoading = false
                switch networkError {
                case .authenticationError:
                    errorMessage = "Authentication failed. Please log in again."
                case .serverError(let message):
                    errorMessage = message
                case .networkError(let underlyingError):
                    errorMessage = "Network error: \(underlyingError.localizedDescription)"
                default:
                    errorMessage = "Failed to update employee: \(networkError.localizedDescription)"
                }
                showingErrorAlert = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Unexpected error: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    private func createSalaryDetail() -> AdminSalaryDetailUpdateRequest? {
        // Check if any salary detail fields have values
        let hasAnyValue = !baseSalary.isEmpty || !hourlySalary.isEmpty || !variableSalary.isEmpty ||
                         !deductions.isEmpty || !netSalary.isEmpty || !grossSalary.isEmpty ||
                         !seniority.isEmpty || !bankName.isEmpty || !bankAccountNumber.isEmpty ||
                         onMaternity || !merotFee.isEmpty
        
        guard hasAnyValue else { return nil }
        
        return AdminSalaryDetailUpdateRequest(
            baseSalary: baseSalary.isEmpty ? nil : Double(baseSalary),
            hourlySalary: hourlySalary.isEmpty ? nil : Double(hourlySalary),
            variableSalary: variableSalary.isEmpty ? nil : Double(variableSalary),
            deductions: deductions.isEmpty ? nil : Double(deductions),
            netSalary: netSalary.isEmpty ? nil : Double(netSalary),
            grossSalary: grossSalary.isEmpty ? nil : Double(grossSalary),
            seniority: seniority.isEmpty ? nil : Double(seniority),
            bankName: bankName.isEmpty ? nil : bankName,
            bankAccountNumber: bankAccountNumber.isEmpty ? nil : bankAccountNumber,
            onMaternity: onMaternity,
            merotFee: merotFee.isEmpty ? nil : Double(merotFee)
        )
    }
    
    @MainActor
    private func lookupBankName(for accountNumber: String) async {
        // Only lookup if we have a valid account number and country
        guard !accountNumber.isEmpty && !country.isEmpty else {
            bankName = ""
            return
        }
        
        // Don't lookup for very short account numbers
        guard accountNumber.count >= 2 else {
            bankName = ""
            return
        }
        
        isLookingUpBank = true
        
        do {
            let result = try await cachedAPIService.lookupBankName(accountNumber: accountNumber, country: country)
            bankName = result.bankName
        } catch {
            print("Bank lookup error: \(error)")
            // Don't show error to user, just leave bank name empty
            bankName = ""
        }
        
        isLookingUpBank = false
    }
    
    private func formatDepartmentName(_ department: String) -> String {
        switch department {
        case "business_development":
            return "Business Development"
        case "customer_service":
            return "Customer Service"
        case "human_resources":
            return "Human Resources"
        case "social_media":
            return "Social Media"
        default:
            return department.capitalized
        }
    }
    
    private func formatCountryName(_ countryCode: String) -> String {
        switch countryCode {
        case "north_macedonia":
            return "North Macedonia"
        default:
            return countryCode.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

#Preview {
    AdminDashboardView()
}