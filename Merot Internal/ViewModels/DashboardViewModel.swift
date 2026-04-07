import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stats: DashboardStats?
    @Published var pendingItems: [PendingItem] = []
    @Published var upcomingPayroll: UpcomingPayroll?
    @Published var upcomingHoliday: UpcomingHoliday?
    @Published var entities: [LegalEntity] = []
    @Published var recentActivity: [RecentActivity] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            let res: DashboardResponse = try await api.request("GET", "/admin/dashboard")
            if let data = res.data {
                stats = data.stats
                pendingItems = data.pending_items ?? []
                upcomingPayroll = data.upcoming_payroll
                upcomingHoliday = data.upcoming_holiday
                entities = data.entities ?? []
                recentActivity = data.recent_activity ?? []
            }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load dashboard"
        }
        isLoading = false
    }
}
