import Foundation

struct AdminUser: Codable {
    let id: Int
    let email: String
    let user_type: String?
    let first_name: String?
    let last_name: String?
    let full_name: String?
    let phone_number: String?
    let department: String?
    let roles: [String]?
    let super_admin: Bool?

    var displayName: String { full_name ?? "\(first_name ?? "") \(last_name ?? "")".trimmingCharacters(in: .whitespaces) }
    var initials: String {
        let f = (first_name ?? "").prefix(1)
        let l = (last_name ?? "").prefix(1)
        return "\(f)\(l)".uppercased()
    }
}

struct LoginResponse: Codable {
    let data: LoginData?
    let success: Bool?
    let message: String?
}

struct LoginData: Codable {
    let access_token: String
    let refresh_token: String
    let user: AdminUser
    let expires_at: String?
}

struct ProfileResponse: Codable {
    let data: ProfileData?
    let success: Bool?
    let message: String?
}

struct ProfileData: Codable {
    let user: AdminUser
}
