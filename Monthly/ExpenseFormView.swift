import SwiftUI
import SwiftData
import WidgetKit

/// Add a new purchase/refund, or edit an existing one.
/// The number pad pops up immediately so a manual entry is: type amount → Save.
struct ExpenseFormView: View {
    let expense: Expense?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""
    @State private var merchant = ""
    @State private var date = Date.now
    @State private var isRefund = false
    @FocusState private var amountFocused: Bool

    private var parsedAmount: Double? {
        guard let value = AmountParser.parse(amountText), value > 0 else { return nil }
        return value
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $isRefund) {
                    Text("Purchase").tag(false)
                    Text("Refund").tag(true)
                }
                .pickerStyle(.segmented)

                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .focused($amountFocused)

                TextField("What was it? (optional)", text: $merchant)
                DatePicker("When", selection: $date)
            }
            .navigationTitle(expense == nil ? "Add" : "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).disabled(parsedAmount == nil)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        if let expense {
            amountText = String(format: "%.2f", abs(expense.amount))
            merchant = expense.merchant
            date = expense.date
            isRefund = expense.amount < 0
        }
        amountFocused = true
    }

    private func save() {
        guard let value = parsedAmount else { return }
        let signed = isRefund ? -value : value
        if let expense {
            expense.amount = signed
            expense.merchant = merchant
            expense.date = date
        } else {
            context.insert(Expense(amount: signed, merchant: merchant, date: date))
        }
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}
