import SwiftUI

@MainActor
class TimeOffViewModel: ObservableObject {
    @Published var requests: [TimeOffRequest] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var statusFilter = "pending"
    @Published var isActioning = false
    @Published var successMessage: String?

    let statusOptions = ["pending", "approved", "denied", "all"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: TimeOffListResponse = try await api.request("GET", "/admin/time_off_requests", query: query)
            requests = res.data?.time_off_requests ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load time off requests"
        }
        isLoading = false
    }

    func approve(id: Int) async {
        isActioning = true
        error = nil
        do {
            let res: TimeOffActionResponse = try await api.request("PUT", "/admin/time_off_requests/\(id)/approve")
            successMessage = res.message ?? "Approved"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to approve"
        }
        isActioning = false
    }

    func deny(id: Int) async {
        isActioning = true
        error = nil
        do {
            let res: TimeOffActionResponse = try await api.request("PUT", "/admin/time_off_requests/\(id)/deny")
            successMessage = res.message ?? "Denied"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to deny"
        }
        isActioning = false
    }
}
