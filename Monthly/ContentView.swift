import SwiftUI
import SwiftData
import WidgetKit

/// Main screen: the big "left this month" number, then this month's purchases.
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    // @Query keeps this list in sync with the database automatically.
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]

    // @AppStorage re-draws the screen whenever a setting changes.
    @AppStorage(Settings.budgetKey, store: AppConfig.defaults) private var budget: Double = 1000
    @AppStorage(Settings.startDayKey, store: AppConfig.defaults) private var startDay: Int = 1

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var editing: Expense?

    private var period: BudgetPeriod { BudgetPeriod.containing(.now, startDay: startDay) }
    private var expenses: [Expense] { allExpenses.filter { period.contains($0.date) } }
    private var summary: BudgetSummary {
        BudgetSummary(budget: budget, spent: expenses.reduce(0) { $0 + $1.amount }, period: period, now: .now)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    header
                }
                Section("This month") {
                    if expenses.isEmpty {
                        Text("No purchases yet.").foregroundStyle(.secondary)
                    }
                    ForEach(expenses) { expense in
                        Button { editing = expense } label: { row(expense) }
                            .tint(.primary)
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Monthly")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSettings = true } label: { Image(systemName: "gearshape") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) { ExpenseFormView(expense: nil) }
            .sheet(item: $editing) { ExpenseFormView(expense: $0) }
            .sheet(isPresented: $showingSettings) { SettingsView() }
        }
        // monthly://add opens the add screen (used by the lock screen button).
        .onOpenURL { url in
            if url.host == "add" { showingAdd = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: QuickAddIntent.notification)) { _ in
            checkPendingQuickAdd()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { checkPendingQuickAdd() }
        }
        .onAppear { checkPendingQuickAdd() }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text(summary.remaining.money())
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(summary.remaining < 0 ? .red : .primary)
                .contentTransition(.numericText())
            Text("left of \(budget.money())")
                .foregroundStyle(.secondary)
            ProgressView(value: summary.fractionLeft)
                .tint(summary.fractionLeft < 0.2 ? .red : .green)
                .padding(.top, 4)
            Text("\(summary.perDay.money())/day for \(summary.daysLeft) days")
                .font(.headline)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func row(_ expense: Expense) -> some View {
        HStack {
            Image(systemName: expense.source == "applePay" ? "wave.3.right.circle.fill" : "pencil.circle.fill")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading) {
                Text(expense.merchant.isEmpty ? "Purchase" : expense.merchant)
                Text(expense.date, format: .dateTime.month().day().hour().minute())
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(expense.amount < 0 ? "+" + (-expense.amount).money(decimals: 2) : expense.amount.money(decimals: 2))
                .foregroundStyle(expense.amount < 0 ? .green : .primary)
                .monospacedDigit()
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets { context.delete(expenses[index]) }
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func checkPendingQuickAdd() {
        if AppConfig.defaults.bool(forKey: QuickAddIntent.pendingKey) {
            AppConfig.defaults.set(false, forKey: QuickAddIntent.pendingKey)
            showingAdd = true
        }
    }
}
