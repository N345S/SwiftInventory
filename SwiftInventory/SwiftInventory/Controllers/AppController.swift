import Foundation
import SwiftUI
internal import Combine

class AppController: ObservableObject {
    
    @Published var productController: ProductController
    @Published var inventoryController: InventoryController
    @Published var salesController: SalesController
    
    @Published var cart: [CartItem] = []
    
    @Published var selectedTab = 0
    
    @Published var cashierNavigationPath = NavigationPath()
    
    @Published var cashierSessionID = UUID()
    
    private var nextTransactionNumber: Int
    
    private let persistence = PersistenceController.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        
        let productController = ProductController()
        
        self.productController = productController
        
        self.inventoryController = InventoryController(
            products: productController.products
        )
        
        self.salesController = SalesController()
        
        // Load the next transaction number saved on the phone
        self.nextTransactionNumber =
            persistence.loadTransactionNumber()
        
        
        inventoryController.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        salesController.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        productController.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Cart
    
    func addToCart(product: Product) {
        
        if let index = cart.firstIndex(where: {
            $0.product.id == product.id
        }) {
            cart[index].quantity += 1
        } else {
            // Capture the store's actual inventory pricing so the
            // cart charges what the cashier displayed.
            let inventoryItem = inventoryController.item(for: product)

            let newItem = CartItem(
                product: product,
                quantity: 1,
                unitPrice: inventoryItem?.sellingPrice,
                unitCost: inventoryItem?.averageCost
            )

            cart.append(newItem)
        }
    }
    
    
    func removeFromCart(product: Product) {
        
        if let index = cart.firstIndex(where: {
            $0.product.id == product.id
        }) {
            
            if cart[index].quantity > 1 {
                cart[index].quantity -= 1
            } else {
                cart.remove(at: index)
            }
        }
    }
    
    
    func clearCart() {
        cart.removeAll()
    }
    
    
    var cartItemCount: Int {
        cart.reduce(0) {
            $0 + $1.quantity
        }
    }
    
    
    var cartTotal: Double {
        cart.reduce(0) {
            $0 + $1.subtotal
        }
    }
    
    
    var cartProfit: Double {
        cart.reduce(0) {
            $0 + $1.profit
        }
    }
    
    
    // MARK: - Sale Navigation
    
    func startNewSale() {
        clearCart()
        selectedTab = 1
        cashierNavigationPath = NavigationPath()
        cashierSessionID = UUID()
    }
    
    
    func exitToHome() {
        selectedTab = 0
        cashierNavigationPath = NavigationPath()
        cashierSessionID = UUID()
    }
    
    
    // MARK: - Transactions
    
    func createTransactionNumber() -> Int {
        
        let currentNumber = nextTransactionNumber
        
        nextTransactionNumber += 1
        
        // Save the next available number
        persistence.saveTransactionNumber(
            nextTransactionNumber
        )
        
        return currentNumber
    }
    
    
    func formattedTransactionNumber(_ number: Int) -> String {
        String(format: "#%04d", number)
    }
}
