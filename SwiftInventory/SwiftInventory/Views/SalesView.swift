import SwiftUI

struct SalesView: View {
    
    @EnvironmentObject var salesController: SalesController
    
    var totalRevenue: Double {
        salesController.sales.reduce(0) {
            $0 + $1.totalAmount
        }
    }
    
    var totalProfit: Double {
        salesController.sales.reduce(0) {
            $0 + $1.totalProfit
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        SalesSummaryCard(
                            title: "Revenue",
                            value: totalRevenue,
                            icon: "banknote.fill",
                            color: .blue
                        )
                        
                        SalesSummaryCard(
                            title: "Profit",
                            value: totalProfit,
                            icon: "chart.line.uptrend.xyaxis",
                            color: .green
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sales History")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if salesController.sales.isEmpty {
                            emptyState
                        } else {
                            ForEach(salesController.sales.reversed()) { sale in
                                SaleRow(sale: sale)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sales")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            
            Text("No sales recorded yet")
                .font(.headline)
            
            Text("Completed checkout sales will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct SalesSummaryCard: View {
    
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("₱\(value, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct SaleRow: View {
    
    let sale: Sale
    
    private var transactionText: String {
        String(format: "Transaction #%04d", sale.transactionNumber)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "cart.fill")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 42, height: 42)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(transactionText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(sale.product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("Quantity: \(sale.quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(sale.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("₱\(sale.totalAmount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("+₱\(sale.totalProfit, specifier: "%.2f") profit")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

#Preview {
    SalesView()
        .environmentObject(SalesController())
}
