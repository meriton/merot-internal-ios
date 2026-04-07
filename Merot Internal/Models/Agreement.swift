import Foundation

struct EmployeeAgreement: Codable, Identifiable {
    let id: Int
    let employee_user_id: Int?
    let employee_name: String?
    let status: String?
    let signature_status: String?
    let contract_type: String?
    let contract_type_display: String?
    let employment_type: String?
    let employment_type_display: String?
    let country: String?
    let country_display: String?
    let legal_entity: String?
    let legal_entity_display: String?
    let effective_date: String?
    let start_date: String?
    let end_date: String?
    let term_months: Int?
    let auto_renewal: Bool?
    let net_compensation: FlexDouble?
    let currency: String?
    let job_position: String?
    let is_trial: Bool?
    let compensation_type: String?
    let has_signed_document: Bool?
    let addendums_count: Int?
    let created_at: String?
    let updated_at: String?
}

struct ServiceAgreement: Codable, Identifiable {
    let id: Int
    let employer_id: Int?
    let employer_name: String?
    let status: String?
    let signature_status: String?
    let effective_date: String?
    let term_months: Int?
    let auto_renewal: Bool?
    let base_fee_per_employee: FlexDouble?
    let payment_terms_days: Int?
    let has_signed_document: Bool?
    let addendums_count: Int?
    let created_at: String?
    let updated_at: String?
}

struct EmployeeAgreementsListResponse: Codable {
    let data: EmployeeAgreementsListData?
    let success: Bool?
}

struct EmployeeAgreementsListData: Codable {
    let employee_agreements: [EmployeeAgreement]
    let meta: PaginationMeta?
}

struct ServiceAgreementsListResponse: Codable {
    let data: ServiceAgreementsListData?
    let success: Bool?
}

struct ServiceAgreementsListData: Codable {
    let service_agreements: [ServiceAgreement]
    let meta: PaginationMeta?
}
