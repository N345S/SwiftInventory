import Foundation

struct Product: Identifiable, Hashable, Codable {
    
    let id: String
    let name: String
    let category: String
    let costPrice: Double
    let sellingPrice: Double
    
    init(
        name: String,
        category: String,
        costPrice: Double,
        sellingPrice: Double
    ) {
        self.id = Product.createID(from: name)
        self.name = name
        self.category = category
        self.costPrice = costPrice
        self.sellingPrice = sellingPrice
    }
    
    private static func createID(from name: String) -> String {
        return name
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: ".", with: "")
    }
}
