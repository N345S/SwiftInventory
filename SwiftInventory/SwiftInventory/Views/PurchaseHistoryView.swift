import SwiftUI

struct PurchaseHistoryView: View {

    @EnvironmentObject var appController: AppController

    private var purchases: [StockPurchase] {
        appController.inventoryController.purchases.reversed()
    }

    private var totalSpent: Double {
        appController.inventoryController.purchases.reduce(0) {
            $0 + $1.totalCost
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SIHeader(
                title: "Purchase History",
                subtitle: "Stock bought from suppliers.",
                icon: "shippingbox.and.arrow.backward.fill"
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    totalCard

                    if purchases.isEmpty {
                        emptyState
                    } else {
                        ForEach(purchases) { purchase in
                            PurchaseHistoryCard(purchase: purchase)
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
                Text("Total Purchase Expenses")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("₱\(totalSpent, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Spacer()

            Image(systemName: "banknote.fill")
                .font(.title3)
                .foregroundStyle(SITheme.orange)
                .frame(width: 40, height: 40)
                .background(SITheme.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        .padding()
        .siCard()
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "shippingbox")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)

            Text("No purchases recorded yet")
                .font(.headline)

            Text("Stock purchases from Add Stock will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 38)
        .siCard()
    }
}

struct PurchaseHistoryCard: View {

    let purchase: StockPurchase

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(purchase.productName)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Text("\(purchase.formattedReference) • \(purchase.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(
                    title: purchase.purchaseType.rawValue,
                    icon: purchase.purchaseType == .bundle
                        ? "square.stack.3d.up.fill"
                        : "square.fill",
                    color: purchase.purchaseType == .bundle
                        ? SITheme.purple
                        : SITheme.blue
                )
            }

            Divider()

            if purchase.purchaseType == .bundle {
                SummaryRow(
                    title: "Bundles × Items per Bundle",
                    value: "\(purchase.numberOfBundles) × \(purchase.itemsPerBundle)"
                )

                SummaryRow(
                    title: "Bundle Price",
                    value: String(format: "₱%.2f", purchase.unitPrice)
                )
            } else {
                SummaryRow(
                    title: "Quantity",
                    value: "\(purchase.totalItems)"
                )

                SummaryRow(
                    title: "Price per Item",
                    value: String(format: "₱%.2f", purchase.unitPrice)
                )
            }

            SummaryRow(
                title: "Total Items Received",
                value: "\(purchase.totalItems)"
            )

            SummaryRow(
                title: "Cost per Item",
                value: String(format: "₱%.2f", purchase.costPerItem)
            )

            SummaryRow(
                title: "Total Cost",
                value: String(format: "₱%.2f", purchase.totalCost),
                valueColor: SITheme.navy
            )
        }
        .padding()
        .siCard()
    }
}

#Preview {
    NavigationStack {
        PurchaseHistoryView()
            .environmentObject(AppController())
    }
}
