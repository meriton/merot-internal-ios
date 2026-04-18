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

    func create(body: [String: Any]) async -> Bool {
        isLoading = true
        error = nil
        do {
            let _: EmployerDetailResponse = try await api.request("POST", "/admin/employers", body: body)
            await load()
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to create employer"
        }
        isLoading = false
        return false
    }
}

@MainActor
class EmployerDetailViewModel: ObservableObject {
    @Published var detail: EmployerDetail?
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?

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

    func update(id: Int, body: [String: Any]) async -> Bool {
        isActioning = true
        error = nil
        do {
            let _: EmployerDetailResponse = try await api.request("PUT", "/admin/employers/\(id)", body: body)
            successMessage = "Employer updated"
            await load(id: id)
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to update employer"
        }
        isActioning = false
        return false
    }
}
