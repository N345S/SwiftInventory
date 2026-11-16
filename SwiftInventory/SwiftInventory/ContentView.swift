import SwiftUI

struct ContentView: View {
    
    @StateObject private var appController = AppController()
    
    var body: some View {
        TabView(selection: $appController.selectedTab) {
            
            // MARK: - Home
            
            HomeView()
                .environmentObject(appController)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            
            // MARK: - Cashier
            
            NavigationStack(path: $appController.cashierNavigationPath) {
                CashierView()
                    .environmentObject(appController)
                    .id(appController.cashierSessionID)
                    .navigationDestination(for: String.self) { destination in
                        if destination == "checkout" {
                            CheckoutView()
                                .environmentObject(appController)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "cart")
                Text("Cashier")
            }
            .tag(1)
            
            
            // MARK: - Inventory
            
            InventoryView()
                .environmentObject(appController)
                .tabItem {
                    Image(systemName: "shippingbox")
                    Text("Inventory")
                }
                .tag(2)
            
            
            // MARK: - Sales
            
            SalesView()
                .environmentObject(appController.salesController)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Sales")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
