import Foundation

struct InventoryItem: Identifiable, Codable {

    var id: String {
        product.id
    }

    let product: Product
    var quantity: Int

    // The price this store actually charges, which can differ
    // from the catalog product's suggested selling price.
    var sellingPrice: Double

    // Weighted average cost per item across all stock purchases.
    // Updated whenever new stock is purchased at a different price.
    var averageCost: Double

    init(
        product: Product,
        quantity: Int,
        sellingPrice: Double? = nil,
        averageCost: Double? = nil
    ) {
        self.product = product
        self.quantity = quantity
        self.sellingPrice = sellingPrice ?? product.sellingPrice
        self.averageCost = averageCost ?? product.costPrice
    }

    // Older saved inventory was stored without sellingPrice and
    // averageCost, so fall back to the catalog product's prices
    // instead of failing to decode existing data.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        product = try container.decode(Product.self, forKey: .product)
        quantity = try container.decode(Int.self, forKey: .quantity)

        sellingPrice = try container.decodeIfPresent(
            Double.self,
            forKey: .sellingPrice
        ) ?? product.sellingPrice

        averageCost = try container.decodeIfPresent(
            Double.self,
            forKey: .averageCost
        ) ?? product.costPrice
    }
}
