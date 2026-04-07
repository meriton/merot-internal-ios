import SwiftUI

@MainActor
class EmployeesViewModel: ObservableObject {
    @Published var employees: [Employee] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var statusFilter: String? = nil

    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            if let s = statusFilter { query["status"] = s }
            let res: EmployeesListResponse = try await api.request("GET", "/admin/employees", query: query)
            employees = res.data?.employees ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load employees"
        }
        isLoading = false
    }

    func search() async {
        await load()
    }
}

@MainActor
class EmployeeDetailViewModel: ObservableObject {
    @Published var detail: EmployeeDetailData?
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: EmployeeDetailResponse = try await api.request("GET", "/admin/employees/\(id)")
            detail = res.data
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load employee"
        }
        isLoading = false
    }
}
