import Foundation

struct Sale: Identifiable, Codable {

    let id: UUID
    let transactionNumber: Int
    let product: Product
    let quantity: Int

    // Snapshots of the price and cost at the moment of sale,
    // so past sales never change when prices change later.
    let unitPrice: Double
    let unitCost: Double

    let totalAmount: Double
    let totalProfit: Double
    let date: Date

    init(
        transactionNumber: Int,
        product: Product,
        quantity: Int,
        unitPrice: Double,
        unitCost: Double,
        date: Date
    ) {
        self.id = UUID()
        self.transactionNumber = transactionNumber
        self.product = product
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.unitCost = unitCost
        self.totalAmount = unitPrice * Double(quantity)
        self.totalProfit = (unitPrice - unitCost) * Double(quantity)
        self.date = date
    }

    // Older saved sales only stored the totals, so derive the
    // per-unit snapshots from them instead of failing to decode.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        transactionNumber = try container.decode(Int.self, forKey: .transactionNumber)
        product = try container.decode(Product.self, forKey: .product)
        quantity = try container.decode(Int.self, forKey: .quantity)
        totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        totalProfit = try container.decode(Double.self, forKey: .totalProfit)
        date = try container.decode(Date.self, forKey: .date)

        let safeQuantity = Double(max(1, quantity))

        unitPrice = try container.decodeIfPresent(
            Double.self,
            forKey: .unitPrice
        ) ?? totalAmount / safeQuantity

        unitCost = try container.decodeIfPresent(
            Double.self,
            forKey: .unitCost
        ) ?? (totalAmount - totalProfit) / safeQuantity
    }
}
