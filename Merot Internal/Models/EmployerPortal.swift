import Foundation

// MARK: - Employer Dashboard

struct EmployerDashboardResponse: Codable {
    let data: EmployerDashboardData?
    let success: Bool?
    let message: String?
}

struct EmployerDashboardData: Codable {
    let stats: EmployerDashboardStats?
    let recent_employees: [EmployerDashEmployee]?
    let pending_time_off_requests: [EmployerDashTimeOff]?
}

struct EmployerDashboardStats: Codable {
    let total_employees: Int?
    let active_employees: Int?
    let pending_time_off_requests: Int?
    let recent_hires: Int?
    let upcoming_payroll_date: String?
}

struct EmployerDashEmployee: Codable, Identifiable {
    let id: Int
    let full_name: String?
    let employee_id: String?
    let position: String?
    let department: String?
    let status: String?
}

struct EmployerDashTimeOff: Codable, Identifiable {
    let id: Int
    let employee_name: String?
    let start_date: String?
    let end_date: String?
    let days: Int?
    let approval_status: String?
}

// MARK: - Employer Profile

struct EmployerProfileResponse: Codable {
    let data: EmployerProfileData?
    let success: Bool?
    let message: String?
}

struct EmployerProfileData: Codable {
    let user: EmployerProfileUser?
    let employer: EmployerProfileCompany?
}

struct EmployerProfileUser: Codable {
    let id: Int?
    let email: String?
    let first_name: String?
    let last_name: String?
    let user_type: String?
    let status: String?

    var displayName: String {
        "\(first_name ?? "") \(last_name ?? "")".trimmingCharacters(in: .whitespaces)
    }

    var initials: String {
        let f = (first_name ?? "").prefix(1)
        let l = (last_name ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }
}

struct EmployerProfileCompany: Codable {
    let id: Int?
    let name: String?
    let legal_name: String?
    let address_line1: String?
    let address_city: String?
    let address_state: String?
    let address_zip: String?
    let primary_email: String?
    let billing_email: String?
    let contact_email: String?
    let status: String?
    let employee_count: Int?
    let created_at: String?
    let updated_at: String?
}

// MARK: - Employer Employees

struct EmployerEmployeesResponse: Codable {
    let data: EmployerEmployeesData?
    let success: Bool?
}

struct EmployerEmployeesData: Codable {
    let employees: [EmployerEmployee]
    let meta: PaginationMeta?
}

struct EmployerEmployee: Codable, Identifiable {
    let id: Int
    let employee_id: String?
    let full_name: String?
    let first_name: String?
    let last_name: String?
    let email: String?
    let department: String?
    let status: String?
    let on_leave: Bool?
    let employee_type: String?
    let country: String?
    let employment: EmployerEmployeeEmployment?
    let created_at: String?

    var displayName: String { full_name ?? "\(first_name ?? "") \(last_name ?? "")".trimmingCharacters(in: .whitespaces) }
    var initials: String {
        let f = (first_name ?? "").prefix(1)
        let l = (last_name ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }
}

struct EmployerEmployeeEmployment: Codable {
    let id: Int?
    let position: String?
    let status: String?
    let start_date: String?
}

// MARK: - Employer Employee Detail

struct EmployerEmployeeDetailResponse: Codable {
    let data: EmployerEmployeeDetailData?
    let success: Bool?
}

struct EmployerEmployeeDetailData: Codable {
    let employee: EmployerEmployeeDetail
}

struct EmployerEmployeeDetail: Codable, Identifiable {
    let id: Int
    let employee_id: String?
    let full_name: String?
    let first_name: String?
    let last_name: String?
    let email: String?
    let personal_email: String?
    let department: String?
    let status: String?
    let on_leave: Bool?
    let employee_type: String?
    let country: String?
    let title: String?
    let location: String?
    let city: String?
    let address: String?
    let phone: String?
    let employment: EmployerEmployeeEmployment?
    let employments: [EmployerEmploymentRecord]?
    let created_at: String?

    var displayName: String { full_name ?? "\(first_name ?? "") \(last_name ?? "")".trimmingCharacters(in: .whitespaces) }
    var initials: String {
        let f = (first_name ?? "").prefix(1)
        let l = (last_name ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }
}

struct EmployerEmploymentRecord: Codable, Identifiable {
    let id: Int
    let position: String?
    let department: String?
    let status: String?
    let start_date: String?
    let end_date: String?
}

// MARK: - Employer Invoices

struct EmployerInvoicesResponse: Codable {
    let data: EmployerInvoicesData?
    let success: Bool?
}

struct EmployerInvoicesData: Codable {
    let invoices: [EmployerInvoice]
    let meta: PaginationMeta?
}

struct EmployerInvoice: Codable, Identifiable {
    let id: Int
    let invoice_number: String?
    let status: String?
    let issue_date: String?
    let due_date: String?
    let total_amount: FlexDouble?
    let subtotal: FlexDouble?
    let tax_amount: FlexDouble?
    let discount_amount: FlexDouble?
    let late_fee: FlexDouble?
    let currency: String?
    let billing_period_start: String?
    let billing_period_end: String?
    let billing_period_display: String?
    let total_employees: Int?
    let payroll_processing_fee: FlexDouble?
    let hr_services_fee: FlexDouble?
    let benefits_administration_fee: FlexDouble?
    let overdue: Bool?
    let days_overdue: Int?
    let created_at: String?
    let updated_at: String?
}

// MARK: - Employer Invoice Detail

struct EmployerInvoiceDetailResponse: Codable {
    let data: EmployerInvoiceDetailData?
    let success: Bool?
}

struct EmployerInvoiceDetailData: Codable {
    let invoice: EmployerInvoiceDetail?
}

struct EmployerInvoiceDetail: Codable, Identifiable {
    let id: Int
    let invoice_number: String?
    let status: String?
    let issue_date: String?
    let due_date: String?
    let total_amount: FlexDouble?
    let subtotal: FlexDouble?
    let tax_amount: FlexDouble?
    let discount_amount: FlexDouble?
    let late_fee: FlexDouble?
    let currency: String?
    let billing_period_start: String?
    let billing_period_end: String?
    let billing_period_display: String?
    let total_employees: Int?
    let overdue: Bool?
    let days_overdue: Int?
    let line_items: [EmployerInvoiceLineItem]?
    let employer: EmployerInvoiceEmployerRef?
    let created_at: String?
    let updated_at: String?
}

struct EmployerInvoiceLineItem: Codable, Identifiable {
    let id: Int
    let description: String?
    let quantity: FlexDouble?
    let unit_price: FlexDouble?
    let total_price: FlexDouble?
    let line_item_type: String?
    let service_category: String?
    let employee_name: String?
    let employee_id: String?
    let service_date: String?
}

struct EmployerInvoiceEmployerRef: Codable {
    let id: Int?
    let name: String?
    let legal_name: String?
}

// MARK: - Employer Time Off

struct EmployerTimeOffResponse: Codable {
    let data: EmployerTimeOffData?
    let success: Bool?
}

struct EmployerTimeOffData: Codable {
    let time_off_requests: [EmployerTimeOffRequest]
    let meta: PaginationMeta?
}

struct EmployerTimeOffRequest: Codable, Identifiable {
    let id: Int
    let employee: TimeOffEmployeeRef?
    let start_date: String?
    let end_date: String?
    let days: Int?
    let approval_status: String?
    let time_off_record: TimeOffRecordRef?
    let created_at: String?
    let updated_at: String?
}

// MARK: - Employer Holidays

struct EmployerHolidaysResponse: Codable {
    let data: EmployerHolidaysData?
    let success: Bool?
}

struct EmployerHolidaysData: Codable {
    let holidays: [EmployerHoliday]
    let meta: PaginationMeta?
}

struct EmployerHoliday: Codable, Identifiable {
    let id: Int
    let name: String?
    let date: String?
    let country: String?
    let holiday_type: String?
    let applicable_group: String?
    let is_weekend: Bool?
    let day_of_week: String?
    let created_at: String?
    let updated_at: String?
}

// MARK: - Employer Service Agreements

struct EmployerServiceAgreementsResponse: Codable {
    let data: EmployerServiceAgreementsData?
    let success: Bool?
}

struct EmployerServiceAgreementsData: Codable {
    let service_agreements: [EmployerServiceAgreement]
    let meta: PaginationMeta?
}

struct EmployerServiceAgreement: Codable, Identifiable {
    let id: Int
    let signature_status: String?
    let contract_status: String?
    let effective_date: String?
    let expiration_date: String?
    let created_at: String?
    let updated_at: String?
}

// MARK: - Employer Service Agreement Detail

struct EmployerServiceAgreementDetailResponse: Codable {
    let data: EmployerServiceAgreementDetailData?
    let success: Bool?
}

struct EmployerServiceAgreementDetailData: Codable {
    let service_agreement: EmployerServiceAgreementFull?
    let addendums: [EmployerAgreementAddendum]?
}

struct EmployerServiceAgreementFull: Codable, Identifiable {
    let id: Int
    let signature_status: String?
    let contract_status: String?
    let effective_date: String?
    let expiration_date: String?
    let addendums_count: Int?
    let created_at: String?
    let updated_at: String?
}

struct EmployerAgreementAddendum: Codable, Identifiable {
    let id: Int
    let addendum_number: Int?
    let employee: EmployerAddendumEmployee?
    let effective_date: String?
    let created_at: String?
}

struct EmployerAddendumEmployee: Codable {
    let id: Int?
    let full_name: String?
}
