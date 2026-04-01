import Foundation

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    
    init() {
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        isAuthenticated = networkManager.isAuthenticated
    }
    
    @MainActor
    func login(email: String, password: String, userType: String = "employer") async {
        isLoading = true
        errorMessage = nil
        
        let loginRequest = LoginRequest(
            email: email,
            password: password,
            userType: userType
        )
        
        do {
            let response: APIResponse<LoginResponse> = try await networkManager.post(
                endpoint: "/auth/login",
                body: loginRequest,
                responseType: APIResponse<LoginResponse>.self
            )
            
            if response.success {
                networkManager.setAuthTokens(
                    token: response.data.token,
                    refreshToken: response.data.refreshToken
                )
                currentUser = response.data.user
                isAuthenticated = true
            } else {
                errorMessage = response.message ?? "Unknown error"
            }
        } catch {
            if let networkError = error as? NetworkManager.NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = "Login failed: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func logout() async {
        isLoading = true
        
        do {
            let _: APIResponse<EmptyResponse> = try await networkManager.post(
                endpoint: "/auth/logout",
                body: EmptyRequest(),
                responseType: APIResponse<EmptyResponse>.self
            )
        } catch {
            print("Logout request failed: \(error)")
        }
        
        networkManager.clearAuthTokens()
        currentUser = nil
        isAuthenticated = false
        isLoading = false
    }
    
    @MainActor
    func refreshToken() async -> Bool {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") else {
            await logout()
            return false
        }
        
        let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
        
        do {
            let response: APIResponse<LoginResponse> = try await networkManager.post(
                endpoint: "/auth/refresh",
                body: refreshRequest,
                responseType: APIResponse<LoginResponse>.self
            )
            
            if response.success {
                networkManager.setAuthTokens(
                    token: response.data.token,
                    refreshToken: response.data.refreshToken
                )
                currentUser = response.data.user
                return true
            } else {
                await logout()
                return false
            }
        } catch {
            await logout()
            return false
        }
    }
    
    @MainActor
    func getProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: APIResponse<UserProfileWrapper> = try await networkManager.get(
                endpoint: "/auth/profile",
                responseType: APIResponse<UserProfileWrapper>.self
            )
            
            if response.success {
                currentUser = response.data.user
            } else {
                errorMessage = response.message ?? "Unknown error"
            }
        } catch {
            if let networkError = error as? NetworkManager.NetworkError {
                if case .authenticationError = networkError {
                    let refreshed = await refreshToken()
                    if refreshed {
                        await getProfile()
                        return
                    }
                }
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = "Failed to get profile: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
    let userType: String
    
    enum CodingKeys: String, CodingKey {
        case email, password
        case userType = "user_type"
    }
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct LoginResponse: Codable {
    let token: String
    let refreshToken: String
    let user: User
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
        case user
        case expiresAt = "expires_at"
    }
}

struct EmptyRequest: Codable {}
struct EmptyResponse: Codable {}