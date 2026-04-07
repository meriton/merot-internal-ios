import SwiftUI

@MainActor
class EmployeeAgreementsViewModel: ObservableObject {
    @Published var agreements: [EmployeeAgreement] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var statusFilter = "all"

    let statusOptions = ["all", "draft", "sent", "viewed", "signed", "completed"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: EmployeeAgreementsListResponse = try await api.request("GET", "/admin/employee_agreements", query: query)
            agreements = res.data?.employee_agreements ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load agreements"
        }
        isLoading = false
    }
}

@MainActor
class ServiceAgreementsViewModel: ObservableObject {
    @Published var agreements: [ServiceAgreement] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var statusFilter = "all"

    let statusOptions = ["all", "draft", "sent", "viewed", "signed", "completed"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: ServiceAgreementsListResponse = try await api.request("GET", "/admin/service_agreements", query: query)
            agreements = res.data?.service_agreements ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load agreements"
        }
        isLoading = false
    }
}
