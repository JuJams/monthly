import SwiftUI
import SwiftData

/// Where the app starts. It opens the shared database and shows the main screen.
@main
struct MonthlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SharedStore.container)
    }
}
