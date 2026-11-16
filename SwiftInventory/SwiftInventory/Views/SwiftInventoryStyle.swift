import SwiftUI

enum SITheme {
    static let navy = Color(red: 0.03, green: 0.14, blue: 0.25)
    static let deepNavy = Color(red: 0.02, green: 0.10, blue: 0.18)
    static let green = Color(red: 0.02, green: 0.62, blue: 0.36)
    static let lightGreen = Color(red: 0.88, green: 0.97, blue: 0.92)
    static let blue = Color(red: 0.02, green: 0.42, blue: 0.88)
    static let purple = Color(red: 0.45, green: 0.25, blue: 0.90)
    static let orange = Color.orange
    static let background = Color(.systemGroupedBackground)
    static let card = Color(.systemBackground)
    static let border = Color(.systemGray5)
    static let softFill = Color(.secondarySystemGroupedBackground)
    static let cornerRadius: CGFloat = 16
}

struct SIHeader: View {
    
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 18)
        .padding(.bottom, 24)
        .background(SITheme.navy)
    }
}

struct SICardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SITheme.card)
            .clipShape(RoundedRectangle(cornerRadius: SITheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: SITheme.cornerRadius)
                    .stroke(SITheme.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
    }
}

extension View {
    func siCard() -> some View {
        modifier(SICardModifier())
    }
}

struct ProductBadge: View {
    
    let product: Product
    var size: CGFloat = 48
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(badgeColor.opacity(0.15))
            
            Image(systemName: badgeIcon)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(badgeColor)
        }
        .frame(width: size, height: size)
    }
    
    private var badgeIcon: String {
        if product.category == "Drinks" {
            return "drop.fill"
        } else if product.category == "Snacks" {
            return "bag.fill"
        } else {
            return "fork.knife"
        }
    }
    
    private var badgeColor: Color {
        if product.category == "Drinks" {
            return SITheme.green
        } else if product.category == "Snacks" {
            return SITheme.orange
        } else {
            return SITheme.blue
        }
    }
}

struct StatusBadge: View {
    
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
