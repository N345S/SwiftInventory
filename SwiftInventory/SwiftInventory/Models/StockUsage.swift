import Foundation

// A record of stock removed for reasons other than a customer
// sale. These never create revenue or sales transactions.
struct StockUsage: Identifiable, Codable {

    enum Reason: String, Codable, CaseIterable {
        case personalUse = "Personal Use"
        case familyEvent = "Family / Event"
        case damaged = "Damaged"
        case expired = "Expired"
        case lost = "Lost"
        case other = "Other"

        var icon: String {
            switch self {
            case .personalUse:
                return "person.fill"
            case .familyEvent:
                return "person.3.fill"
            case .damaged:
                return "exclamationmark.triangle.fill"
            case .expired:
                return "calendar.badge.exclamationmark"
            case .lost:
                return "questionmark.circle.fill"
            case .other:
                return "ellipsis.circle.fill"
            }
        }
    }

    let id: UUID
    let referenceNumber: Int
    let productID: String
    let productName: String
    let productCategory: String
    let quantity: Int
    let reason: Reason
    let notes: String
    let remainingStock: Int
    let date: Date

    var formattedReference: String {
        String(format: "U-%04d", referenceNumber)
    }
}
