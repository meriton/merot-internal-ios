import Foundation

struct JobPosting: Codable, Identifiable {
    let id: Int
    let title: String?
    let status: String?
    let employer_id: Int?
    let employer: JobPostingEmployerRef?
    let department: String?
    let location: String?
    let employment_type: String?
    let experience_level: String?
    let salary_min: FlexDouble?
    let salary_max: FlexDouble?
    let salary_currency: String?
    let positions_available: Int?
    let positions_filled: Int?
    let applications_count: Int?
    let published_at: String?
    let expires_at: String?
    let created_at: String?
    let updated_at: String?
    // Detail fields
    let description: String?
    let requirements: String?
    let benefits: String?
    let salary_period: String?
    let created_by: JobPostingCreatedBy?
}

struct JobPostingEmployerRef: Codable {
    let id: Int?
    let name: String?
}

struct JobPostingCreatedBy: Codable {
    let id: Int?
    let full_name: String?
}

struct JobPostingsListResponse: Codable {
    let data: JobPostingsListData?
    let success: Bool?
}

struct JobPostingsListData: Codable {
    let job_postings: [JobPosting]
    let meta: PaginationMeta?
}

struct JobPostingDetailResponse: Codable {
    let data: JobPostingDetailData?
    let success: Bool?
}

struct JobPostingDetailData: Codable {
    let job_posting: JobPosting?
    let applications: [JobApplicationBrief]?
}

struct JobPostingActionResponse: Codable {
    let data: JobPostingActionData?
    let success: Bool?
    let message: String?
}

struct JobPostingActionData: Codable {
    let job_posting: JobPosting?
}
