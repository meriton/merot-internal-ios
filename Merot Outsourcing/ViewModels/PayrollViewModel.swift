import SwiftUI

@MainActor
class PayrollViewModel: ObservableObject {
    @Published var batches: [PayrollBatch] = []
    @Published var isLoading = false
    @Published var error: String?

    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            let res: PayrollListResponse = try await api.request("GET", "/admin/payroll", query: ["per_page": "50"])
            batches = res.data?.payroll_batches ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load payroll: \(error.localizedDescription)"
            #if DEBUG
            print("[PayrollVM] Error: \(error)")
            #endif
        }
        isLoading = false
    }
}

@MainActor
class PayrollDetailViewModel: ObservableObject {
    @Published var batch: PayrollBatchWithRecords?
    @Published var isLoading = false
    @Published var isApproving = false
    @Published var error: String?
    @Published var successMessage: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: PayrollDetailResponse = try await api.request("GET", "/admin/payroll/\(id)")
            batch = res.data?.payroll_batch
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load payroll batch"
        }
        isLoading = false
    }

    func approve(id: Int) async {
        isApproving = true
        error = nil
        do {
            let res: PayrollActionResponse = try await api.request("POST", "/admin/payroll/\(id)/approve")
            successMessage = res.message ?? "Batch approved"
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to approve batch"
        }
        isApproving = false
    }
}
