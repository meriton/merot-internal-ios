import Foundation

struct TimeOffRequest: Codable, Identifiable {
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

struct TimeOffEmployeeRef: Codable {
    let id: Int?
    let full_name: String?
    let employee_id: String?
    let department: String?
}

struct TimeOffRecordRef: Codable {
    let id: Int?
    let name: String?
    let leave_type: String?
    let balance: Double?
    let total_days: Double?
}

struct TimeOffListResponse: Codable {
    let data: TimeOffListData?
    let success: Bool?
}

struct TimeOffListData: Codable {
    let time_off_requests: [TimeOffRequest]
    let meta: PaginationMeta?
}

struct TimeOffActionResponse: Codable {
    let data: TimeOffActionData?
    let success: Bool?
    let message: String?
}

struct TimeOffActionData: Codable {
    let time_off_request: TimeOffRequest?
}
