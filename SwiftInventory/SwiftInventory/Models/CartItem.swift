import Foundation

struct CartItem: Identifiable, Hashable {
    let id = UUID()

    let product: Product
    var quantity: Int

    // Prices are captured from inventory when the item is added
    // to the cart, so the checkout always charges the same price
    // the cashier displayed.
    let unitPrice: Double
    let unitCost: Double

    init(
        product: Product,
        quantity: Int,
        unitPrice: Double? = nil,
        unitCost: Double? = nil
    ) {
        self.product = product
        self.quantity = quantity
        self.unitPrice = unitPrice ?? product.sellingPrice
        self.unitCost = unitCost ?? product.costPrice
    }

    var subtotal: Double {
        unitPrice * Double(quantity)
    }

    var profit: Double {
        (unitPrice - unitCost)
        * Double(quantity)
    }
}
