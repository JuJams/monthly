import SwiftUI
import WidgetKit

/// Lists everything this extension provides: the budget widget and the quick-add button.
@main
struct MonthlyWidgetBundle: WidgetBundle {
    var body: some Widget {
        BudgetWidget()
        QuickAddControl()
    }
}
