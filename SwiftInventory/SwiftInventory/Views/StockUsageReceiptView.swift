import SwiftUI

// Receipt shown after a stock usage deduction. This is not a sale:
// no revenue or transaction number is involved.
struct StockUsageReceiptView: View {

    let usage: StockUsage

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            receiptArea
        }
        .background(SITheme.background)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 92, height: 92)
                .background(SITheme.navy)
                .clipShape(Circle())
                .shadow(color: SITheme.navy.opacity(0.35), radius: 14, y: 8)

            Text("Stock Usage Recorded")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Reference \(usage.formattedReference)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 42)
        .padding(.bottom, 34)
        .background(SITheme.deepNavy)
    }

    private var receiptArea: some View {
        ScrollView {
            VStack(spacing: 18) {
                receiptCard
                doneButton
            }
            .padding()
            .padding(.top, -10)
        }
    }

    private var receiptCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Usage Details")
                .font(.headline)
                .fontWeight(.bold)

            UsageDetailRow(title: "Product", value: usage.productName)

            UsageDetailRow(title: "Quantity Removed", value: "\(usage.quantity)")

            UsageDetailRow(title: "Reason", value: usage.reason.rawValue)

            if !usage.notes.isEmpty {
                UsageDetailRow(title: "Notes", value: usage.notes)
            }

            Divider()

            UsageDetailRow(
                title: "Remaining Stock",
                value: "\(usage.remainingStock)",
                isBold: true
            )

            UsageDetailRow(
                title: "Date",
                value: usage.date.formatted(date: .abbreviated, time: .shortened)
            )

            Label(
                "This is not a sale. No revenue was recorded.",
                systemImage: "info.circle.fill"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .siCard()
    }

    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Label("Done", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(SITheme.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

struct UsageDetailRow: View {

    let title: String
    let value: String
    var isBold = false

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(isBold ? .bold : .semibold)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        StockUsageReceiptView(
            usage: StockUsage(
                id: UUID(),
                referenceNumber: 1,
                productID: "piattos",
                productName: "Piattos",
                productCategory: "Snacks",
                quantity: 2,
                reason: .damaged,
                notes: "Crushed during delivery",
                remainingStock: 28,
                date: Date()
            )
        )
    }
}
