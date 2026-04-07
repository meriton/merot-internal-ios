import SwiftUI

@MainActor
class InvoicesViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var stats: InvoiceStats?
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var statusFilter = "all"
    @Published var actionMessage: String?

    let statusOptions = ["all", "draft", "approved", "sent", "paid", "overdue", "cancelled"]

    private let api = APIService.shared

    func load() async {
        isLoading = true
        error = nil
        do {
            var query: [String: String] = ["per_page": "100"]
            if !searchText.isEmpty { query["search"] = searchText }
            if statusFilter != "all" { query["status"] = statusFilter }
            let res: InvoicesListResponse = try await api.request("GET", "/admin/invoices", query: query)
            invoices = res.data?.invoices ?? []
            stats = res.data?.stats
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load invoices"
        }
        isLoading = false
    }
}

@MainActor
class InvoiceDetailViewModel: ObservableObject {
    @Published var invoice: Invoice?
    @Published var lineItems: [InvoiceLineItem] = []
    @Published var transactions: [InvoiceTransaction] = []
    @Published var isLoading = false
    @Published var isActioning = false
    @Published var error: String?
    @Published var successMessage: String?

    private let api = APIService.shared

    func load(id: Int) async {
        isLoading = true
        error = nil
        do {
            let res: InvoiceDetailResponse = try await api.request("GET", "/admin/invoices/\(id)")
            // The detail response wraps invoice with line_items inside
            if let data = res.data {
                // Try to parse as full detail (invoice has line_items embedded)
                invoice = data.invoice
                lineItems = data.line_items ?? []
                transactions = data.transactions ?? []
            }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to load invoice"
        }
        isLoading = false
    }

    func approve(id: Int) async {
        await performAction("approve", id: id)
    }

    func markSent(id: Int) async {
        await performAction("mark_sent", id: id)
    }

    func markPaid(id: Int) async {
        await performAction("mark_paid", id: id)
    }

    func cancel(id: Int) async {
        await performAction("cancel", id: id)
    }

    func sendEmail(id: Int) async {
        await performAction("send_email", id: id)
    }

    func recordPayment(id: Int, amount: Double, method: String, reference: String?) async {
        isActioning = true
        error = nil
        do {
            var body: [String: Any] = ["amount": amount, "payment_method": method]
            if let ref = reference, !ref.isEmpty { body["reference_number"] = ref }
            let res: InvoiceActionResponse = try await api.request("POST", "/admin/invoices/\(id)/record_payment", body: body)
            successMessage = res.message ?? "Payment recorded"
            if let inv = res.data?.invoice { invoice = inv }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to record payment"
        }
        isActioning = false
    }

    private func performAction(_ action: String, id: Int) async {
        isActioning = true
        error = nil
        successMessage = nil
        do {
            let res: InvoiceActionResponse = try await api.request("POST", "/admin/invoices/\(id)/\(action)")
            successMessage = res.message
            if let inv = res.data?.invoice { invoice = inv }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Action failed"
        }
        isActioning = false
    }
}
