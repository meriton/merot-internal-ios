import Foundation

// MARK: - Employee Dashboard Models

struct EmployeeDashData: Codable {
    let employee: EmployeeDashEmployee?
    let employment: EmployeeDashEmployment?
    let time_tracking: EmployeeDashTimeTracking?
    let time_off: EmployeeDashTimeOff?
    let next_holiday: EmployeeDashHoliday?
    let last_paystub: EmployeeDashPaystub?
}

struct EmployeeDashEmployee: Codable {
    let id: Int?
    let full_name: String?
    let employee_id: String?
    let department: String?
}

struct EmployeeDashEmployment: Codable {
    let id: Int?
    let position: String?
    let employer: EmployeeDashEmployer?
}

struct EmployeeDashEmployer: Codable {
    let id: Int?
    let name: String?
}

struct EmployeeDashTimeTracking: Codable {
    let currently_clocked_in: Bool?
    let total_hours_this_week: Double?
    let total_hours_this_month: Double?
}

struct EmployeeDashTimeOff: Codable {
    let available_days: Double?
    let pending_requests_count: Int?
    let pending_requests: [EmployeeDashPendingReq]?
    let balances: [EmployeeDashBalance]?
}

struct EmployeeDashPendingReq: Codable {
    let id: Int
    let start_date: String?
    let end_date: String?
    let days: Int?
    let approval_status: String?
}

struct EmployeeDashBalance: Codable {
    let id: Int
    let name: String?
    let leave_type: String?
    let days: Double?
    let balance: Double?
}

struct EmployeeDashHoliday: Codable {
    let id: Int?
    let name: String?
    let date: String?
    let day_of_week: String?
    let days_until: Int?
}

struct EmployeeDashPaystub: Codable {
    let id: Int?
    let period: String?
    let net_salary: Double?
    let gross_salary: Double?
    let currency: String?
}

// MARK: - Payroll Models

struct EmpPayrollRecord: Codable, Identifiable {
    let id: Int
    let employee_id: String?
    let gross_pay: Double?
    let net_pay: Double?
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
    let pension_tax: Double?
    let health_insurance_tax: Double?
    let disability_insurance_tax: Double?
    let employment_insurance_tax: Double?
    let personal_tax: Double?
    let all_taxes: Double?
    let country: String?
    let payroll_batch: EmpPayrollBatch?
    let currency: String?
    let period: String?
    let period_label: String?
    let net_salary_before_seniority: Double?
    let created_at: String?
}

struct EmpPayrollBatch: Codable {
    let id: Int?
    let month: String?
    let year: Int?
    let pay_date: String?
    let working_hours: Int?
    let period: String?
    let month_name: String?
}

struct EmpPayrollResponse: Codable {
    let data: EmpPayrollData?
    let success: Bool?
}

struct EmpPayrollData: Codable {
    let payroll_records: [EmpPayrollRecord]
}

struct EmpPayrollDetailResponse: Codable {
    let data: EmpPayrollDetailData?
    let success: Bool?
}

struct EmpPayrollDetailData: Codable {
    let payroll_record: EmpPayrollRecord
}

// MARK: - Time Tracking Models

struct EmpTimeKeepingRecord: Codable, Identifiable {
    let id: Int
    let time_in: String?
    let time_out: String?
    let hours_worked: Double?
    let employee_id: String?
    let created_at: String?
}

struct EmpTimeTrackingResponse: Codable {
    let data: EmpTimeTrackingData?
    let success: Bool?
}

struct EmpTimeTrackingData: Codable {
    let time_keeping_records: [EmpTimeKeepingRecord]
}

// MARK: - Time Off Models

struct EmpTimeOffReq: Codable, Identifiable {
    let id: Int
    let start_date: String?
    let end_date: String?
    let days: Int?
    let approval_status: String?
    let time_off_record: EmpTimeOffRecordRef?
    let created_at: String?
}

struct EmpTimeOffRecordRef: Codable {
    let id: Int?
    let name: String?
    let leave_type: String?
    let balance: Int?
    let total_days: Int?
}

struct EmpTimeOffResponse: Codable {
    let data: EmpTimeOffData?
    let success: Bool?
}

struct EmpTimeOffData: Codable {
    let time_off_requests: [EmpTimeOffReq]
}

struct EmpTimeOffRecord: Codable, Identifiable {
    let id: Int
    let name: String?
    let leave_type: String?
    let balance: Int?
    let total_days: Int?
    let issue_date: String?
    let valid_until: String?
}

struct EmpTimeOffRecordsResponse: Codable {
    let data: EmpTimeOffRecordsData?
    let success: Bool?
}

struct EmpTimeOffRecordsData: Codable {
    let time_off_records: [EmpTimeOffRecord]
    let total_available_days: Int?
}

// MARK: - Employee Profile Model

struct EmpProfile: Codable {
    let id: Int?
    let email: String?
    let first_name: String?
    let last_name: String?
    let full_name: String?
    let employee_id: String?
    let department: String?
    let title: String?
    let phone_number: String?
    let personal_email: String?
    let address: String?
    let city: String?
    let country: String?
    let status: String?
    let employment: EmpProfileEmployment?
}

struct EmpProfileEmployment: Codable {
    let id: Int?
    let position: String?
    let start_date: String?
    let employer: EmpProfileEmployer?
}

struct EmpProfileEmployer: Codable {
    let id: Int?
    let name: String?
}

struct EmpProfileResponse: Codable {
    let data: EmpProfileData?
    let success: Bool?
}

struct EmpProfileData: Codable {
    let profile: EmpProfile?
    let user: AdminUser?
}

// MARK: - Employment Verification Models

struct EmpVerificationRequest: Codable, Identifiable {
    let id: Int
    let reason: String?
    let purpose_detail: String?
    let status: String?
    let language: String?
    let issued_at: String?
    let admin_notes: String?
    let created_at: String?
}

struct EmpVerificationListResponse: Codable {
    let data: EmpVerificationListData?
    let success: Bool?
}

struct EmpVerificationListData: Codable {
    let requests: [EmpVerificationRequest]
}

struct EmpVerificationCreateResponse: Codable {
    let data: EmpVerificationCreateData?
    let success: Bool?
    let message: String?
    let errors: [String]?
}

struct EmpVerificationCreateData: Codable {
    let request: EmpVerificationRequest?
}
