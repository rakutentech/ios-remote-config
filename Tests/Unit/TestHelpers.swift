@testable import RRemoteConfig

class BundleMock: EnvironmentSetupProtocol {
    var mockAppId: String?
    var mockAppName: String?
    var mockAppVersion: String?
    var mockEndpoint: String?
    var mockSubKey: String?
    var mockDeviceModel: String?
    var mockOsVersion: String?
    var mockSdkName: String?
    var mockSdkVersion: String?
    var mockNotFound: String?

    func value(for key: String) -> String? {
        switch key {
        case "RASApplicationIdentifier":
            return mockAppId
        case "RRCConfigAPIEndpoint":
            return mockEndpoint
        case "RASProjectSubscriptionKey":
            return mockSubKey
        case "CFBundleIdentifier":
            return mockAppId
        case "CFBundleDisplayName":
            return mockAppName
        case "CFBundleShortVersionString":
            return mockAppVersion
        default:
            return nil
        }
    }

    var valueNotFound: String {
        return mockNotFound ?? ""
    }

    func deviceModel() -> String {
        return mockDeviceModel ?? valueNotFound
    }

    func deviceOsVersion() -> String {
        return mockOsVersion ?? valueNotFound
    }

    func sdkName() -> String {
        return mockSdkName ?? valueNotFound
    }

    func sdkVersion() -> String {
        return mockSdkVersion ?? valueNotFound
    }
}

class CacheMock: ConfigCache {
    var refreshCalled = false

    override func refreshFromRemote() {
        self.refreshCalled = true
    }
}

class FetcherMock: Fetcher {
    var fetchConfigCalledNumTimes = 0
    var fetchKeyCalledNumTimes = 0
    var fetchedConfig = ConfigModel(config: ["": ""])
    var fetchedKey = KeyModel(id: "", key: "", createdAt: "")

    override func fetchConfig(completionHandler: @escaping (ConfigModel?) -> Void) {
        fetchConfigCalledNumTimes += 1
        completionHandler(fetchedConfig)
    }

    override func fetchKey(with keyId: String, completionHandler: @escaping (KeyModel?) -> Void) {
        fetchKeyCalledNumTimes += 1
        completionHandler(fetchedKey)
    }
}

class VerifierMock: Verifier {
    var verifyOK = true

    override func verify(signatureBase64: String, dictionary: [String: Any], keyBase64: String) -> Bool {
        return verifyOK
    }
}

class KeyStoreMock: KeyStore {
    var store: [String: String]?

    init(contents: [String: String]) {
        self.store = contents
    }

    override func key(for keyId: String) -> String? {
        return store?[keyId]
    }

    override func addKey(key: String, for keyId: String) {
        self.store?[keyId] = key
    }
}

func createCacheMock(initialContents: [String: String] = ["": ""]) -> CacheMock {
    return CacheMock(fetcher: Fetcher(client: APIClient(), environment: Environment()), poller: Poller(), initialCacheContents: initialContents)
}
