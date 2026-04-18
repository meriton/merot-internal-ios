import Foundation

struct PayrollBatch: Codable, Identifiable {
    let id: Int
    let month: String?
    let year: Int?
    let conversion_rate: FlexDouble?
    let working_hours: FlexDouble?
    let approved: Bool?
    let approved_at: String?
    let approved_by_id: Int?
    let payroll_period: String?
    let records_count: Int?
    let total_mkd_gross: FlexDouble?
    let total_eur_gross: FlexDouble?
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
    let base_salary: FlexDouble?
    let overtime_hours: FlexDouble?
    let overtime_pay: FlexDouble?
    let night_hours: FlexDouble?
    let night_pay: FlexDouble?
    let holiday_hours: FlexDouble?
    let holiday_pay: FlexDouble?
    let sunday_hours: FlexDouble?
    let sunday_pay: FlexDouble?
    let seniority: FlexDouble?
    let net_salary_before_seniority: FlexDouble?
    let net_salary: FlexDouble?
    let gross_salary: FlexDouble?
    let personal_tax: FlexDouble?
    let pension_tax: FlexDouble?
    let health_insurance_tax: FlexDouble?
    let disability_insurance_tax: FlexDouble?
    let employment_insurance_tax: FlexDouble?
    let personal_tax_allowance: FlexDouble?
    let bonus_payment: FlexDouble?
    let competition_payment: FlexDouble?
}

struct PayrollBatchDetail: Codable {
    let payroll_batch: PayrollBatchWithRecords
}

struct PayrollBatchWithRecords: Codable, Identifiable {
    let id: Int
    let month: String?
    let year: Int?
    let conversion_rate: FlexDouble?
    let working_hours: FlexDouble?
    let approved: Bool?
    let approved_at: String?
    let records_count: Int?
    let total_mkd_gross: FlexDouble?
    let total_eur_gross: FlexDouble?
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
