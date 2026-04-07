import Foundation

struct Employee: Codable, Identifiable {
    let id: Int
    let employee_id: String?
    let first_name: String?
    let last_name: String?
    let full_name: String?
    let email: String?
    let status: String?
    let employee_type: String?
    let department: String?
    let department_name: String?
    let title: String?
    let employer: EmployeeEmployerRef?
    let salary_detail: EmployeeSalaryRef?
    let created_at: String?
    let updated_at: String?

    var displayName: String { full_name ?? "\(first_name ?? "") \(last_name ?? "")".trimmingCharacters(in: .whitespaces) }
    var initials: String {
        let f = (first_name ?? "").prefix(1)
        let l = (last_name ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }
}

struct EmployeeEmployerRef: Codable {
    let id: Int?
    let name: String?
}

struct EmployeeSalaryRef: Codable {
    let net_salary: Double?
    let gross_salary: Double?
    let currency: String?
}

struct EmployeeDetailData: Codable {
    let employee: EmployeeFullJSON
    let salary_detail: SalaryDetail?
    let employments: [EmploymentRecord]?
    let recent_payroll_records: [RecentPayrollRecord]?
    let employee_agreements: [EmployeeAgreementBrief]?
}

struct EmployeeFullJSON: Codable, Identifiable {
    let id: Int
    let employee_id: String?
    let first_name: String?
    let last_name: String?
    let full_name: String?
    let email: String?
    let personal_email: String?
    let phone_number: String?
    let status: String?
    let employee_type: String?
    let department: String?
    let department_name: String?
    let title: String?
    let location: String?
    let address: String?
    let city: String?
    let country: String?
    let country_name: String?
    let postcode: String?
    let personal_id_number: String?
    let full_name_cyr: String?
    let id_front_photo_url: String?
    let id_back_photo_url: String?
    let created_at: String?
    let updated_at: String?

    var displayName: String { full_name ?? "\(first_name ?? "") \(last_name ?? "")".trimmingCharacters(in: .whitespaces) }
    var initials: String {
        let f = (first_name ?? "").prefix(1)
        let l = (last_name ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }
}

struct SalaryDetail: Codable {
    let id: Int?
    let base_salary: Double?
    let net_salary: Double?
    let gross_salary: Double?
    let currency: String?
    let bank_name: String?
    let bank_account_number: String?
    let employment_type: String?
    let seniority: Double?
    let merot_fee: Double?
}

struct EmploymentRecord: Codable, Identifiable {
    let id: Int
    let employer_id: Int?
    let employer_name: String?
    let start_date: String?
    let end_date: String?
    let employment_status: String?
}

struct RecentPayrollRecord: Codable, Identifiable {
    let id: Int
    let period: String?
    let net_salary: Double?
    let gross_salary: Double?
    let created_at: String?
}

struct EmployeeAgreementBrief: Codable, Identifiable {
    let id: Int
    let contract_status: String?
    let signature_status: String?
    let start_date: String?
    let end_date: String?
    let created_at: String?
}

struct EmployeesListResponse: Codable {
    let data: EmployeesListData?
    let success: Bool?
}

struct EmployeesListData: Codable {
    let employees: [Employee]
    let meta: PaginationMeta?
}

struct EmployeeDetailResponse: Codable {
    let data: EmployeeDetailData?
    let success: Bool?
}
