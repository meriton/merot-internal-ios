import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: AdminUser?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isCheckingSession = true

    private let api = APIService.shared

    func checkExistingSession() async {
        guard api.hasToken else {
            isCheckingSession = false
            return
        }
        do {
            let res: ProfileResponse = try await api.request("GET", "/auth/profile")
            if let u = res.data?.user {
                user = u
                isAuthenticated = true
            } else {
                api.clearTokens()
            }
        } catch {
            api.clearTokens()
            isAuthenticated = false
        }
        isCheckingSession = false
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let res: LoginResponse = try await api.request("POST", "/auth/login", body: [
                "email": email,
                "password": password,
                "user_type": "admin"
            ])
            if let data = res.data {
                api.setTokens(access: data.access_token, refresh: data.refresh_token)
                user = data.user
                isAuthenticated = true
            } else {
                error = res.message ?? "Login failed"
            }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Network error. Please try again."
        }
        isLoading = false
    }

    func logout() {
        Task {
            let _: APIResponse<String>? = try? await api.request("POST", "/auth/logout")
        }
        api.clearTokens()
        user = nil
        isAuthenticated = false
    }

    func updateProfile(firstName: String, lastName: String, phoneNumber: String) async -> Bool {
        error = nil
        do {
            var body: [String: Any] = [:]
            if firstName != (user?.first_name ?? "") { body["first_name"] = firstName }
            if lastName != (user?.last_name ?? "") { body["last_name"] = lastName }
            if phoneNumber != (user?.phone_number ?? "") { body["phone_number"] = phoneNumber }
            guard !body.isEmpty else { return true }

            let res: ProfileResponse = try await api.request("PUT", "/auth/profile", body: body)
            if let u = res.data?.user { user = u }
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to update profile"
        }
        return false
    }

    func changePassword(current: String, newPassword: String, confirmation: String) async -> Bool {
        error = nil
        do {
            let _: ProfileResponse = try await api.request("PUT", "/auth/profile", body: [
                "password": newPassword,
                "password_confirmation": confirmation
            ])
            return true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = "Failed to change password"
        }
        return false
    }
}
