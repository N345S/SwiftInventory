import SwiftUI

// The catalog lists products the store can carry. A catalog
// product only becomes an inventory item after its first stock
// purchase through Add Stock.
struct ProductCatalogView: View {

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
        VStack(spacing: 0) {
            SIHeader(
                title: "Product Catalog",
                subtitle: "Add catalog products to your store.",
                icon: "books.vertical.fill"
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    searchBar
                    categoryFilter
                    catalogList
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(SITheme.background)
        .navigationBarTitleDisplayMode(.inline)
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

    private var catalogList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Catalog Products")
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
                VStack(spacing: 12) {
                    ForEach(filteredProducts) { product in
                        CatalogProductCard(
                            product: product,
                            appController: appController
                        )
                    }
                }
            }
        }
    }
}

struct CatalogProductCard: View {

    let product: Product
    @ObservedObject var appController: AppController

    private var inventoryItem: InventoryItem? {
        appController.inventoryController.item(for: product)
    }

    private var isInInventory: Bool {
        inventoryItem != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ProductBadge(product: product, size: 50)

                VStack(alignment: .leading, spacing: 3) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    Text(product.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Suggested price ₱\(product.sellingPrice, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let inventoryItem {
                    VStack(alignment: .trailing, spacing: 6) {
                        StatusBadge(
                            title: "In Inventory",
                            icon: "checkmark.circle.fill",
                            color: SITheme.green
                        )

                        Text("\(inventoryItem.quantity) in stock")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    StatusBadge(
                        title: "Not in Store",
                        icon: "circle.dashed",
                        color: .gray
                    )
                }
            }

            NavigationLink {
                AddStockView(product: product)
                    .environmentObject(appController)
            } label: {
                Label(
                    isInInventory ? "Add More Stock" : "Add to Inventory",
                    systemImage: "plus.square.fill.on.square.fill"
                )
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(SITheme.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
        }
        .padding()
        .siCard()
    }
}

#Preview {
    NavigationStack {
        ProductCatalogView()
            .environmentObject(AppController())
    }
}
