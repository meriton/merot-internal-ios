import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: AdminUser?
    @Published var userType: String = "admin" // "admin", "employer", "employee"
    @Published var isLoading = false
    @Published var error: String?
    @Published var isCheckingSession = true

    private let api = APIService.shared

    func checkExistingSession() async {
        guard api.hasToken else {
            isCheckingSession = false
            return
        }
        // Restore saved user type
        userType = UserDefaults.standard.string(forKey: "merot_user_type") ?? "admin"
        do {
            let endpoint = userType == "admin" ? "/auth/profile" : "/\(userType == "employer" ? "employers" : "employees")/profile"
            let res: ProfileResponse = try await api.request("GET", endpoint)
            if let u = res.data?.user {
                user = u
                isAuthenticated = true
            } else {
                api.clearTokens()
            }
        } catch {
            api.clearTokens()
            isAuthenticated = false
            self.error = nil // Don't show error on login screen for stale sessions
        }
        isCheckingSession = false
    }

    func login(email: String, password: String, userType: String = "admin") async {
        isLoading = true
        error = nil
        do {
            let res: LoginResponse = try await api.request("POST", "/auth/login", body: [
                "email": email,
                "password": password,
                "user_type": userType
            ])
            if let data = res.data {
                api.setTokens(access: data.access_token, refresh: data.refresh_token)
                user = data.user
                self.userType = userType
                UserDefaults.standard.set(userType, forKey: "merot_user_type")
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
            let _: SimpleResponse? = try? await api.request("POST", "/auth/logout")
        }
        api.clearTokens()
        user = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "merot_user_type")
    }

    func updateProfile(firstName: String, lastName: String, phoneNumber: String) async -> Bool {
        error = nil
        do {
            var body: [String: Any] = [:]
            if firstName != (user?.first_name ?? "") { body["first_name"] = firstName }
            if lastName != (user?.last_name ?? "") { body["last_name"] = lastName }
            if phoneNumber != (user?.phone_number ?? "") { body["phone_number"] = phoneNumber }
            guard !body.isEmpty else { return true }

            let endpoint = userType == "admin" ? "/auth/profile" : "/\(userType == "employer" ? "employers" : "employees")/profile"
            let res: ProfileResponse = try await api.request("PUT", endpoint, body: body)
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
            let endpoint = userType == "admin" ? "/auth/profile" : "/\(userType == "employer" ? "employers" : "employees")/profile"
            let _: ProfileResponse = try await api.request("PUT", endpoint, body: [
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
