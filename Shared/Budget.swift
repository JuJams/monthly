import Foundation
import SwiftData

/// The current budget window, e.g. Nov 1 (inclusive) to Dec 1 (exclusive).
struct BudgetPeriod {
    let start: Date
    let end: Date

    static func containing(_ date: Date, startDay: Int, calendar: Calendar = .current) -> BudgetPeriod {
        var parts = calendar.dateComponents([.year, .month], from: date)
        parts.day = Settings.clampStartDay(startDay)
        var start = calendar.date(from: parts) ?? date
        // If this month's reset day hasn't happened yet, we're still in last month's period.
        if start > date {
            start = calendar.date(byAdding: .month, value: -1, to: start) ?? start
        }
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        return BudgetPeriod(start: start, end: end)
    }

    func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}

/// Everything the widget and app need to show: what's left, and how much per day.
struct BudgetSummary {
    let budget: Double
    let spent: Double
    let period: BudgetPeriod
    let now: Date

    var remaining: Double { budget - spent }

    /// Days left including today. On Nov 2 with a Dec 1 reset that's 29.
    var daysLeft: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: period.end).day ?? 1
        return max(days, 1)
    }

    var perDay: Double { max(remaining, 0) / Double(daysLeft) }

    /// 1.0 = untouched budget, 0.0 = all gone. Used for the ring on the lock screen.
    var fractionLeft: Double {
        guard budget > 0 else { return 0 }
        return min(max(remaining / budget, 0), 1)
    }

    /// Reads this period's expenses from the database and adds them up.
    static func load(context: ModelContext, now: Date = .now) -> BudgetSummary {
        let period = BudgetPeriod.containing(now, startDay: Settings.startDay)
        let start = period.start
        let end = period.end
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { $0.date >= start && $0.date < end }
        )
        let expenses = (try? context.fetch(descriptor)) ?? []
        let spent = expenses.reduce(0) { $0 + $1.amount }
        return BudgetSummary(budget: Settings.budget, spent: spent, period: period, now: now)
    }

    static let sample = BudgetSummary(
        budget: 1000, spent: 20,
        period: BudgetPeriod.containing(.now, startDay: 1),
        now: .now
    )
}

/// Turns text like "$20.00", "1,234.56", "12,50" or "-$5" into a number.
/// The Apple Pay automation hands us the amount as text, so we need this.
enum AmountParser {
    static func parse(_ text: String) -> Double? {
        let isNegative = text.contains("-") || text.contains("\u{2212}")
        let kept = text.filter { ($0.isASCII && $0.isNumber) || $0 == "." || $0 == "," }
        guard !kept.isEmpty else { return nil }

        var normalized = kept
        if let sep = kept.lastIndex(where: { $0 == "." || $0 == "," }) {
            let before = kept[..<sep].filter { $0 != "." && $0 != "," }
            let after = String(kept[kept.index(after: sep)...])
            // 1–2 digits after the last separator = cents. 3 digits = thousands ("1,000").
            normalized = (after.count == 1 || after.count == 2) ? "\(before).\(after)" : "\(before)\(after)"
        }
        guard let value = Double(normalized) else { return nil }
        return isNegative ? -value : value
    }
}

extension Double {
    /// Formats as money in your phone's currency, e.g. 980 -> "$980".
    func money(decimals: Int = 0) -> String {
        formatted(
            .currency(code: Locale.current.currency?.identifier ?? "USD")
                .precision(.fractionLength(decimals))
        )
    }
}
