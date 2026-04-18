import Foundation

struct ContactRequest: Codable, Identifiable {
    let id: Int
    let name: String?
    let email: String?
    let company_name: String?
    let message: String?
    let status: String?
    let ip_address: String?
    let created_at: String?
    let updated_at: String?
}

struct ContactRequestStats: Codable {
    let pending: Int?
    let replied: Int?
    let completed: Int?
    let total: Int?
}

struct ContactRequestsListResponse: Codable {
    let data: ContactRequestsListData?
    let success: Bool?
}

struct ContactRequestsListData: Codable {
    let contact_requests: [ContactRequest]
    let meta: PaginationMeta?
    let stats: ContactRequestStats?
}

struct ContactRequestActionResponse: Codable {
    let data: ContactRequestActionData?
    let success: Bool?
    let message: String?
}

struct ContactRequestActionData: Codable {
    let contact_request: ContactRequest?
}
