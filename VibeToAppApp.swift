import SwiftUI

@main
struct VibeToAppApp: App {
    // Create the single source of truth for our app's brain
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainLayoutView()
                // Inject the brain globally into the environment 
                // so any sub-view can read tokens/models instantly
                .environmentObject(appState)
        }
    }
}
