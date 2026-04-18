import Foundation

struct JobApplicationBrief: Codable, Identifiable {
    let id: Int
    let full_name: String?
    let email: String?
    let phone: String?
    let status: String?
    let events_count: Int?
    let created_at: String?
}

struct JobApplication: Codable, Identifiable {
    let id: Int
    let full_name: String?
    let first_name: String?
    let last_name: String?
    let email: String?
    let phone: String?
    let status: String?
    let job_posting: JobApplicationPostingRef?
    let events_count: Int?
    let can_be_converted: Bool?
    let cover_letter: String?
    let linkedin_url: String?
    let portfolio_url: String?
    let hired_at: String?
    let converted_to_employee_user_id: Int?
    let converted_at: String?
    let has_resume: Bool?
    let created_at: String?
    let updated_at: String?
}

struct JobApplicationPostingRef: Codable {
    let id: Int?
    let title: String?
    let employer_name: String?
}

struct JobApplicationEvent: Codable, Identifiable {
    let id: Int
    let event_type: String?
    let notes: String?
    let scheduled_date: String?
    let scheduled_at: String?
    let interview_type: String?
    let location: String?
    let is_private: Bool?
    let previous_status: String?
    let new_status: String?
    let created_by: JobEventCreatedBy?
    let created_at: String?
}

struct JobEventCreatedBy: Codable {
    let id: Int?
    let full_name: String?
}

struct JobApplicationsListResponse: Codable {
    let data: JobApplicationsListData?
    let success: Bool?
}

struct JobApplicationsListData: Codable {
    let job_applications: [JobApplication]
    let meta: PaginationMeta?
}

struct JobApplicationDetailResponse: Codable {
    let data: JobApplicationDetailData?
    let success: Bool?
}

struct JobApplicationDetailData: Codable {
    let job_application: JobApplication?
    let events: [JobApplicationEvent]?
}

struct JobApplicationActionResponse: Codable {
    let data: JobApplicationActionData?
    let success: Bool?
    let message: String?
}

struct JobApplicationActionData: Codable {
    let job_application: JobApplication?
}
