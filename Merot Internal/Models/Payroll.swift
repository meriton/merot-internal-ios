import Foundation

struct PayrollBatch: Codable, Identifiable {
    let id: Int
    let month: String?
    let year: Int?
    let conversion_rate: Double?
    let working_hours: Double?
    let approved: Bool?
    let approved_at: String?
    let approved_by_id: Int?
    let payroll_period: String?
    let records_count: Int?
    let total_mkd_gross: Double?
    let total_eur_gross: Double?
    let created_at: String?
    let updated_at: String?

    var periodLabel: String {
        let months = ["", "January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        if let m = month, let mi = Int(m), mi >= 1 && mi <= 12, let y = year {
            return "\(months[mi]) \(y)"
        }
        return "\(month ?? "") \(year ?? 0)"
    }
}

struct PayrollRecord: Codable, Identifiable {
    let id: Int
    let employee_user_id: Int?
    let employee_name: String?
    let employee_id: String?
    let country: String?
    let employment_type: String?
    let base_salary: Double?
    let overtime_hours: Double?
    let overtime_pay: Double?
    let night_hours: Double?
    let night_pay: Double?
    let holiday_hours: Double?
    let holiday_pay: Double?
    let sunday_hours: Double?
    let sunday_pay: Double?
    let seniority: Double?
    let net_salary_before_seniority: Double?
    let net_salary: Double?
    let gross_salary: Double?
    let personal_tax: Double?
    let pension_tax: Double?
    let health_insurance_tax: Double?
    let disability_insurance_tax: Double?
    let employment_insurance_tax: Double?
    let personal_tax_allowance: Double?
    let bonus_payment: Double?
    let competition_payment: Double?
}

struct PayrollBatchDetail: Codable {
    let payroll_batch: PayrollBatchWithRecords
}

struct PayrollBatchWithRecords: Codable, Identifiable {
    let id: Int
    let month: String?
    let year: Int?
    let conversion_rate: Double?
    let working_hours: Double?
    let approved: Bool?
    let approved_at: String?
    let records_count: Int?
    let total_mkd_gross: Double?
    let total_eur_gross: Double?
    let payroll_records: [PayrollRecord]?
}

struct PayrollListResponse: Codable {
    let data: PayrollListData?
    let success: Bool?
}

struct PayrollListData: Codable {
    let payroll_batches: [PayrollBatch]
    let meta: PaginationMeta?
}

struct PayrollDetailResponse: Codable {
    let data: PayrollBatchDetail?
    let success: Bool?
}

struct PayrollActionResponse: Codable {
    let data: PayrollActionData?
    let success: Bool?
    let message: String?
}

struct PayrollActionData: Codable {
    let payroll_batch: PayrollBatch?
}
