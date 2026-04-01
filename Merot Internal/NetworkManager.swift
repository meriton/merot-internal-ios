import Foundation

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    var baseURL: String {
        #if DEBUG
        #if targetEnvironment(simulator)
        return "http://localhost:3000/api"  // Simulator can reach localhost
        #else
        return "https://internal.merot.com/api"  // Real device needs production URL
        #endif
        #else
        return "https://internal.merot.com/api"  // Release builds always use production
        #endif
    }
    
    private let session = URLSession.shared
    
    private init() {}
    
    private var token: String? {
        get {
            UserDefaults.standard.string(forKey: "jwt_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "jwt_token")
        }
    }
    
    private var refreshToken: String? {
        get {
            UserDefaults.standard.string(forKey: "refresh_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "refresh_token")
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError
        case authenticationError
        case serverError(String)
        case networkError(Error)
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .authenticationError:
                return "Authentication failed"
            case .serverError(let message):
                return "Server error: \(message)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    private func createRequest(url: URL, method: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Skip CSRF for API requests
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func performRequest<T: Decodable>(
        request: URLRequest,
        responseType: T.Type
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(URLError(.badServerResponse))
            }
            
            if httpResponse.statusCode == 401 {
                throw NetworkError.authenticationError
            }
            
            if httpResponse.statusCode >= 400 {
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse.message)
                } else {
                    throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                return try decoder.decode(responseType, from: data)
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                throw NetworkError.decodingError
            }
        } catch let urlError as URLError where urlError.code == .cancelled {
            // Handle cancellation specifically - this is normal behavior
            print("NetworkManager: Request was cancelled (Code: \(urlError.code.rawValue))")
            throw NetworkError.networkError(urlError)
        } catch is CancellationError {
            // Handle Swift concurrency cancellation
            print("NetworkManager: Task was cancelled")
            throw CancellationError()
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    func get<T: Decodable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        let request = createRequest(url: url, method: .GET)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    func post<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(body)
        
        let request = createRequest(url: url, method: .POST, body: bodyData)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    func put<T: Encodable, U: Decodable>(
        endpoint: String,
        body: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(body)
        
        let request = createRequest(url: url, method: .PUT, body: bodyData)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    func delete<T: Decodable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        let request = createRequest(url: url, method: .DELETE)
        return try await performRequest(request: request, responseType: responseType)
    }
    
    func setAuthTokens(token: String, refreshToken: String) {
        self.token = token
        self.refreshToken = refreshToken
    }
    
    func clearAuthTokens() {
        self.token = nil
        self.refreshToken = nil
    }
    
    var isAuthenticated: Bool {
        return token != nil
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}