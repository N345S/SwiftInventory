import SwiftUI

struct AddStockView: View {

    let product: Product

    @EnvironmentObject var appController: AppController
    @Environment(\.dismiss) private var dismiss

    @State private var purchaseType: StockPurchase.PurchaseType = .individual

    // Individual purchase fields
    @State private var quantityText = ""
    @State private var pricePerItemText = ""

    // Bundle purchase fields
    @State private var bundlesText = ""
    @State private var itemsPerBundleText = ""
    @State private var bundlePriceText = ""

    @State private var sellingPriceText = ""
    @State private var showConfirmation = false
    @State private var savedPurchase: StockPurchase?

    private var inventoryItem: InventoryItem? {
        appController.inventoryController.item(for: product)
    }

    private var quantity: Int {
        Int(quantityText) ?? 0
    }

    private var pricePerItem: Double {
        Double(pricePerItemText) ?? 0
    }

    private var bundles: Int {
        Int(bundlesText) ?? 0
    }

    private var itemsPerBundle: Int {
        Int(itemsPerBundleText) ?? 0
    }

    private var bundlePrice: Double {
        Double(bundlePriceText) ?? 0
    }

    private var sellingPrice: Double {
        Double(sellingPriceText) ?? 0
    }

    private var totalItems: Int {
        switch purchaseType {
        case .individual:
            return quantity
        case .bundle:
            return bundles * itemsPerBundle
        }
    }

    private var totalCost: Double {
        switch purchaseType {
        case .individual:
            return pricePerItem * Double(quantity)
        case .bundle:
            return bundlePrice * Double(bundles)
        }
    }

    private var costPerItem: Double {
        guard totalItems > 0 else {
            return 0
        }

        return totalCost / Double(totalItems)
    }

    private var expectedSales: Double {
        sellingPrice * Double(totalItems)
    }

    private var expectedProfit: Double {
        expectedSales - totalCost
    }

    private var isValid: Bool {
        totalItems > 0 && totalCost > 0 && sellingPrice > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            SIHeader(
                title: "Add Stock",
                subtitle: product.name,
                icon: "plus.square.fill.on.square.fill"
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    purchaseTypePicker
                    purchaseFields
                    sellingPriceField
                    summarySection
                    saveButton
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(SITheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Start from the current store price so the cashier
            // price does not change unless the user edits it.
            if sellingPriceText.isEmpty {
                let current = inventoryItem?.sellingPrice ?? product.sellingPrice
                sellingPriceText = String(format: "%.2f", current)
            }
        }
        .alert("Stock Added", isPresented: $showConfirmation) {
            Button("Done") {
                dismiss()
            }
        } message: {
            if let savedPurchase {
                Text("\(savedPurchase.totalItems) items were added to \(product.name). Purchase \(savedPurchase.formattedReference) was recorded.")
            }
        }
    }

    private var purchaseTypePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Purchase Type")
                .font(.headline)
                .fontWeight(.bold)

            Picker("Purchase Type", selection: $purchaseType) {
                ForEach(StockPurchase.PurchaseType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var purchaseFields: some View {
        VStack(alignment: .leading, spacing: 14) {
            if purchaseType == .individual {
                AddStockField(
                    title: "Quantity",
                    placeholder: "0",
                    text: $quantityText,
                    keyboard: .numberPad
                )

                AddStockField(
                    title: "Price per Item (₱)",
                    placeholder: "0.00",
                    text: $pricePerItemText,
                    keyboard: .decimalPad
                )
            } else {
                AddStockField(
                    title: "Number of Bundles",
                    placeholder: "0",
                    text: $bundlesText,
                    keyboard: .numberPad
                )

                AddStockField(
                    title: "Items per Bundle",
                    placeholder: "0",
                    text: $itemsPerBundleText,
                    keyboard: .numberPad
                )

                AddStockField(
                    title: "Bundle Price (₱)",
                    placeholder: "0.00",
                    text: $bundlePriceText,
                    keyboard: .decimalPad
                )
            }
        }
        .padding()
        .siCard()
    }

    private var sellingPriceField: some View {
        VStack(alignment: .leading, spacing: 14) {
            AddStockField(
                title: "Selling Price per Item (₱)",
                placeholder: "0.00",
                text: $sellingPriceText,
                keyboard: .decimalPad
            )
        }
        .padding()
        .siCard()
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .fontWeight(.bold)

            SummaryRow(
                title: "Total Items Added",
                value: "\(totalItems)"
            )

            if purchaseType == .bundle {
                SummaryRow(
                    title: "Cost per Item",
                    value: String(format: "₱%.2f", costPerItem)
                )
            }

            SummaryRow(
                title: "Total Purchase Cost",
                value: String(format: "₱%.2f", totalCost)
            )

            Divider()

            SummaryRow(
                title: "Expected Sales",
                value: String(format: "₱%.2f", expectedSales)
            )

            SummaryRow(
                title: "Expected Profit",
                value: String(format: "₱%.2f", expectedProfit),
                valueColor: expectedProfit >= 0 ? SITheme.green : .red
            )
        }
        .padding()
        .siCard()
    }

    private var saveButton: some View {
        Button {
            savePurchase()
        } label: {
            Label("Record Purchase", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? SITheme.green : Color(.systemGray4))
                .foregroundStyle(isValid ? .white : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .disabled(!isValid)
    }

    private func savePurchase() {
        let purchase: StockPurchase?

        switch purchaseType {
        case .individual:
            purchase = appController.inventoryController.addStock(
                product: product,
                purchaseType: .individual,
                numberOfBundles: 1,
                itemsPerBundle: quantity,
                unitPrice: pricePerItem,
                sellingPrice: sellingPrice
            )
        case .bundle:
            purchase = appController.inventoryController.addStock(
                product: product,
                purchaseType: .bundle,
                numberOfBundles: bundles,
                itemsPerBundle: itemsPerBundle,
                unitPrice: bundlePrice,
                sellingPrice: sellingPrice
            )
        }

        if let purchase {
            savedPurchase = purchase
            showConfirmation = true
        }
    }
}

struct AddStockField: View {

    let title: String
    let placeholder: String
    @Binding var text: String
    let keyboard: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(SITheme.softFill)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct SummaryRow: View {

    let title: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(valueColor)
        }
    }
}

#Preview {
    NavigationStack {
        AddStockView(
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
