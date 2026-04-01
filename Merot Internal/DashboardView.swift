import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var apiService = APIService()
    @State private var dashboardData: DashboardData?
    @State private var employerProfile: EmployerProfileData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingProfile = false
    @State private var selectedTab = 0
    @State private var employeeFilter: String? = nil
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading dashboard...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let dashboardData = dashboardData {
                        DashboardStatsView(stats: dashboardData.stats, selectedTab: $selectedTab, employeeFilter: $employeeFilter)
                        
                        if let recentActivities = dashboardData.recentActivities {
                            RecentActivitiesView(activities: recentActivities)
                        }
                    } else if let errorMessage = errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Error loading dashboard")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Retry") {
                                Task {
                                    await loadDashboard()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle(employerProfile?.employer.name ?? "Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let employerName = employerProfile?.employer.name {
                        VStack(spacing: 0) {
                            Text(employerName)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("Dashboard")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                    }
                }
                
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
            .refreshable {
                await loadDashboard()
            }
            .sheet(isPresented: $showingProfile) {
                EmployerProfileView()
                    .environmentObject(authService)
            }
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Dashboard")
            }
            .tag(0)
            
            EmployeesView(filterFromDashboard: $employeeFilter)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Employees")
                }
                .tag(1)
            
            PendingRequestsView()
                .tabItem {
                    Image(systemName: "clock.badge.exclamationmark")
                    Text("Pending")
                }
                .tag(2)
            
            InvoicesView()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Invoices")
                }
                .tag(3)
            
            HolidaysView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("Holidays")
                }
                .tag(4)
        }
        .onAppear {
            Task {
                await loadDashboard()
                loadEmployerProfile()
            }
        }
        .onChange(of: selectedTab) { newTab in
            // Refresh dashboard data when returning to dashboard tab
            if newTab == 0 {
                Task {
                    await loadDashboard()
                }
            }
        }
    }
    
    private func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        
        do {
            dashboardData = try await apiService.getDashboard()
        } catch {
            if let networkError = error as? NetworkManager.NetworkError {
                if case .authenticationError = networkError {
                    let refreshed = await authService.refreshToken()
                    if refreshed {
                        await loadDashboard()
                        return
                    }
                }
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    private func loadEmployerProfile() {
        APIService.shared.fetchEmployerProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.employerProfile = profile
                case .failure(let error):
                    print("Failed to load employer profile: \(error)")
                }
            }
        }
    }
}

struct DashboardStatsView: View {
    let stats: DashboardStats
    @Binding var selectedTab: Int
    @Binding var employeeFilter: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Total Employees",
                    value: "\(stats.totalEmployees)",
                    icon: "person.3",
                    color: .blue
                ) {
                    employeeFilter = "all"
                    selectedTab = 1 // Navigate to Employees tab
                }
                
                StatCard(
                    title: "Active Employees",
                    value: "\(stats.activeEmployees ?? 0)",
                    icon: "person.badge.plus",
                    color: .green
                ) {
                    employeeFilter = "active"
                    selectedTab = 1 // Navigate to Employees tab with active filter
                }
                
                StatCard(
                    title: "Pending Requests",
                    value: "\(stats.pendingTimeOffRequests ?? 0)",
                    icon: "clock.badge.exclamationmark",
                    color: .orange
                ) {
                    selectedTab = 2 // Navigate to Pending tab
                }
                
                StatCard(
                    title: "On Leave Today",
                    value: "\(stats.employeesOnLeaveToday ?? 0)",
                    icon: "calendar.badge.minus",
                    color: .purple
                ) {
                    employeeFilter = "all"
                    selectedTab = 1 // Navigate to Employees tab
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentActivitiesView: View {
    let activities: [DashboardActivity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activities")
                .font(.headline)
            
            if activities.isEmpty {
                Text("No recent activities")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(activities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: DashboardActivity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.employeeName ?? "Unknown Employee")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(activity.type.replacingOccurrences(of: "_", with: " ").capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let startDate = activity.startDate, let endDate = activity.endDate {
                    Text("\(formatDateObject(startDate)) - \(formatDateObject(endDate))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                StatusBadge(status: activity.status ?? "pending")
                
                if let days = activity.days {
                    Text("\(days) day\(days == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ssZ",      // ISO 8601 with timezone
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",  // ISO 8601 with milliseconds
            "yyyy-MM-dd'T'HH:mm:ss",       // ISO 8601 without timezone
            "yyyy-MM-dd"                   // Date only
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            
            if let date = formatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d, yyyy"
                return displayFormatter.string(from: date)
            }
        }
        
        return dateString
    }
    
    private func formatDateObject(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        return displayFormatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch status.lowercased() {
        case "pending":
            return .orange.opacity(0.2)
        case "approved":
            return .green.opacity(0.2)
        case "denied":
            return .red.opacity(0.2)
        case "active":
            return .green.opacity(0.2)
        default:
            return .gray.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "approved":
            return .green
        case "denied":
            return .red
        case "active":
            return .green
        default:
            return .gray
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authService.currentUser {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(user.email)
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        if let employer = user.employer {
                            Text(employer.name ?? "Unknown Company")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Button("Sign Out") {
                    Task {
                        await authService.logout()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}