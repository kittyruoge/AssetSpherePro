//
//  ASPKeychainManager.swift
//  AssetSpherePro
//
//  Thin wrapper over the iOS Keychain Services API for securely storing the
//  account password. All data stays on-device; nothing is transmitted.
//

import Foundation
import Security

final class ASPKeychainManager {

    static let shared = ASPKeychainManager()

    private init() {}

    private let service = "com.AssetSpherePro.credentials"

    /// Stores (or updates) a password for the given account key (the email).
    @discardableResult
    func asp_savePassword(_ password: String, account: String) -> Bool {
        guard let data = password.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        // Remove any existing item first so we always perform a clean insert.
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Reads the stored password for an account key, if present.
    func asp_readPassword(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        return password
    }

    /// Verifies a candidate password against the stored value.
    func asp_verifyPassword(_ candidate: String, account: String) -> Bool {
        guard let stored = asp_readPassword(account: account) else { return false }
        return stored == candidate
    }

    /// Deletes the stored password for an account key.
    @discardableResult
    func asp_deletePassword(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
