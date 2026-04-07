import Foundation

// MARK: - API Error

enum APIError: Error, LocalizedError {
    case unauthorized
    case forbidden(String)
    case badRequest(String)
    case notFound(String)
    case serverError(String)
    case networkError

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Session expired. Please log in again."
        case .forbidden(let msg): return msg
        case .badRequest(let msg): return msg
        case .notFound(let msg): return msg
        case .serverError(let msg): return msg
        case .networkError: return "Network error. Please check your connection."
        }
    }
}

// MARK: - API Response

struct APIResponse<T: Codable>: Codable {
    let data: T?
    let success: Bool?
    let message: String?
    let errors: [String]?
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: T?
    let success: Bool?
    let message: String?
    let meta: PaginationMeta?
}

struct PaginationMeta: Codable {
    let page: Int?
    let per_page: Int?
    let total_count: Int?
    let total_pages: Int?
}

// MARK: - Flexible number decoder (handles string/number)

struct FlexDouble: Codable, Comparable {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let d = try? container.decode(Double.self) { value = d }
        else if let i = try? container.decode(Int.self) { value = Double(i) }
        else if let s = try? container.decode(String.self), let d = Double(s) { value = d }
        else { value = 0 }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    static func < (lhs: FlexDouble, rhs: FlexDouble) -> Bool { lhs.value < rhs.value }
    static func > (lhs: FlexDouble, rhs: Int) -> Bool { lhs.value > Double(rhs) }
    static func > (lhs: FlexDouble, rhs: Double) -> Bool { lhs.value > rhs }
}

// MARK: - API Service

class APIService {
    static let shared = APIService()

    #if DEBUG
    private let baseURL = "http://localhost:3000/api/v2"
    #else
    private let baseURL = "https://internal.merot.com/api/v2"
    #endif

    private var accessToken: String? {
        get { KeychainHelper.read(key: "merot_internal_access_token") }
        set {
            if let v = newValue { KeychainHelper.save(key: "merot_internal_access_token", value: v) }
            else { KeychainHelper.delete(key: "merot_internal_access_token") }
        }
    }

    private var refreshToken: String? {
        get { KeychainHelper.read(key: "merot_internal_refresh_token") }
        set {
            if let v = newValue { KeychainHelper.save(key: "merot_internal_refresh_token", value: v) }
            else { KeychainHelper.delete(key: "merot_internal_refresh_token") }
        }
    }

    var hasToken: Bool { accessToken != nil }

    func setTokens(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }

    // MARK: - Generic JSON request

    func request<T: Codable>(
        _ method: String,
        _ path: String,
        body: [String: Any]? = nil,
        query: [String: String]? = nil
    ) async throws -> T {
        var urlString = "\(baseURL)\(path)"
        if let q = query, !q.isEmpty {
            let qs = q.map { "\($0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }.joined(separator: "&")
            urlString += "?\(qs)"
        }

        guard let url = URL(string: urlString) else { throw APIError.networkError }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 30

        if let t = accessToken {
            req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.networkError }

        if http.statusCode == 401 {
            // Try token refresh
            if let newAccess = try? await performTokenRefresh() {
                accessToken = newAccess
                req.setValue("Bearer \(newAccess)", forHTTPHeaderField: "Authorization")
                let (retryData, retryResponse) = try await URLSession.shared.data(for: req)
                guard let retryHttp = retryResponse as? HTTPURLResponse else { throw APIError.networkError }
                if retryHttp.statusCode == 401 { throw APIError.unauthorized }
                return try handleResponse(retryData, statusCode: retryHttp.statusCode)
            }
            throw APIError.unauthorized
        }

        return try handleResponse(data, statusCode: http.statusCode)
    }

    // MARK: - Raw data request (for PDFs)

    func requestData(_ method: String, _ path: String) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(path)") else { throw APIError.networkError }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = 60
        if let t = accessToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError("Download failed")
        }
        return data
    }

    // MARK: - Helpers

    private func handleResponse<T: Codable>(_ data: Data, statusCode: Int) throws -> T {
        if statusCode == 403 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = json["message"] as? String {
                throw APIError.forbidden(msg)
            }
            throw APIError.forbidden("Access denied")
        }

        if statusCode == 404 {
            throw APIError.notFound("Not found")
        }

        if statusCode >= 400 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let errors = json["errors"] as? [String], let first = errors.first {
                    throw APIError.badRequest(first)
                }
                if let msg = json["message"] as? String {
                    throw APIError.badRequest(msg)
                }
            }
            throw APIError.serverError("Server error (\(statusCode))")
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    private func performTokenRefresh() async throws -> String? {
        guard let rt = refreshToken else { return nil }

        let body: [String: Any] = ["refresh_token": rt]
        guard let url = URL(string: "\(baseURL)/auth/refresh") else { return nil }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

        struct RefreshResponse: Codable {
            let data: RefreshData?
        }
        struct RefreshData: Codable {
            let access_token: String
            let refresh_token: String
        }

        let decoded = try JSONDecoder().decode(RefreshResponse.self, from: data)
        if let tokens = decoded.data {
            refreshToken = tokens.refresh_token
            return tokens.access_token
        }
        return nil
    }
}
