import SwiftUI

@main
struct MerotOutsourcingApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .accentColor(.accent)
        }
    }
}
