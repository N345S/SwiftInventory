import SwiftUI

struct StockUsageView: View {

    let product: Product

    @EnvironmentObject var appController: AppController

    @State private var quantityText = ""
    @State private var reason: StockUsage.Reason = .personalUse
    @State private var notes = ""

    @State private var showAuthorization = false

    // Set inside the sheet on success, acted on only after the
    // sheet has fully dismissed. Recording the usage (and pushing
    // the receipt) mid-dismissal caused blank-screen navigation.
    @State private var pendingAuthorization = false

    @State private var completedUsage: StockUsage?
    @State private var showReceipt = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var availableStock: Int {
        appController.inventoryController.item(for: product)?.quantity ?? 0
    }

    private var quantity: Int {
        Int(quantityText) ?? 0
    }

    private var isValid: Bool {
        quantity > 0 && quantity <= availableStock
    }

    var body: some View {
        VStack(spacing: 0) {
            SIHeader(
                title: "Record Stock Usage",
                subtitle: product.name,
                icon: "minus.square.fill"
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    stockInfo
                    quantityField
                    reasonPicker
                    notesField
                    recordButton
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(SITheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAuthorization) {
            if pendingAuthorization {
                pendingAuthorization = false
                recordUsage()
            }
        } content: {
            StockUsageAuthorizationView {
                pendingAuthorization = true
            }
        }
        .navigationDestination(isPresented: $showReceipt) {
            if let completedUsage {
                StockUsageReceiptView(usage: completedUsage)
                    .environmentObject(appController)
            }
        }
        .alert("Unable to Record Usage", isPresented: $showError) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text(errorMessage)
        }
    }

    private var stockInfo: some View {
        HStack(spacing: 12) {
            ProductBadge(product: product, size: 50)

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text(product.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(availableStock)")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("in stock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .siCard()
    }

    private var quantityField: some View {
        VStack(alignment: .leading, spacing: 14) {
            AddStockField(
                title: "Quantity to Remove",
                placeholder: "0",
                text: $quantityText,
                keyboard: .numberPad
            )

            if quantity > availableStock {
                Label(
                    "Only \(availableStock) in stock.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.red)
            }
        }
        .padding()
        .siCard()
    }

    private var reasonPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reason")
                .font(.headline)
                .fontWeight(.bold)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(StockUsage.Reason.allCases, id: \.self) { option in
                    Button {
                        reason = option
                    } label: {
                        Label(option.rawValue, systemImage: option.icon)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                reason == option
                                ? SITheme.navy
                                : SITheme.card
                            )
                            .foregroundStyle(
                                reason == option
                                ? .white
                                : .secondary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Notes (optional)")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Add a note...", text: $notes, axis: .vertical)
                .lineLimit(2...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(SITheme.softFill)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .siCard()
    }

    private var recordButton: some View {
        Button {
            // Stock is only deducted after PIN authorization
            // succeeds inside the sheet's callback.
            showAuthorization = true
        } label: {
            Label("Record Usage", systemImage: "lock.shield.fill")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? SITheme.navy : Color(.systemGray4))
                .foregroundStyle(isValid ? .white : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .disabled(!isValid)
    }

    private func recordUsage() {
        // Re-validate; stock may have changed while the sheet was up.
        guard isValid else {
            errorMessage = "The quantity is no longer valid for the available stock."
            showError = true
            return
        }

        let usage = appController.inventoryController.recordUsage(
            product: product,
            quantity: quantity,
            reason: reason,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        if let usage {
            completedUsage = usage
            showReceipt = true
        } else {
            errorMessage = "The stock usage could not be recorded."
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        StockUsageView(
            product: Product(
                name: "Coca-Cola 1.5L",
                category: "Drinks",
                costPrice: 45,
                sellingPrice: 60
            )
        )
        .environmentObject(AppController())
    }
}
