import SwiftUI

@MainActor
class EmployersViewModel: ObservableObject {
    @Published var employers: [Employer] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""

    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            let res: EmployersListResponse = try await api.request("GET", "/admin/employers", query: query)
            employers = res.data?.employers ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load employers"
        }
        isLoading = false
    }

    func search() async {
        await load()
    }
}

@MainActor
class EmployerDetailViewModel: ObservableObject {
    @Published var detail: EmployerDetail?
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: EmployerDetailResponse = try await api.request("GET", "/admin/employers/\(id)")
            detail = res.data
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load employer"
        }
        isLoading = false
    }
}
