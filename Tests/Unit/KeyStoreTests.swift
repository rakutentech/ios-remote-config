import Quick
import Nimble
@testable import RRemoteConfig

extension KeyStore {
    func delete(keyId: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "unit-tests",
            kSecAttrAccount as String: keyId,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
    }
}

class KeyStoreSpec: QuickSpec {
    override func spec() {
        // Keychain can't be mocked so the best we can do
        // to isolate the tests is to use a separate
        // keychain service
        let keyStore = KeyStore(service: "unit-tests")

        beforeEach {
            keyStore.delete(keyId: "key-id")
            keyStore.delete(keyId: "key-id-2")
        }

        it("can retrieve an added key") {
            keyStore.addKey(key: "a-key", for: "key-id")

            expect(keyStore.key(for: "key-id")).to(equal("a-key"))
        }

        it("returns nil when key not found") {
            keyStore.addKey(key: "a-key", for: "key-id-2")

            expect(keyStore.key(for: "key-id")).to(beNil())
        }
    }
}
