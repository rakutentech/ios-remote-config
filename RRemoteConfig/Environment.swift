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
    var url: URL? {
        guard let appId = bundle.value(for: "RASApplicationIdentifier"), let endpointUrlString = bundle.value(for: "RRCConfigAPIEndpoint") else {
            print("Ensure RASApplicationIdentifier and RRCConfigAPIEndpoint values in plist are valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)/\(appId)/config")
    }
    var subscriptionKey: String {
        return bundle.value(for: "RASProjectSubscriptionKey") ?? ""
    }

    init(bundle: EnvironmentSetupProtocol = Bundle.main) {
        self.bundle = bundle
    }
}
