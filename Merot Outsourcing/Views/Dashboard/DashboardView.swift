import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Welcome
                    Text("Welcome, \(auth.user?.first_name ?? "Admin")")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    if let error = vm.error {
                        ErrorBanner(message: error)
                    }

                    // Stats grid
                    if let stats = vm.stats {
                        statsGrid(stats).padding(.horizontal)
                    }

                    // Upcoming payroll & holiday
                    HStack(spacing: 12) {
                        if let payroll = vm.upcomingPayroll {
                            payrollCard(payroll)
                        }
                        if let holiday = vm.upcomingHoliday {
                            holidayCard(holiday)
                        }
                    }
                    .padding(.horizontal)

                    // Pending items
                    if !vm.pendingItems.isEmpty {
                        SectionHeader(title: "Pending Items")
                        ForEach(vm.pendingItems) { item in
                            pendingItemRow(item).padding(.horizontal)
                        }
                    }

                    // Legal entities
                    if !vm.entities.isEmpty {
                        SectionHeader(title: "Legal Entities")
                        ForEach(vm.entities) { entity in
                            entityRow(entity).padding(.horizontal)
                        }
                    }

                    // Recent activity
                    if !vm.recentActivity.isEmpty {
                        SectionHeader(title: "Recent Activity")
                        ForEach(vm.recentActivity) { activity in
                            activityRow(activity).padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color.brand.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .brandNavBar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { auth.logout() } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .refreshable { await vm.load() }
        }
        .task { await vm.load() }
    }

    // MARK: - Stats Grid

    private func statsGrid(_ stats: DashboardStats) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            StatCard(icon: "person.fill", title: "Active Employees", value: "\(stats.active_employees ?? 0)")
            StatCard(icon: "clock.fill", title: "Clocked In", value: "\(stats.clocked_in ?? 0)", color: .green)
            StatCard(icon: "sun.max.fill", title: "On Leave", value: "\(stats.on_leave ?? 0)", color: .orange)
            StatCard(icon: "doc.text.fill", title: "Outstanding", value: "\(stats.outstanding_invoices ?? 0)", color: .yellow)
            StatCard(icon: "building.2.fill", title: "Employers", value: "\(stats.employers_count ?? 0)", color: .blue)
            StatCard(icon: "calendar.badge.clock", title: "Pending Time Off", value: "\(stats.pending_time_off ?? 0)", color: .purple)
        }
    }

    // MARK: - Payroll Card

    private func payrollCard(_ payroll: UpcomingPayroll) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "banknote.fill")
                .foregroundColor(.accent)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Next Payroll")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text("\(payroll.days_until ?? 0) days")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    // MARK: - Holiday Card

    private func holidayCard(_ holiday: UpcomingHoliday) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .foregroundColor(.accent)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Next Holiday")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text(holiday.name ?? "-")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(formatDate(holiday.date))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    // MARK: - Pending Item

    private func pendingItemRow(_ item: PendingItem) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.warning.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Text("\(item.count)")
                        .font(.caption).bold()
                        .foregroundColor(.warning)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(item.label)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("\(item.count) pending")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Entity Row

    private func entityRow(_ entity: LegalEntity) -> some View {
        HStack(spacing: 12) {
            Text(entity.country ?? "-")
                .font(.caption).bold()
                .foregroundColor(.accent)
                .padding(6)
                .background(Color.accent.opacity(0.15))
                .cornerRadius(6)
            VStack(alignment: .leading, spacing: 2) {
                Text(entity.name)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Text(entity.detail ?? "")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }

    // MARK: - Activity Row

    private func activityRow(_ activity: RecentActivity) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(activityColor(activity.type ?? ""))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.message ?? "")
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(formatDate(activity.created_at))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.3))
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .cornerRadius(8)
    }

    private func activityColor(_ type: String) -> Color {
        switch type {
        case "employer_created": return .blue
        case "employee_created": return .green
        case "invoice_created": return .orange
        default: return .gray
        }
    }
}
