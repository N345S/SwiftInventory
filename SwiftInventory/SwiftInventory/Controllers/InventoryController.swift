import Foundation

internal import Combine

class InventoryController: ObservableObject {

    @Published var inventory: [InventoryItem] = []
    @Published var purchases: [StockPurchase] = []
    @Published var usages: [StockUsage] = []

    private var nextPurchaseNumber: Int
    private var nextUsageNumber: Int

    private let persistence = PersistenceController.shared


    init(products: [Product]) {

        nextPurchaseNumber = persistence.loadPurchaseNumber()
        nextUsageNumber = persistence.loadUsageNumber()

        purchases = persistence.loadStockPurchases() ?? []
        usages = persistence.loadStockUsages() ?? []

        if let savedInventory = persistence.loadInventory() {
            inventory = savedInventory
        } else {
            loadSampleInventory(products: products)
            persistence.saveInventory(inventory)
        }
    }
    
    
    private func loadSampleInventory(products: [Product]) {
        inventory = [
            InventoryItem(product: products[0], quantity: 25),
            InventoryItem(product: products[1], quantity: 18),
            InventoryItem(product: products[2], quantity: 30),
            InventoryItem(product: products[3], quantity: 12),
            InventoryItem(product: products[4], quantity: 20)
        ]
    }
    
    
    func item(for product: Product) -> InventoryItem? {
        inventory.first {
            $0.product.id == product.id
        }
    }


    func sellProduct(product: Product, quantity: Int) -> Bool {
        
        guard quantity > 0 else {
            return false
        }
        
        guard let index = inventory.firstIndex(where: {
            $0.product.id == product.id
        }) else {
            return false
        }
        
        guard inventory[index].quantity >= quantity else {
            return false
        }
        
        inventory[index].quantity -= quantity
        
        // Save the updated inventory
        persistence.saveInventory(inventory)
        
        return true
    }
    
    
    func updateStock(product: Product, quantity: Int) {

        guard let index = inventory.firstIndex(where: {
            $0.product.id == product.id
        }) else {
            return
        }

        inventory[index].quantity = max(0, quantity)

        // Save the updated inventory
        persistence.saveInventory(inventory)
    }


    // MARK: - Stock Purchases

    // Records a supplier purchase and adds the items to inventory.
    // The item's average cost is recalculated as a weighted average
    // so profit stays accurate across purchases at different prices.
    @discardableResult
    func addStock(
        product: Product,
        purchaseType: StockPurchase.PurchaseType,
        numberOfBundles: Int,
        itemsPerBundle: Int,
        unitPrice: Double,
        sellingPrice: Double
    ) -> StockPurchase? {

        let purchase = StockPurchase(
            id: UUID(),
            referenceNumber: nextPurchaseNumber,
            productID: product.id,
            productName: product.name,
            productCategory: product.category,
            purchaseType: purchaseType,
            numberOfBundles: numberOfBundles,
            itemsPerBundle: itemsPerBundle,
            unitPrice: unitPrice,
            sellingPrice: sellingPrice,
            date: Date()
        )

        guard purchase.totalItems > 0, purchase.totalCost >= 0 else {
            return nil
        }

        nextPurchaseNumber += 1
        persistence.savePurchaseNumber(nextPurchaseNumber)

        if let index = inventory.firstIndex(where: {
            $0.product.id == product.id
        }) {
            let oldQuantity = Double(inventory[index].quantity)
            let addedQuantity = Double(purchase.totalItems)

            // Weighted average cost across the old stock and the
            // newly purchased stock.
            let totalCostBasis =
                oldQuantity * inventory[index].averageCost
                + addedQuantity * purchase.costPerItem

            inventory[index].averageCost =
                totalCostBasis / (oldQuantity + addedQuantity)

            inventory[index].quantity += purchase.totalItems
            inventory[index].sellingPrice = sellingPrice
        } else {
            // First purchase of a catalog product brings it into
            // the store's inventory.
            let newItem = InventoryItem(
                product: product,
                quantity: purchase.totalItems,
                sellingPrice: sellingPrice,
                averageCost: purchase.costPerItem
            )

            inventory.append(newItem)
        }

        purchases.append(purchase)

        persistence.saveInventory(inventory)
        persistence.saveStockPurchases(purchases)

        return purchase
    }


    // MARK: - Stock Usage

    // Records a non-sale stock deduction (personal use, damage,
    // expiry, etc.). Never creates a sale or revenue.
    @discardableResult
    func recordUsage(
        product: Product,
        quantity: Int,
        reason: StockUsage.Reason,
        notes: String
    ) -> StockUsage? {

        guard quantity > 0 else {
            return nil
        }

        guard let index = inventory.firstIndex(where: {
            $0.product.id == product.id
        }) else {
            return nil
        }

        guard inventory[index].quantity >= quantity else {
            return nil
        }

        inventory[index].quantity -= quantity

        let usage = StockUsage(
            id: UUID(),
            referenceNumber: nextUsageNumber,
            productID: product.id,
            productName: product.name,
            productCategory: product.category,
            quantity: quantity,
            reason: reason,
            notes: notes,
            remainingStock: inventory[index].quantity,
            date: Date()
        )

        nextUsageNumber += 1
        persistence.saveUsageNumber(nextUsageNumber)

        usages.append(usage)

        persistence.saveInventory(inventory)
        persistence.saveStockUsages(usages)

        return usage
    }
}
