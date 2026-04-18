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

    func create(body: [String: Any]) async -> Bool {
        isLoading = true
        error = nil
        do {
            let _: EmployeeDetailResponse = try await api.request("POST", "/admin/employees", body: body)
            await load()
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to create employee"
        }
        isLoading = false
        return false
    }
}

@MainActor
class EmployeeDetailViewModel: ObservableObject {
    @Published var detail: EmployeeDetailData?
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?

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

    func update(id: Int, body: [String: Any]) async -> Bool {
        isActioning = true
        error = nil
        do {
            let _: EmployeeDetailResponse = try await api.request("PUT", "/admin/employees/\(id)", body: body)
            successMessage = "Employee updated"
            await load(id: id)
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to update employee"
        }
        isActioning = false
        return false
    }

    func sendWelcomeEmail(id: Int) async {
        isActioning = true
        error = nil
        do {
            let res: SimpleResponse = try await api.request("POST", "/admin/employees/\(id)/send_welcome_email")
            successMessage = res.message ?? "Welcome email sent"
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to send welcome email"
        }
        isActioning = false
    }

    func regenerateId(id: Int) async {
        isActioning = true
        error = nil
        do {
            let _: EmployeeDetailResponse = try await api.request("POST", "/admin/employees/\(id)/regenerate_id")
            successMessage = "Employee ID regenerated"
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to regenerate ID"
        }
        isActioning = false
    }

    func sendPersonalInfoRequest(employeeUserId: Int) async {
        isActioning = true
        error = nil
        do {
            let body: [String: Any] = ["employee_user_id": employeeUserId]
            let res: PersonalInfoActionResponse = try await api.request("POST", "/admin/personal_info_requests", body: body)
            successMessage = res.message ?? "Personal info request sent"
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to send personal info request"
        }
        isActioning = false
    }
}
