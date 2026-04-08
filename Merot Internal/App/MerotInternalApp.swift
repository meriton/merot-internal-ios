import SwiftUI

@main
struct MerotInternalApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .accentColor(.accent)
        }
    }
}
