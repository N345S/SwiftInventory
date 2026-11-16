import Foundation

class PersistenceController {
    
    static let shared = PersistenceController()
    
    private init() {}
    
    private let inventoryKey = "saved_inventory"
    private let salesKey = "saved_sales"
    private let transactionNumberKey = "transaction_number"
    private let purchasesKey = "saved_stock_purchases"
    private let usagesKey = "saved_stock_usages"
    private let purchaseNumberKey = "purchase_reference_number"
    private let usageNumberKey = "usage_reference_number"
    
    
    // MARK: - Inventory
    
    func saveInventory(_ inventory: [InventoryItem]) {
        if let data = try? JSONEncoder().encode(inventory) {
            UserDefaults.standard.set(data, forKey: inventoryKey)
        }
    }
    
    func loadInventory() -> [InventoryItem]? {
        guard let data = UserDefaults.standard.data(forKey: inventoryKey) else {
            return nil
        }
        
        return try? JSONDecoder().decode(
            [InventoryItem].self,
            from: data
        )
    }
    
    
    // MARK: - Sales
    
    func saveSales(_ sales: [Sale]) {
        if let data = try? JSONEncoder().encode(sales) {
            UserDefaults.standard.set(data, forKey: salesKey)
        }
    }
    
    func loadSales() -> [Sale]? {
        guard let data = UserDefaults.standard.data(forKey: salesKey) else {
            return nil
        }
        
        return try? JSONDecoder().decode(
            [Sale].self,
            from: data
        )
    }
    
    
    // MARK: - Stock Purchases

    func saveStockPurchases(_ purchases: [StockPurchase]) {
        if let data = try? JSONEncoder().encode(purchases) {
            UserDefaults.standard.set(data, forKey: purchasesKey)
        }
    }

    func loadStockPurchases() -> [StockPurchase]? {
        guard let data = UserDefaults.standard.data(forKey: purchasesKey) else {
            return nil
        }

        return try? JSONDecoder().decode(
            [StockPurchase].self,
            from: data
        )
    }


    // MARK: - Stock Usages

    func saveStockUsages(_ usages: [StockUsage]) {
        if let data = try? JSONEncoder().encode(usages) {
            UserDefaults.standard.set(data, forKey: usagesKey)
        }
    }

    func loadStockUsages() -> [StockUsage]? {
        guard let data = UserDefaults.standard.data(forKey: usagesKey) else {
            return nil
        }

        return try? JSONDecoder().decode(
            [StockUsage].self,
            from: data
        )
    }


    // MARK: - Reference Numbers

    func savePurchaseNumber(_ number: Int) {
        UserDefaults.standard.set(number, forKey: purchaseNumberKey)
    }

    func loadPurchaseNumber() -> Int {
        let number = UserDefaults.standard.integer(forKey: purchaseNumberKey)

        return number > 0 ? number : 1
    }

    func saveUsageNumber(_ number: Int) {
        UserDefaults.standard.set(number, forKey: usageNumberKey)
    }

    func loadUsageNumber() -> Int {
        let number = UserDefaults.standard.integer(forKey: usageNumberKey)

        return number > 0 ? number : 1
    }


    // MARK: - Transaction Number
    
    func saveTransactionNumber(_ number: Int) {
        UserDefaults.standard.set(
            number,
            forKey: transactionNumberKey
        )
    }
    
    func loadTransactionNumber() -> Int {
        let number = UserDefaults.standard.integer(
            forKey: transactionNumberKey
        )
        
        return number > 0 ? number : 1
    }
}
