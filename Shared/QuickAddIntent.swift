import AppIntents
import Foundation

/// Runs when you press the "Add Expense" button on the lock screen or in Control Center.
/// It opens the app and leaves a note asking the app to show the add-expense screen.
/// This file is compiled into BOTH the app and the widget, which iOS requires for controls.
struct QuickAddIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var description = IntentDescription("Open Monthly straight to the add-expense screen.")
    static var openAppWhenRun = true

    static let pendingKey = "pendingQuickAdd"
    static let notification = Notification.Name("MonthlyQuickAdd")

    @MainActor
    func perform() async throws -> some IntentResult {
        AppConfig.defaults.set(true, forKey: Self.pendingKey)
        NotificationCenter.default.post(name: Self.notification, object: nil)
        return .result()
    }
}
