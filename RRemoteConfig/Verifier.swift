internal class Verifier {
    func verify(signatureBase64: String,
                dictionary: [String: Any],
                keyBase64: String) -> Bool {
        guard let secKey = createSecKey(for: keyBase64),
            let signatureData = Data(base64Encoded: signatureBase64) else {
                return false
        }

        var objectData: Data = Data()
        do {
            objectData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        } catch {
            return false
        }

        var error: Unmanaged<CFError>?
        let verified = SecKeyVerifySignature(secKey,
                                             .ecdsaSignatureMessageX962SHA256,
                                             objectData as CFData,
                                             signatureData as CFData,
                                             &error)
        if error != nil {
            print(error as Any)
        }
        return verified
    }

    fileprivate func createSecKey(for base64String: String) -> SecKey? {
        let attributes: [String: Any] = [
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        guard let secKeyData = Data(base64Encoded: base64String) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(secKeyData as CFData, attributes as CFDictionary, &error) else {
            print(error as Any)
            return nil
        }
        print(secKey as Any)

        if !SecKeyIsAlgorithmSupported(secKey, .verify, .ecdsaSignatureMessageX962SHA256) {
            print("Key doesn't support algorithm ecdsaSignatureMessageX962SHA256")
            return nil
        }
        return secKey
    }
}
