import Foundation

struct EmploymentVerificationRequest: Codable, Identifiable {
    let id: Int
    let employee_name: String?
    let employee_id: String?
    let requester_name: String?
    let requester_email: String?
    let requester_company: String?
    let purpose: String?
    let status: String?
    let notes: String?
    let issued_at: String?
    let rejected_at: String?
    let rejection_reason: String?
    let created_at: String?
    let updated_at: String?
}

struct EmploymentVerificationListResponse: Codable {
    let data: EmploymentVerificationListData?
    let success: Bool?
}

struct EmploymentVerificationListData: Codable {
    let employment_verification_requests: [EmploymentVerificationRequest]
    let meta: PaginationMeta?
}

struct EmploymentVerificationActionResponse: Codable {
    let data: EmploymentVerificationActionData?
    let success: Bool?
    let message: String?
}

struct EmploymentVerificationActionData: Codable {
    let employment_verification_request: EmploymentVerificationRequest?
}
