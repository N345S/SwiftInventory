import SwiftUI

struct InventoryView: View {
    
    @EnvironmentObject var appController: AppController
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    private var categories: [String] {
        let productCategories = appController.productController.products.map {
            $0.category
        }
        
        return ["All"] + Array(Set(productCategories)).sorted()
    }
    
    private var filteredInventory: [InventoryItem] {
        appController.inventoryController.inventory.filter { item in
            let matchesSearch =
                searchText.isEmpty ||
                item.product.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory =
                selectedCategory == "All" ||
                item.product.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SIHeader(
                    title: "Inventory",
                    subtitle: "Search products and update stock.",
                    icon: "shippingbox.fill"
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        searchBar
                        categoryFilter
                        inventoryList
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            }
            .background(SITheme.background)
            .navigationBarHidden(true)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search products...", text: $searchText)
                .textInputAutocapitalization(.never)
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
    
    private var inventoryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products")
                .font(.headline)
                .fontWeight(.bold)
            
            if filteredInventory.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                    
                    Text("No inventory found")
                        .font(.headline)
                    
                    Text("Try a different search or category.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 38)
                .siCard()
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredInventory) { item in
                        InventoryCard(
                            item: item,
                            appController: appController
                        )
                    }
                }
            }
        }
    }
}

struct InventoryCard: View {

    let item: InventoryItem
    @ObservedObject var appController: AppController

    private var stockStatus: String {
        if item.quantity == 0 {
            return "Out of Stock"
        } else if item.quantity <= 5 {
            return "Low Stock"
        } else {
            return "In Stock"
        }
    }
    
    private var stockIcon: String {
        if item.quantity == 0 {
            return "xmark.circle.fill"
        } else if item.quantity <= 5 {
            return "exclamationmark.triangle.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var stockColor: Color {
        if item.quantity == 0 {
            return .red
        } else if item.quantity <= 5 {
            return SITheme.orange
        } else {
            return SITheme.green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ProductBadge(product: item.product, size: 50)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.product.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text(item.product.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("Stock: \(item.quantity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 7) {
                    Text("₱\(item.sellingPrice, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    StatusBadge(
                        title: stockStatus,
                        icon: stockIcon,
                        color: stockColor
                    )
                }
            }
            
            Divider()

            HStack(spacing: 12) {
                NavigationLink {
                    AddStockView(product: item.product)
                        .environmentObject(appController)
                } label: {
                    Label("Add Stock", systemImage: "plus.square.fill.on.square.fill")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(SITheme.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }

                NavigationLink {
                    StockUsageView(product: item.product)
                        .environmentObject(appController)
                } label: {
                    Label("Record Usage", systemImage: "minus.square.fill")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(SITheme.navy)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
                .disabled(item.quantity == 0)
                .opacity(item.quantity == 0 ? 0.45 : 1)
            }
        }
        .padding()
        .siCard()
    }
}

#Preview {
    InventoryView()
        .environmentObject(AppController())
}
