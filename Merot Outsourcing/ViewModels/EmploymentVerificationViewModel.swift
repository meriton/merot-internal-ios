import SwiftUI

@MainActor
class EmploymentVerificationViewModel: ObservableObject {
    @Published var requests: [EmploymentVerificationRequest] = []
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?
    @Published var statusFilter = "all"

    let statusOptions = ["all", "pending", "issued", "rejected"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: EmploymentVerificationListResponse = try await api.request("GET", "/admin/employment_verification_requests", query: query)
            requests = res.data?.employment_verification_requests ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load verification requests"
        }
        isLoading = false
    }

    func issue(id: Int) async {
        isActioning = true
        error = nil
        do {
            let res: EmploymentVerificationActionResponse = try await api.request("POST", "/admin/employment_verification_requests/\(id)/issue")
            successMessage = res.message ?? "Verification issued"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to issue verification"
        }
        isActioning = false
    }

    func reject(id: Int, reason: String?) async {
        isActioning = true
        error = nil
        do {
            var body: [String: Any] = [:]
            if let r = reason, !r.isEmpty { body["rejection_reason"] = r }
            let res: EmploymentVerificationActionResponse = try await api.request("POST", "/admin/employment_verification_requests/\(id)/reject", body: body.isEmpty ? nil : body)
            successMessage = res.message ?? "Verification rejected"
            await load()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to reject verification"
        }
        isActioning = false
    }

    func downloadPDF(id: Int) async -> URL? {
        do {
            let data = try await api.requestData("GET", "/admin/employment_verification_requests/\(id)/pdf")
            let tmpDir = FileManager.default.temporaryDirectory
            let fileURL = tmpDir.appendingPathComponent("verification_\(id).pdf")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            self.error = "Failed to download PDF"
            return nil
        }
    }
}
