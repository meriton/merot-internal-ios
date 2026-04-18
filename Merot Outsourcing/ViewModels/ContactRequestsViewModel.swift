import SwiftUI

@MainActor
class ContactRequestsViewModel: ObservableObject {
    @Published var requests: [ContactRequest] = []
    @Published var stats: ContactRequestStats?
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var statusFilter = "all"
    @Published var isActioning = false
    @Published var successMessage: String?

    let statusOptions = ["all", "pending", "replied", "completed"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: ContactRequestsListResponse = try await api.request("GET", "/admin/contact_requests", query: query)
            requests = res.data?.contact_requests ?? []
            stats = res.data?.stats
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load contact requests"
        }
        isLoading = false
    }

    func updateStatus(id: Int, status: String) async {
        isActioning = true
        error = nil
        do {
            let res: ContactRequestActionResponse = try await api.request("PUT", "/admin/contact_requests/\(id)", body: ["status": status])
            successMessage = res.message ?? "Status updated"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to update status"
        }
        isActioning = false
    }
}
