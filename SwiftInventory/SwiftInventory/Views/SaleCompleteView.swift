import SwiftUI

struct SaleCompleteView: View {
    
    let items: [CartItem]
    let total: Double
    let cashReceived: Double
    let change: Double
    let transactionNumber: Int
    
    @EnvironmentObject var appController: AppController
    
    private var transactionText: String {
        "Transaction \(appController.formattedTransactionNumber(transactionNumber))"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            successHeader
            receiptArea
        }
        .background(SITheme.background)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private var successHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 92, height: 92)
                .background(SITheme.green)
                .clipShape(Circle())
                .shadow(color: SITheme.green.opacity(0.35), radius: 14, y: 8)
            
            Text("Sale Completed")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(transactionText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 42)
        .padding(.bottom, 34)
        .background(SITheme.deepNavy)
    }
    
    private var receiptArea: some View {
        ScrollView {
            VStack(spacing: 18) {
                receiptCard
                actionButtons
            }
            .padding()
            .padding(.top, -10)
        }
    }
    
    private var receiptCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Items")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(items) { item in
                ReceiptItemRow(item: item)
            }
            
            Divider()
            
            ReceiptAmountRow(
                title: "Total",
                amount: total,
                isBold: true
            )
            
            Divider()
            
            ReceiptAmountRow(
                title: "Cash Received",
                amount: cashReceived
            )
            
            ReceiptAmountRow(
                title: "Change",
                amount: change,
                color: SITheme.green,
                isBold: true
            )
        }
        .padding()
        .siCard()
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                appController.startNewSale()
            } label: {
                Label("Start New Sale", systemImage: "cart.fill")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(SITheme.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            Button {
                appController.exitToHome()
            } label: {
                Label("Exit", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundStyle(SITheme.navy)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}

struct ReceiptItemRow: View {
    
    let item: CartItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(item.product.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("x \(item.quantity)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("₱\(item.subtotal, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}

struct ReceiptAmountRow: View {
    
    let title: String
    let amount: Double
    var color: Color = .primary
    var isBold = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(isBold ? .headline : .subheadline)
                .fontWeight(isBold ? .bold : .regular)
            
            Spacer()
            
            Text("₱\(amount, specifier: "%.2f")")
                .font(isBold ? .headline : .subheadline)
                .fontWeight(isBold ? .bold : .regular)
                .foregroundStyle(color)
        }
    }
}

#Preview {
    NavigationStack {
        SaleCompleteView(
            items: [
                CartItem(
                    product: Product(
                        name: "Coca-Cola 1.5L",
                        category: "Drinks",
                        costPrice: 45,
                        sellingPrice: 60
                    ),
                    quantity: 2
                )
            ],
            total: 120,
            cashReceived: 500,
            change: 380,
            transactionNumber: 1
        )
        .environmentObject(AppController())
    }
}
