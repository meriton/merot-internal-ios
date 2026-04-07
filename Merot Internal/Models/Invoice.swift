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
    let subtotal: FlexDouble?
    let tax_amount: FlexDouble?
    let late_fee: FlexDouble?
    let discount_amount: FlexDouble?
    let total_amount: FlexDouble?
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
    let quantity: FlexDouble?
    let unit_price: FlexDouble?
    let total_price: FlexDouble?
    let employee_name: String?
    let employee_id: String?
    let hours_worked: FlexDouble?
    let hourly_rate: FlexDouble?
}

struct InvoiceTransaction: Codable, Identifiable {
    let id: Int
    let amount: FlexDouble?
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
    let total_draft: FlexDouble?
    let total_approved: FlexDouble?
    let total_outstanding: FlexDouble?
    let overdue_count: Int?
    let total_paid: FlexDouble?
    let total_fees: FlexDouble?
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
