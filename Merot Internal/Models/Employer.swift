import Foundation

struct Employer: Codable, Identifiable {
    let id: Int
    let name: String?
    let legal_name: String?
    let primary_email: String?
    let status: String?
    let address_city: String?
    let employee_count: Int?
    let created_at: String?
    let updated_at: String?
}

struct EmployerDetail: Codable {
    let employer: EmployerFull
    let employee_count: Int?
    let total_invoiced: Double?
    let active_employments: [ActiveEmployment]?
}

struct EmployerFull: Codable, Identifiable {
    let id: Int
    let name: String?
    let legal_name: String?
    let primary_email: String?
    let billing_email: String?
    let contact_email: String?
    let phone: String?
    let status: String?
    let industry: String?
    let company_size: String?
    let address_line1: String?
    let address_line2: String?
    let address_city: String?
    let address_state: String?
    let address_zip: String?
    let address_country: String?
    let tax_number: String?
    let registration_number: String?
    let website: String?
    let description: String?
    let created_at: String?
    let updated_at: String?
}

struct ActiveEmployment: Codable, Identifiable {
    let id: Int
    let employee_id: Int?
    let employee_name: String?
    let start_date: String?
    let employment_status: String?
}

struct EmployersListResponse: Codable {
    let data: EmployersListData?
    let success: Bool?
}

struct EmployersListData: Codable {
    let employers: [Employer]
    let meta: PaginationMeta?
}

struct EmployerDetailResponse: Codable {
    let data: EmployerDetail?
    let success: Bool?
}
