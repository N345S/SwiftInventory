import Foundation
internal import Combine

class ProductController: ObservableObject {
    
    @Published var products: [Product] = [
        Product(
            name: "Coca-Cola 1.5L",
            category: "Drinks",
            costPrice: 45.00,
            sellingPrice: 60.00
        ),
        Product(
            name: "Sprite 1.5L",
            category: "Drinks",
            costPrice: 40.00,
            sellingPrice: 55.00
        ),
        Product(
            name: "Piattos",
            category: "Snacks",
            costPrice: 20.00,
            sellingPrice: 28.00
        ),
        Product(
            name: "Nova",
            category: "Snacks",
            costPrice: 18.00,
            sellingPrice: 25.00
        ),
        Product(
            name: "Lucky Me Pancit Canton",
            category: "Food",
            costPrice: 13.00,
            sellingPrice: 18.00
        ),
        Product(
            name: "Chippy",
            category: "Snacks",
            costPrice: 16.00,
            sellingPrice: 22.00
        ),
        Product(
            name: "Boy Bawang",
            category: "Snacks",
            costPrice: 14.00,
            sellingPrice: 20.00
        ),
        Product(
            name: "C2 Apple 500ml",
            category: "Drinks",
            costPrice: 22.00,
            sellingPrice: 30.00
        ),
        Product(
            name: "Fita",
            category: "Snacks",
            costPrice: 15.00,
            sellingPrice: 20.00
        ),
        Product(
            name: "Lucky Me Beef Mami",
            category: "Food",
            costPrice: 12.00,
            sellingPrice: 17.00
        )
    ]
}
