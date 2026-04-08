import SwiftUI

@main
struct MerotInternalApp: App {
    @StateObject private var auth = AuthViewModel()

    init() {
        // Clear stored session when running UI tests so each test starts fresh
        if CommandLine.arguments.contains("--uitesting") {
            KeychainHelper.delete(key: "access_token")
            KeychainHelper.delete(key: "refresh_token")
            UserDefaults.standard.removeObject(forKey: "merot_user_type")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .accentColor(.accent)
        }
    }
}
