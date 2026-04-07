import Foundation

struct PersonalInfoRequest: Codable, Identifiable {
    let id: Int
    let status: String?
    let token: String?
    let employee: PersonalInfoEmployeeRef?
    let reviewer: PersonalInfoReviewerRef?
    let rejection_comment: String?
    let expires_at: String?
    let submitted_data: [String: String]?
    let current_data: [String: String]?
    let changed_fields: [String]?
    let has_photo_changes: Bool?
    let id_front_photo_url: String?
    let id_back_photo_url: String?
    let reviewed_at: String?
    let created_at: String?
    let updated_at: String?
}

struct PersonalInfoEmployeeRef: Codable {
    let id: Int?
    let full_name: String?
    let email: String?
    let employee_id: String?
}

struct PersonalInfoReviewerRef: Codable {
    let id: Int?
    let full_name: String?
}

struct PersonalInfoListResponse: Codable {
    let data: PersonalInfoListData?
    let success: Bool?
}

struct PersonalInfoListData: Codable {
    let personal_info_requests: [PersonalInfoRequest]
    let meta: PaginationMeta?
}

struct PersonalInfoDetailResponse: Codable {
    let data: PersonalInfoDetailData?
    let success: Bool?
}

struct PersonalInfoDetailData: Codable {
    let personal_info_request: PersonalInfoRequest?
}

struct PersonalInfoActionResponse: Codable {
    let data: PersonalInfoActionData?
    let success: Bool?
    let message: String?
}

struct PersonalInfoActionData: Codable {
    let personal_info_request: PersonalInfoRequest?
}
