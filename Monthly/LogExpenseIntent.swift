import AppIntents
import SwiftData
import WidgetKit

/// The "Log Expense" action that shows up in the Shortcuts app.
/// Your Apple Pay automation calls this every time you tap your phone to pay.
/// It runs in the background — the app never opens.
struct LogExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Expense"
    static var description = IntentDescription("Subtract a purchase from this month's Monthly budget.")
    static var openAppWhenRun = false

    @Parameter(title: "Amount")
    var amount: String

    @Parameter(title: "Merchant")
    var merchant: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amount) at \(\.$merchant)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let value = AmountParser.parse(amount), value != 0 else {
            throw LogExpenseError.badAmount(amount)
        }

        let context = SharedStore.container.mainContext
        context.insert(Expense(amount: value, merchant: merchant ?? "", source: "applePay"))
        try context.save()

        // Tell the lock screen widget to redraw with the new number.
        WidgetCenter.shared.reloadAllTimelines()

        let summary = BudgetSummary.load(context: context)
        return .result(value: "\(summary.remaining.money()) left")
    }
}

enum LogExpenseError: Error, CustomLocalizedStringResourceConvertible {
    case badAmount(String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .badAmount(let text):
            return "Monthly couldn't read an amount from \"\(text)\"."
        }
    }
}
