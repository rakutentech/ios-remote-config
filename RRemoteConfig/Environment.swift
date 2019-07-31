internal protocol EnvironmentSetupProtocol {
    func value(for key: String) -> String?
}

extension Bundle: EnvironmentSetupProtocol {
    func value(for key: String) -> String? {
        return self.object(forInfoDictionaryKey: key) as? String
    }
}

internal class Environment {
    let bundle: EnvironmentSetupProtocol
    private var baseUrl: URL? {
        guard let endpointUrlString = bundle.value(for: "RRCConfigAPIEndpoint") else {
            print("Ensure RRCConfigAPIEndpoint value in plist is valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }
    var configUrl: URL? {
        guard let appId = bundle.value(for: "RASApplicationIdentifier") else {
            print("Ensure RASApplicationIdentifier value in plist is valid")
            return nil
        }
        return baseUrl?.appendingPathComponent("/app/\(appId)/config")
    }
    var subscriptionKey: String {
        return bundle.value(for: "RASProjectSubscriptionKey") ?? ""
    }

    init(bundle: EnvironmentSetupProtocol = Bundle.main) {
        self.bundle = bundle
    }

    func keyUrl(with keyId: String) -> URL? {
        return baseUrl?.appendingPathComponent("/keys/\(keyId)")
    }
}
