import Foundation
import Security

// Stores the stock usage authorization PIN in the iOS Keychain.
//
// Keychain is used instead of UserDefaults because UserDefaults is
// stored as a readable plist, while Keychain entries are encrypted
// at rest by the system. If an older build ever saved a PIN in
// UserDefaults, it is migrated to the Keychain once and removed.
enum StockUsagePIN {

    private static let service = "com.swiftinventory.stock-usage"
    private static let account = "authorization-pin"

    // Key an older build would have used in UserDefaults.
    private static let legacyDefaultsKey = "stock_usage_pin"


    static var isConfigured: Bool {
        loadPIN() != nil
    }


    static func save(_ pin: String) {
        let data = Data(pin.utf8)

        // Remove any existing entry first so saving acts as an update.
        SecItemDelete(baseQuery() as CFDictionary)

        var attributes = baseQuery()
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        SecItemAdd(attributes as CFDictionary, nil)
    }


    static func verify(_ pin: String) -> Bool {
        guard let savedPIN = loadPIN() else {
            return false
        }

        return savedPIN == pin
    }


    private static func loadPIN() -> String? {
        migrateFromUserDefaultsIfNeeded()

        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }


    private static func migrateFromUserDefaultsIfNeeded() {
        guard let legacyPIN = UserDefaults.standard.string(
            forKey: legacyDefaultsKey
        ) else {
            return
        }

        var query = baseQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        // Only migrate when the Keychain has no PIN yet.
        if SecItemCopyMatching(query as CFDictionary, nil) == errSecItemNotFound {
            save(legacyPIN)
        }

        UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
    }


    private static func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
