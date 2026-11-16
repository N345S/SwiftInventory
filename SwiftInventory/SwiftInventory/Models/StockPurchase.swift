import Foundation

// A record of stock bought from a supplier. Each purchase is kept
// separately because the same product can be bought at different
// prices over time.
struct StockPurchase: Identifiable, Codable {

    enum PurchaseType: String, Codable, CaseIterable {
        case individual = "Individual"
        case bundle = "Bundle"
    }

    let id: UUID
    let referenceNumber: Int
    let productID: String
    let productName: String
    let productCategory: String
    let purchaseType: PurchaseType

    // Bundle details. For individual purchases these are 1 bundle
    // of `quantity` items so the math stays uniform.
    let numberOfBundles: Int
    let itemsPerBundle: Int

    // The price paid per unit: per item for individual purchases,
    // per bundle for bundle purchases.
    let unitPrice: Double

    // The selling price set for the product at purchase time.
    let sellingPrice: Double

    let date: Date

    var totalItems: Int {
        numberOfBundles * itemsPerBundle
    }

    var totalCost: Double {
        switch purchaseType {
        case .individual:
            return unitPrice * Double(totalItems)
        case .bundle:
            return unitPrice * Double(numberOfBundles)
        }
    }

    var costPerItem: Double {
        guard totalItems > 0 else {
            return 0
        }

        return totalCost / Double(totalItems)
    }

    var formattedReference: String {
        String(format: "P-%04d", referenceNumber)
    }
}
