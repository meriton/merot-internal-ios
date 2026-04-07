import SwiftUI

@MainActor
class PersonalInfoViewModel: ObservableObject {
    @Published var requests: [PersonalInfoRequest] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var statusFilter = "submitted"
    @Published var isActioning = false
    @Published var successMessage: String?

    let statusOptions = ["submitted", "approved", "rejected", "all"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: PersonalInfoListResponse = try await api.request("GET", "/admin/personal_info_requests", query: query)
            requests = res.data?.personal_info_requests ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load requests"
        }
        isLoading = false
    }

    func approve(id: Int) async {
        isActioning = true
        error = nil
        do {
            let res: PersonalInfoActionResponse = try await api.request("POST", "/admin/personal_info_requests/\(id)/approve")
            successMessage = res.message ?? "Approved"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to approve"
        }
        isActioning = false
    }

    func reject(id: Int, comment: String?) async {
        isActioning = true
        error = nil
        do {
            var body: [String: Any] = [:]
            if let c = comment, !c.isEmpty { body["rejection_comment"] = c }
            let res: PersonalInfoActionResponse = try await api.request("POST", "/admin/personal_info_requests/\(id)/reject", body: body.isEmpty ? nil : body)
            successMessage = res.message ?? "Rejected"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to reject"
        }
        isActioning = false
    }
}

@MainActor
class PersonalInfoDetailViewModel: ObservableObject {
    @Published var request: PersonalInfoRequest?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isActioning = false
    @Published var successMessage: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: PersonalInfoDetailResponse = try await api.request("GET", "/admin/personal_info_requests/\(id)")
            request = res.data?.personal_info_request
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load request"
        }
        isLoading = false
    }

    func approve(id: Int) async {
        isActioning = true
        error = nil
        do {
            let res: PersonalInfoActionResponse = try await api.request("POST", "/admin/personal_info_requests/\(id)/approve")
            successMessage = res.message ?? "Approved"
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to approve"
        }
        isActioning = false
    }

    func reject(id: Int, comment: String?) async {
        isActioning = true
        error = nil
        do {
            var body: [String: Any] = [:]
            if let c = comment, !c.isEmpty { body["rejection_comment"] = c }
            let res: PersonalInfoActionResponse = try await api.request("POST", "/admin/personal_info_requests/\(id)/reject", body: body.isEmpty ? nil : body)
            successMessage = res.message ?? "Rejected"
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to reject"
        }
        isActioning = false
    }
}
