import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appController: AppController
    
    private var totalProducts: Int {
        appController.productController.products.count
    }
    
    private var totalStock: Int {
        appController.inventoryController.inventory.reduce(0) {
            $0 + $1.quantity
        }
    }
    
    // Only count sales recorded today so the card matches its title.
    private var todaysSales: [Sale] {
        appController.salesController.sales.filter {
            Calendar.current.isDateInToday($0.date)
        }
    }

    private var totalSales: Double {
        todaysSales.reduce(0) {
            $0 + $1.totalAmount
        }
    }

    private var totalProfit: Double {
        todaysSales.reduce(0) {
            $0 + $1.totalProfit
        }
    }
    
    private var recentSales: [Sale] {
        Array(appController.salesController.sales.reversed().prefix(3))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    topHeader
                    contentArea
                }
            }
            .background(SITheme.background)
            .navigationBarHidden(true)
        }
    }
    
    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label("SwiftInventory", systemImage: "shippingbox.fill")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "bell.badge.fill")
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Good afternoon,")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                
                Text("Welcome back!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal)
        .padding(.top, 18)
        .padding(.bottom, 46)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SITheme.navy)
    }
    
    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 18) {
            salesCard
                .padding(.top, -34)
            
            quickActions
            
            HStack(spacing: 12) {
                HomeMetricCard(
                    title: "Products",
                    value: "\(totalProducts)",
                    icon: "shippingbox.fill",
                    color: SITheme.blue
                )
                
                HomeMetricCard(
                    title: "Stock Items",
                    value: "\(totalStock)",
                    icon: "cube.box.fill",
                    color: SITheme.orange
                )
            }
            
            recentActivity
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
    
    private var salesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Sales")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label("Live", systemImage: "arrow.up.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(SITheme.green)
            }
            
            Text("₱\(totalSales, specifier: "%.2f")")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(SITheme.green)
            
            Text("Profit ₱\(totalProfit, specifier: "%.2f")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .siCard()
    }
    
    private var quickActions: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            Button {
                appController.startNewSale()
            } label: {
                HomeActionTile(
                    title: "New Sale",
                    subtitle: "Start a new transaction",
                    icon: "cart.fill",
                    color: SITheme.blue
                )
            }
            .buttonStyle(.plain)
            
            Button {
                appController.selectedTab = 2
            } label: {
                HomeActionTile(
                    title: "Inventory",
                    subtitle: "Manage stock and products",
                    icon: "shippingbox.fill",
                    color: SITheme.green
                )
            }
            .buttonStyle(.plain)
            
            Button {
                appController.selectedTab = 3
            } label: {
                HomeActionTile(
                    title: "Sales",
                    subtitle: "View sales history",
                    icon: "chart.bar.fill",
                    color: SITheme.purple
                )
            }
            .buttonStyle(.plain)
            
            HomeActionTile(
                title: "Reports",
                subtitle: "Coming soon",
                icon: "doc.text.fill",
                color: .gray,
                isDisabled: true
            )
        }
    }
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("View All") {
                    appController.selectedTab = 3
                }
                .font(.caption)
                .fontWeight(.semibold)
            }
            
            VStack(spacing: 0) {
                if recentSales.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        
                        Text("No recent sales yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    ForEach(recentSales) { sale in
                        RecentSaleRow(
                            sale: sale,
                            transactionText: appController.formattedTransactionNumber(sale.transactionNumber)
                        )
                        
                        if sale.id != recentSales.last?.id {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
            }
            .siCard()
        }
    }
}

struct HomeActionTile: View {
    
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isDisabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
            
            Spacer(minLength: 4)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding()
        .background(isDisabled ? Color(.systemGray4) : color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HomeMetricCard: View {
    
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .siCard()
    }
}

struct RecentSaleRow: View {
    
    let sale: Sale
    let transactionText: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "receipt.fill")
                .font(.subheadline)
                .foregroundStyle(SITheme.green)
                .frame(width: 34, height: 34)
                .background(SITheme.lightGreen)
                .clipShape(RoundedRectangle(cornerRadius: 9))
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Sale \(transactionText)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text("\(sale.product.name) x\(sale.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("₱\(sale.totalAmount, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(SITheme.green)
        }
        .padding()
    }
}

#Preview {
    HomeView()
        .environmentObject(AppController())
}
