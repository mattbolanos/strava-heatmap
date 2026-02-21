import Foundation
import Security

public actor TokenManager {
    public static let shared = TokenManager()

    private let service = "com.mattbolanos.strava-heatmap.tokens"
    private let account = "strava"

    public init() {}

    public func loadToken() -> StravaToken? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]

        query[kSecAttrAccessGroup as String] = resolvedAccessGroup

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(StravaToken.self, from: data)
    }

    public func saveToken(_ token: StravaToken) throws {
        let data = try JSONEncoder().encode(token)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]
        query[kSecAttrAccessGroup as String] = resolvedAccessGroup

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw TokenManagerError.keychainOperationFailed(updateStatus)
        }

        var addQuery = query
        addQuery.merge(attributes) { _, new in new }

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw TokenManagerError.keychainOperationFailed(addStatus)
        }
    }

    public func clearToken() {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]
        query[kSecAttrAccessGroup as String] = resolvedAccessGroup
        SecItemDelete(query as CFDictionary)
    }

    public func hasRefreshToken() -> Bool {
        guard let token = loadToken() else { return false }
        return !token.refreshToken.isEmpty
    }

    private var resolvedAccessGroup: String? {
        let prefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as? String
        if let prefix {
            return "\(prefix)com.mattbolanos.strava-heatmap"
        }
        return nil
    }
}

public enum TokenManagerError: Error {
    case keychainOperationFailed(OSStatus)
}
