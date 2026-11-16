import Foundation

internal import Combine

class SalesController: ObservableObject {
    
    @Published var sales: [Sale] = []
    
    private let persistence = PersistenceController.shared
    
    
    init() {
        sales = persistence.loadSales() ?? []
    }
    
    
    func addSale(
        transactionNumber: Int,
        product: Product,
        quantity: Int,
        unitPrice: Double,
        unitCost: Double
    ) {

        let newSale = Sale(
            transactionNumber: transactionNumber,
            product: product,
            quantity: quantity,
            unitPrice: unitPrice,
            unitCost: unitCost,
            date: Date()
        )

        sales.append(newSale)

        // Save the updated sales history
        persistence.saveSales(sales)
    }
}
