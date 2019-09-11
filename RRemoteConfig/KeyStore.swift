internal class KeyStore {
    let service: String

    init(service: String = Bundle.main.bundleIdentifier!) {
        self.service = service
    }

    func key(for keyId: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: keyId,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let objectData = result as? Data else {
            return nil
        }

        let key = String(data: objectData, encoding: .utf8)
        Logger.v("Key id \(keyId) matched to key \(String(describing: key))")
        return key
    }

    func addKey(key: String, for keyId: String) {
        let queryFind: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: keyId
        ]

        guard let data = key.data(using: .utf8) else {
            return
        }

        let update: [String: Any] = [
            kSecValueData as String: data
        ]

        var status = SecItemUpdate(queryFind as CFDictionary, update as CFDictionary)

        if status == errSecItemNotFound {
            let queryAdd: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: keyId,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            status = SecItemAdd(queryAdd as CFDictionary, nil)
        }

        if status != errSecSuccess {
            var error: String?
            if #available(iOS 11.3, *) {
                error = SecCopyErrorMessageString(status, nil) as String?
            } else {
                error = "OSStatus \(status)"
            }
            Logger.e("addKey error \(String(describing: error))")
        }
    }
}
