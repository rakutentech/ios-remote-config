internal class Verifier {
    func verify(signatureBase64: String,
                objectData: Data,
                keyBase64: String) -> Bool {
        guard let secKey = createSecKey(for: keyBase64),
            let signatureData = Data(base64Encoded: signatureBase64) else {
                return false
        }

        var error: Unmanaged<CFError>?
        let verified = SecKeyVerifySignature(secKey,
                                             .ecdsaSignatureMessageX962SHA256,
                                             objectData as CFData,
                                             signatureData as CFData,
                                             &error)
        if let err = error as? Error {
            Logger.e(err.localizedDescription)
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
            if let err = error as? Error {
                Logger.e(err.localizedDescription)
            }
            return nil
        }
        Logger.d("Key created: \(String(describing: secKey))")

        if !SecKeyIsAlgorithmSupported(secKey, .verify, .ecdsaSignatureMessageX962SHA256) {
            Logger.e("Key doesn't support algorithm ecdsaSignatureMessageX962SHA256")
            return nil
        }
        return secKey
    }
}
