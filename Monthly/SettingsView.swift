import SwiftUI
import WidgetKit

/// Set your monthly budget and the day it resets.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(Settings.budgetKey, store: AppConfig.defaults) private var budget: Double = 1000
    @AppStorage(Settings.startDayKey, store: AppConfig.defaults) private var startDay: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                Section("Budget") {
                    TextField(
                        "Monthly budget",
                        value: $budget,
                        format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                    )
                    .keyboardType(.decimalPad)

                    Picker("Resets on day", selection: $startDay) {
                        ForEach(1...28, id: \.self) { Text("\($0)").tag($0) }
                    }
                }

                Section("Apple Pay auto-logging") {
                    Text("""
                    Shortcuts app → Automation → + → Transaction. Pick your cards, \
                    choose "Run Immediately", then add the action "Log Expense" (Monthly). \
                    Set Amount to Shortcut Input › Amount and Merchant to Shortcut Input › Merchant.
                    """)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onDisappear { WidgetCenter.shared.reloadAllTimelines() }
        }
    }
}
