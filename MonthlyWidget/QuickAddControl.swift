import SwiftUI
import WidgetKit

/// A "+" button you can put in the lock screen corners or Control Center (iOS 18+).
/// Pressing it opens Monthly straight to the add-expense screen with the keypad up.
struct QuickAddControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "QuickAddControl") {
            ControlWidgetButton(action: QuickAddIntent()) {
                Label("Add Expense", systemImage: "plus.circle.fill")
            }
        }
        .displayName("Add Expense")
        .description("Log a purchase in Monthly.")
    }
}
