import Foundation
import SwiftData

/// One purchase (positive amount) or refund (negative amount).
/// `@Model` tells SwiftData to save these to disk for us.
@Model
final class Expense {
    var amount: Double = 0
    var merchant: String = ""
    var date: Date = Date()
    /// "applePay" when logged by the Shortcuts automation, "manual" when typed in.
    var source: String = "manual"

    init(amount: Double, merchant: String, date: Date = .now, source: String = "manual") {
        self.amount = amount
        self.merchant = merchant
        self.date = date
        self.source = source
    }
}

/// The app and the widget are separate programs. They share data through an "App Group" —
/// a folder both are allowed to read. Its ID comes from project.yml via Info.plist.
enum AppConfig {
    static let appGroupID: String =
        Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String ?? "group.com.example.monthly"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
}

/// The single database file, stored inside the App Group so the widget can read it.
enum SharedStore {
    static let container: ModelContainer = {
        let config = ModelConfiguration(groupContainer: .identifier(AppConfig.appGroupID))
        do {
            return try ModelContainer(for: Expense.self, configurations: config)
        } catch {
            fatalError("Could not open storage: \(error)")
        }
    }()
}

/// User settings, also stored in the App Group.
enum Settings {
    static let budgetKey = "monthlyBudget"
    static let startDayKey = "periodStartDay"

    static var budget: Double {
        let value = AppConfig.defaults.double(forKey: budgetKey)
        return value > 0 ? value : 1000
    }

    /// Day of the month the budget resets (1–28, so it exists in every month).
    static var startDay: Int {
        clampStartDay(AppConfig.defaults.integer(forKey: startDayKey))
    }

    static func clampStartDay(_ day: Int) -> Int {
        min(max(day, 1), 28)
    }
}
