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
    var fetchedConfig = ConfigModel(data: (try? JSONSerialization.data(withJSONObject: ["": ""], options: []))!)
    var fetchedKey = KeyModel(data: (try? JSONSerialization.data(withJSONObject: ["id": "", "key": "", "createdAt": ""], options: []))!)

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

    override func verify(signatureBase64: String, objectData: Data, keyBase64: String) -> Bool {
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

class APIClientMock: APIClient {
    var dictionary: [String: Any]?
    var headers: [String: String]?
    var error: Error?
    var request: URLRequest?

    override func send<T>(request: URLRequest, parser: T.Type, completionHandler: @escaping (Result<Response, Error>) -> Void) where T: Parsable {
        self.request = request

        guard let dictionary = dictionary else {
            return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
        }
        if let httpResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1.1", headerFields: headers),
            let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
            let config = ConfigModel(data: jsonData) {
            return completionHandler(.success(Response(config, jsonData, httpResponse)))
        }
    }
}

func createCacheMock(initialContents: [String: Any] = ["body": ["": ""]]) -> CacheMock {
    return CacheMock(fetcher: Fetcher(client: APIClient(), environment: Environment()), poller: Poller(), initialCacheContents: initialContents)
}
