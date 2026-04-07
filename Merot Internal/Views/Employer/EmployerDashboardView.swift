import SwiftUI

struct EmployerDashboardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var dashboard: EmployerDashboardData?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading && dashboard == nil {
                    LoadingView()
                } else if let error {
                    VStack(spacing: 16) {
                        ErrorBanner(message: error)
                        Button("Retry") { Task { await loadDashboard() } }
                            .foregroundColor(.accent)
                    }
                    .padding(.top, 40)
                } else if let d = dashboard {
                    VStack(spacing: 12) {
                        // Welcome card
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome, \(auth.user?.full_name ?? auth.user?.first_name ?? "")")
                                        .font(.headline).foregroundColor(.white)
                                    if let company = auth.user?.department {
                                        Text(company)
                                            .font(.caption).foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                Spacer()
                                Image(systemName: "building.2.fill")
                                    .font(.title2).foregroundColor(.accent)
                            }
                        }

                        // Stats
                        if let stats = d.stats {
                            HStack(spacing: 10) {
                                StatCard(icon: "person.3.fill", title: "Employees", value: "\(stats.total_employees ?? 0)")
                                StatCard(icon: "person.fill.checkmark", title: "Active", value: "\(stats.active_employees ?? 0)", color: .green)
                            }
                            HStack(spacing: 10) {
                                StatCard(icon: "calendar.badge.clock", title: "Pending PTO", value: "\(stats.pending_time_off_requests ?? 0)", color: .yellow)
                                StatCard(icon: "person.badge.plus", title: "Recent Hires", value: "\(stats.recent_hires ?? 0)", color: .blue)
                            }
                            if let payrollDate = stats.upcoming_payroll_date {
                                CardView {
                                    HStack {
                                        Image(systemName: "banknote.fill")
                                            .foregroundColor(.accent)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Next Payroll")
                                                .font(.caption).foregroundColor(.white.opacity(0.4))
                                            Text(formatDate(payrollDate))
                                                .font(.subheadline).bold().foregroundColor(.white)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }

                        // Recent Employees
                        if let employees = d.recent_employees, !employees.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Team Members")
                                        .font(.caption).foregroundColor(.white.opacity(0.4))
                                    ForEach(employees) { emp in
                                        HStack(spacing: 10) {
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Text(initials(emp.full_name))
                                                        .font(.caption2).bold()
                                                        .foregroundColor(.accent)
                                                )
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(emp.full_name ?? "-")
                                                    .font(.subheadline).foregroundColor(.white)
                                                HStack(spacing: 6) {
                                                    if let pos = emp.position {
                                                        Text(pos)
                                                            .font(.caption2).foregroundColor(.white.opacity(0.4))
                                                    }
                                                    if let dept = emp.department {
                                                        Text(dept)
                                                            .font(.caption2).foregroundColor(.white.opacity(0.3))
                                                    }
                                                }
                                            }
                                            Spacer()
                                            StatusBadge(status: emp.status ?? "active")
                                        }
                                    }
                                }
                            }
                        }

                        // Pending Time Off
                        if let pending = d.pending_time_off_requests, !pending.isEmpty {
                            CardView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Pending Time Off Requests")
                                        .font(.caption).foregroundColor(.white.opacity(0.4))
                                    ForEach(pending) { req in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(req.employee_name ?? "-")
                                                    .font(.subheadline).foregroundColor(.white)
                                                Text("\(formatDateShort(req.start_date)) - \(formatDateShort(req.end_date))")
                                                    .font(.caption2).foregroundColor(.white.opacity(0.4))
                                            }
                                            Spacer()
                                            Text("\(req.days ?? 0) days")
                                                .font(.caption2).foregroundColor(.accent)
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
        error = nil
        do {
            let res: EmployerDashboardResponse = try await APIService.shared.request("GET", "/employers/dashboard")
            dashboard = res.data
        } catch {
            self.error = "Failed to load dashboard"
            #if DEBUG
            print("[EmployerDash] Error: \(error)")
            #endif
        }
        isLoading = false
    }

    private func initials(_ name: String?) -> String {
        guard let name = name else { return "?" }
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(f)\(l)".uppercased()
    }
}
