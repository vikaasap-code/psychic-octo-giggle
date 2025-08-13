import SwiftUI

@main
struct AstroMatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserManager())
                .environmentObject(AstrologyService())
        }
    }
}