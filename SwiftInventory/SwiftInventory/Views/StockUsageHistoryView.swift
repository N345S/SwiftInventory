import SwiftUI

struct StockUsageHistoryView: View {

    @EnvironmentObject var appController: AppController

    private var usages: [StockUsage] {
        appController.inventoryController.usages.reversed()
    }

    private var totalItemsRemoved: Int {
        appController.inventoryController.usages.reduce(0) {
            $0 + $1.quantity
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SIHeader(
                title: "Stock Usage History",
                subtitle: "Non-sale stock deductions.",
                icon: "minus.square.fill"
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    totalCard

                    if usages.isEmpty {
                        emptyState
                    } else {
                        ForEach(usages) { usage in
                            UsageHistoryCard(usage: usage)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(SITheme.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var totalCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Items Removed")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(totalItemsRemoved)")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Spacer()

            Image(systemName: "archivebox.fill")
                .font(.title3)
                .foregroundStyle(SITheme.navy)
                .frame(width: 40, height: 40)
                .background(SITheme.navy.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        .padding()
        .siCard()
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "archivebox")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)

            Text("No stock usage recorded yet")
                .font(.headline)

            Text("Non-sale deductions will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 38)
        .siCard()
    }
}

struct UsageHistoryCard: View {

    let usage: StockUsage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(usage.productName)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Text("\(usage.formattedReference) • \(usage.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(
                    title: usage.reason.rawValue,
                    icon: usage.reason.icon,
                    color: SITheme.navy
                )
            }

            Divider()

            SummaryRow(
                title: "Quantity Removed",
                value: "\(usage.quantity)"
            )

            SummaryRow(
                title: "Remaining Stock",
                value: "\(usage.remainingStock)"
            )

            if !usage.notes.isEmpty {
                SummaryRow(
                    title: "Notes",
                    value: usage.notes
                )
            }
        }
        .padding()
        .siCard()
    }
}

#Preview {
    NavigationStack {
        StockUsageHistoryView()
            .environmentObject(AppController())
    }
}
