import SwiftUI

struct CheckoutView: View {
    
    @EnvironmentObject var appController: AppController
    
    @State private var cashReceivedText = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var completedItems: [CartItem] = []
    @State private var completedTotal: Double = 0
    @State private var completedCash: Double = 0
    @State private var completedChange: Double = 0
    @State private var transactionNumber = 0
    @State private var saleCompleted = false
    @State private var showReceipt = false
    
    private var cashReceived: Double {
        Double(cashReceivedText) ?? 0
    }
    
    private var orderTotal: Double {
        appController.cartTotal
    }
    
    private var change: Double {
        cashReceived - orderTotal
    }
    
    private var displayedChange: Double {
        max(0, change)
    }
    
    private var isPaymentEnough: Bool {
        !appController.cart.isEmpty && cashReceived >= orderTotal
    }
    
    private var canCompleteSale: Bool {
        isPaymentEnough && !saleCompleted
    }
    
    private var showInsufficientCash: Bool {
        !cashReceivedText.isEmpty && cashReceived < orderTotal
    }
    
    private var insufficientCashMessage: String {
        String(format: "₱%.2f more needed.", orderTotal - cashReceived)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SIHeader(
                title: "Checkout",
                subtitle: "Review the cart and collect payment.",
                icon: "creditcard.fill"
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    orderSummarySection
                    paymentSection
                    completeSaleButton
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .background(SITheme.background)
        .navigationBarHidden(true)
        .alert("Unable to Complete Sale", isPresented: $showError) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $showReceipt) {
            SaleCompleteView(
                items: completedItems,
                total: completedTotal,
                cashReceived: completedCash,
                change: completedChange,
                transactionNumber: transactionNumber
            )
            .environmentObject(appController)
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order Summary")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("\(appController.cartItemCount) products")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "receipt.fill")
                    .font(.title3)
                    .foregroundStyle(SITheme.blue)
                    .frame(width: 40, height: 40)
                    .background(SITheme.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 11))
            }
            
            VStack(spacing: 12) {
                if appController.cart.isEmpty {
                    Text("Your cart is empty.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(appController.cart) { item in
                        CheckoutItemRow(item: item)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("₱\(orderTotal, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .siCard()
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Payment")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Enter the customer's cash payment")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                Text("₱")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(SITheme.navy)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cash Received")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("0.00", text: $cashReceivedText)
                        .keyboardType(.decimalPad)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(SITheme.softFill)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Change")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("₱\(displayedChange, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(isPaymentEnough ? SITheme.green : .secondary)
                }
                
                if showInsufficientCash {
                    Label(insufficientCashMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(isPaymentEnough ? SITheme.lightGreen : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding()
        .siCard()
    }
    
    private var completeSaleButton: some View {
        Button {
            completeSale()
        } label: {
            Label("Complete Sale", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canCompleteSale ? SITheme.green : Color(.systemGray4))
                .foregroundStyle(canCompleteSale ? .white : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .disabled(!canCompleteSale)
    }
    
    private func completeSale() {
        guard !saleCompleted else {
            return
        }
        
        guard !appController.cart.isEmpty else {
            errorMessage = "There are no products in the current order."
            showError = true
            return
        }
        
        guard cashReceived >= orderTotal else {
            errorMessage = "The cash received must be equal to or greater than the total amount."
            showError = true
            return
        }
        
        for item in appController.cart {
            let availableStock = appController.inventoryController.inventory.first {
                $0.product.id == item.product.id
            }?.quantity ?? 0
            
            if item.quantity > availableStock {
                errorMessage = "\(item.product.name) does not have enough stock."
                showError = true
                return
            }
        }
        
        transactionNumber = appController.createTransactionNumber()
        completedItems = appController.cart
        completedTotal = orderTotal
        completedCash = cashReceived
        completedChange = change
        
        for item in appController.cart {
            _ = appController.inventoryController.sellProduct(
                product: item.product,
                quantity: item.quantity
            )
        }
        
        for item in appController.cart {
            appController.salesController.addSale(
                transactionNumber: transactionNumber,
                product: item.product,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                unitCost: item.unitCost
            )
        }
        
        appController.clearCart()
        saleCompleted = true
        showReceipt = true
    }
}

struct CheckoutItemRow: View {
    
    let item: CartItem
    
    var body: some View {
        HStack(spacing: 12) {
            ProductBadge(product: item.product, size: 36)
            
            Text(item.product.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Spacer()
            
            Text("x \(item.quantity)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("₱\(item.subtotal, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject(AppController())
    }
}
