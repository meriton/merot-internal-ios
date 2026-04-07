import SwiftUI

@MainActor
class JobPostingsViewModel: ObservableObject {
    @Published var postings: [JobPosting] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var statusFilter = "all"

    let statusOptions = ["all", "draft", "published", "closed", "archived"]
    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: JobPostingsListResponse = try await api.request("GET", "/admin/job_postings", query: query)
            postings = res.data?.job_postings ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load job postings"
        }
        isLoading = false
    }
}

@MainActor
class JobPostingDetailViewModel: ObservableObject {
    @Published var posting: JobPosting?
    @Published var applications: [JobApplicationBrief] = []
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: JobPostingDetailResponse = try await api.request("GET", "/admin/job_postings/\(id)")
            posting = res.data?.job_posting
            applications = res.data?.applications ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load job posting"
        }
        isLoading = false
    }

    func publish(id: Int) async { await performAction("publish", id: id, method: "PUT") }
    func close(id: Int) async { await performAction("close", id: id, method: "PUT") }
    func archive(id: Int) async { await performAction("archive", id: id, method: "PUT") }

    private func performAction(_ action: String, id: Int, method: String) async {
        isActioning = true
        error = nil
        do {
            let res: JobPostingActionResponse = try await api.request(method, "/admin/job_postings/\(id)/\(action)")
            successMessage = res.message
            if let p = res.data?.job_posting { posting = p }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Action failed"
        }
        isActioning = false
    }
}
