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
            self.error = "Failed to load agreements: \(error.localizedDescription)"
            #if DEBUG
            print("[EAgreementsVM] Error: \(error)")
            #endif
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
            self.error = "Failed to load agreements: \(error.localizedDescription)"
            #if DEBUG
            print("[SAgreementsVM] Error: \(error)")
            #endif
        }
        isLoading = false
    }
}

// MARK: - Agreement Detail ViewModels

@MainActor
class EmployeeAgreementDetailViewModel: ObservableObject {
    @Published var agreement: EmployeeAgreement?
    @Published var addendums: [AgreementAddendum] = []
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: EmployeeAgreementDetailResponse = try await api.request("GET", "/admin/employee_agreements/\(id)")
            agreement = res.data?.employee_agreement
            addendums = res.data?.addendums ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load agreement"
        }
        isLoading = false
    }

    func sendForSignature(id: Int) async {
        await performAction("send_for_signature", id: id)
    }

    func syncDocusign(id: Int) async {
        await performAction("sync_docusign", id: id)
    }

    func downloadPDF(id: Int) async -> URL? {
        do {
            let data = try await api.requestData("GET", "/admin/employee_agreements/\(id)/pdf")
            let tmpDir = FileManager.default.temporaryDirectory
            let fileURL = tmpDir.appendingPathComponent("employee_agreement_\(id).pdf")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            self.error = "Failed to download PDF"
            return nil
        }
    }

    func downloadSigned(id: Int) async -> URL? {
        do {
            let data = try await api.requestData("GET", "/admin/employee_agreements/\(id)/download_signed")
            let tmpDir = FileManager.default.temporaryDirectory
            let fileURL = tmpDir.appendingPathComponent("employee_agreement_\(id)_signed.pdf")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            self.error = "Failed to download signed document"
            return nil
        }
    }

    private func performAction(_ action: String, id: Int) async {
        isActioning = true
        error = nil
        successMessage = nil
        do {
            let res: AgreementActionResponse = try await api.request("POST", "/admin/employee_agreements/\(id)/\(action)")
            successMessage = res.message ?? action.replacingOccurrences(of: "_", with: " ").capitalized
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Action failed"
        }
        isActioning = false
    }
}

@MainActor
class ServiceAgreementDetailViewModel: ObservableObject {
    @Published var agreement: ServiceAgreement?
    @Published var addendums: [AgreementAddendum] = []
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: ServiceAgreementDetailResponse = try await api.request("GET", "/admin/service_agreements/\(id)")
            agreement = res.data?.service_agreement
            addendums = res.data?.addendums ?? []
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load agreement"
        }
        isLoading = false
    }

    func sendForSignature(id: Int) async {
        await performAction("send_for_signature", id: id)
    }

    func syncDocusign(id: Int) async {
        await performAction("sync_docusign", id: id)
    }

    func downloadPDF(id: Int) async -> URL? {
        do {
            let data = try await api.requestData("GET", "/admin/service_agreements/\(id)/pdf")
            let tmpDir = FileManager.default.temporaryDirectory
            let fileURL = tmpDir.appendingPathComponent("service_agreement_\(id).pdf")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            self.error = "Failed to download PDF"
            return nil
        }
    }

    func downloadSigned(id: Int) async -> URL? {
        do {
            let data = try await api.requestData("GET", "/admin/service_agreements/\(id)/download_signed")
            let tmpDir = FileManager.default.temporaryDirectory
            let fileURL = tmpDir.appendingPathComponent("service_agreement_\(id)_signed.pdf")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            self.error = "Failed to download signed document"
            return nil
        }
    }

    private func performAction(_ action: String, id: Int) async {
        isActioning = true
        error = nil
        successMessage = nil
        do {
            let res: AgreementActionResponse = try await api.request("POST", "/admin/service_agreements/\(id)/\(action)")
            successMessage = res.message ?? action.replacingOccurrences(of: "_", with: " ").capitalized
            await load(id: id)
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Action failed"
        }
        isActioning = false
    }
}
