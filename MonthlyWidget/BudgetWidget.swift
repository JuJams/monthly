import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Data

struct BudgetEntry: TimelineEntry {
    let date: Date
    let summary: BudgetSummary
}

/// iOS asks this for what to show. We read the database, then ask to be refreshed at
/// midnight (so the per-day number updates). New purchases refresh it immediately.
struct BudgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BudgetEntry {
        BudgetEntry(date: .now, summary: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (BudgetEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetEntry>) -> Void) {
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: .now) ?? .now)
        completion(Timeline(entries: [currentEntry()], policy: .after(tomorrow)))
    }

    private func currentEntry() -> BudgetEntry {
        let context = ModelContext(SharedStore.container)
        return BudgetEntry(date: .now, summary: BudgetSummary.load(context: context))
    }
}

// MARK: - Views

struct BudgetWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: BudgetEntry

    private var s: BudgetSummary { entry.summary }

    var body: some View {
        switch family {
        case .accessoryInline:
            // One line above the clock: "$980 left · $33/day"
            Text("\(s.remaining.money()) left · \(s.perDay.money())/day")

        case .accessoryCircular:
            // Small ring below the clock.
            Gauge(value: s.fractionLeft) {
                Text("Left")
            } currentValueLabel: {
                Text(s.remaining.money())
                    .minimumScaleFactor(0.5)
            }
            .gaugeStyle(.accessoryCircularCapacity)

        case .accessoryRectangular:
            // The main lock screen widget.
            VStack(alignment: .leading, spacing: 2) {
                Text(s.remaining.money())
                    .font(.system(.title, design: .rounded).bold())
                    .minimumScaleFactor(0.6)
                Text("\(s.perDay.money())/day · \(s.daysLeft)d left")
                    .font(.caption)
                Gauge(value: s.fractionLeft) { EmptyView() }
                    .gaugeStyle(.accessoryLinearCapacity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        default:
            // Home screen version.
            VStack(alignment: .leading, spacing: 4) {
                Text("Left this month")
                    .font(.caption).foregroundStyle(.secondary)
                Text(s.remaining.money())
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(s.remaining < 0 ? .red : .primary)
                    .minimumScaleFactor(0.5)
                Spacer()
                Text("\(s.perDay.money())/day")
                    .font(.headline)
                Text("\(s.daysLeft) days left")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Widget

struct BudgetWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BudgetWidget", provider: BudgetProvider()) { entry in
            BudgetWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(URL(string: "monthly://home"))
        }
        .configurationDisplayName("Money Left")
        .description("How much of this month's budget is left.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .accessoryCircular, .systemSmall])
    }
}
