import SwiftUI

struct CashierView: View {
    
    @EnvironmentObject var appController: AppController
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    private var categories: [String] {
        let productCategories = appController.productController.products.map {
            $0.category
        }
        
        return ["All"] + Array(Set(productCategories)).sorted()
    }
    
    private var filteredProducts: [Product] {
        appController.productController.products.filter { product in
            let matchesSearch =
                searchText.isEmpty ||
                product.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory =
                selectedCategory == "All" ||
                product.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                SIHeader(
                    title: "New Sale",
                    subtitle: "Find products and build the current cart.",
                    icon: "cart.fill"
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        searchBar
                        categoryFilter
                        productsSection
                    }
                    .padding()
                    .padding(.bottom, appController.cart.isEmpty ? 20 : 180)
                }
            }
            
            if !appController.cart.isEmpty {
                cartSummary
            }
        }
        .background(SITheme.background)
        .navigationBarHidden(true)
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search products...", text: $searchText)
                .textInputAutocapitalization(.never)
            
            Image(systemName: "cart")
                .foregroundStyle(SITheme.navy)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .siCard()
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                selectedCategory == category
                                ? SITheme.blue
                                : SITheme.card
                            )
                            .foregroundStyle(
                                selectedCategory == category
                                ? .white
                                : .secondary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products")
                .font(.headline)
                .fontWeight(.bold)
            
            if filteredProducts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                    
                    Text("No products found")
                        .font(.headline)
                    
                    Text("Try a different search or category.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 38)
                .siCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredProducts) { product in
                        POSProductRow(
                            product: product,
                            appController: appController
                        )
                        
                        if product.id != filteredProducts.last?.id {
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
                .siCard()
            }
        }
    }
    
    private var cartSummary: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "list.bullet")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(appController.cartItemCount) items")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text("₱\(appController.cartTotal, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                NavigationLink(value: "checkout") {
                    Label("View Cart", systemImage: "arrow.right")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(SITheme.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            VStack(spacing: 6) {
                ForEach(appController.cart.prefix(3)) { item in
                    HStack {
                        Text(item.product.name)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("x\(item.quantity)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.72))
                        
                        Text("₱\(item.subtotal, specifier: "%.2f")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding()
        .background(SITheme.navy)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: SITheme.navy.opacity(0.28), radius: 16, y: 8)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

struct POSProductRow: View {
    
    let product: Product
    @ObservedObject var appController: AppController
    
    private var inventoryItem: InventoryItem? {
        appController.inventoryController.item(for: product)
    }

    private var currentStock: Int {
        inventoryItem?.quantity ?? 0
    }

    // Charge the store's actual inventory price, not the
    // catalog product's suggested price.
    private var sellingPrice: Double {
        inventoryItem?.sellingPrice ?? product.sellingPrice
    }
    
    private var cartQuantity: Int {
        appController.cart.first {
            $0.product.id == product.id
        }?.quantity ?? 0
    }
    
    private var canAddMore: Bool {
        cartQuantity < currentStock
    }
    
    private var isOutOfStock: Bool {
        currentStock <= 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ProductBadge(product: product, size: 52)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(product.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("₱\(sellingPrice, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(isOutOfStock ? .secondary : SITheme.green)
                
                Text(isOutOfStock ? "Out of stock" : "\(currentStock) in stock")
                    .font(.caption2)
                    .foregroundStyle(isOutOfStock ? .red : .secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    removeOne()
                } label: {
                    Image(systemName: "minus")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 28, height: 28)
                        .background(Color(.systemGray6))
                        .foregroundStyle(cartQuantity > 0 ? SITheme.navy : .secondary)
                        .clipShape(Circle())
                }
                .disabled(cartQuantity <= 0)
                
                Text("\(cartQuantity)")
                    .font(.headline)
                    .frame(width: 24)
                
                Button {
                    addOne()
                } label: {
                    Image(systemName: "plus")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 28, height: 28)
                        .background(canAddMore ? Color(.systemGray6) : Color(.systemGray5))
                        .foregroundStyle(canAddMore ? SITheme.navy : .secondary)
                        .clipShape(Circle())
                }
                .disabled(!canAddMore)
            }
        }
        .padding()
    }
    
    private func addOne() {
        guard canAddMore else {
            return
        }
        
        appController.addToCart(product: product)
    }
    
    private func removeOne() {
        guard cartQuantity > 0 else {
            return
        }
        
        appController.removeFromCart(product: product)
    }
}

#Preview {
    NavigationStack {
        CashierView()
            .environmentObject(AppController())
    }
}
