import Foundation

struct DashboardResponse: Codable {
    let data: DashboardData?
    let success: Bool?
    let message: String?
}

struct DashboardData: Codable {
    let stats: DashboardStats?
    let pending_items: [PendingItem]?
    let upcoming_payroll: UpcomingPayroll?
    let upcoming_holiday: UpcomingHoliday?
    let entities: [LegalEntity]?
    let recent_activity: [RecentActivity]?
}

struct DashboardStats: Codable {
    let active_employees: Int?
    let clocked_in: Int?
    let on_leave: Int?
    let expiring_agreements: Int?
    let outstanding_invoices: Int?
    let pending_service_agreements: Int?
    let pending_employee_agreements: Int?
    let employers_count: Int?
    let pending_time_off: Int?
}

struct PendingItem: Codable, Identifiable {
    let key: String
    let label: String
    let count: Int
    let path: String?
    let icon: String?

    var id: String { key }
}

struct UpcomingPayroll: Codable {
    let days_until: Int?
    let next_date: String?
}

struct UpcomingHoliday: Codable {
    let name: String?
    let date: String?
    let holiday_type: String?
    let applicable_country: String?
}

struct LegalEntity: Codable, Identifiable {
    let name: String
    let detail: String?
    let country: String?

    var id: String { name }
}

struct RecentActivity: Codable, Identifiable {
    let type: String?
    let message: String?
    let created_at: String?

    var id: String { "\(type ?? "")-\(created_at ?? "")-\(message ?? "")" }
}
