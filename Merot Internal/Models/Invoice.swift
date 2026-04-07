import Foundation

struct Invoice: Codable, Identifiable {
    let id: Int
    let employer_id: Int?
    let employer_name: String?
    let employer_emails: [String]?
    let invoice_number: String?
    let issue_date: String?
    let due_date: String?
    let billing_period_start: String?
    let billing_period_end: String?
    let billing_period_display: String?
    let status: String?
    let currency: String?
    let subtotal: Double?
    let tax_amount: Double?
    let late_fee: Double?
    let discount_amount: Double?
    let total_amount: Double?
    let total_employees: Int?
    let description: String?
    let notes: String?
    let payment_terms: String?
    let overdue: Bool?
    let days_overdue: Int?
    let formatted_total: String?
    let created_at: String?
    let updated_at: String?
}

struct InvoiceLineItem: Codable, Identifiable {
    let id: Int
    let description: String?
    let line_item_type: String?
    let service_category: String?
    let quantity: Double?
    let unit_price: Double?
    let total_price: Double?
    let employee_name: String?
    let employee_id: String?
    let hours_worked: Double?
    let hourly_rate: Double?
}

struct InvoiceTransaction: Codable, Identifiable {
    let id: Int
    let amount: Double?
    let payment_method: String?
    let status: String?
    let transaction_type: String?
    let currency: String?
    let reference_number: String?
    let description: String?
    let processed_at: String?
    let created_at: String?
}

struct InvoiceStats: Codable {
    let period_label: String?
    let total_draft: Double?
    let total_approved: Double?
    let total_outstanding: Double?
    let overdue_count: Int?
    let total_paid: Double?
    let total_fees: Double?
}

struct InvoiceDetail: Codable {
    let invoice: Invoice
    let line_items: [InvoiceLineItem]?
    let transactions: [InvoiceTransaction]?
}

struct InvoicesListResponse: Codable {
    let data: InvoicesListData?
    let success: Bool?
}

struct InvoicesListData: Codable {
    let invoices: [Invoice]
    let meta: PaginationMeta?
    let stats: InvoiceStats?
}

struct InvoiceDetailResponse: Codable {
    let data: InvoiceDetailData?
    let success: Bool?
}

struct InvoiceDetailData: Codable {
    let invoice: Invoice?
    let line_items: [InvoiceLineItem]?
    let transactions: [InvoiceTransaction]?
}

struct InvoiceActionResponse: Codable {
    let data: InvoiceActionData?
    let success: Bool?
    let message: String?
}

struct InvoiceActionData: Codable {
    let invoice: Invoice?
}
