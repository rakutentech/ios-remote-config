@testable import RRemoteConfig
@testable import RemoteConfigShared

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
            return mockAppName
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

    func osVersion() -> String {
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

class ConfigApiClientMock: ConfigApiClient {
    var fetchConfigCalledNumTimes = 0
    var fetchKeyCalledNumTimes = 0
    var fetchedConfig = Config(
        rawBody: "{}",
        body: ["": ""],
        signature: "",
        keyId: ""
    )
    var fetchedKey = ""

    override init(platformClient: Ktor_client_coreHttpClient = ConfigApiClientKt.createHttpClient(),
                  baseUrl: String = "https://www.example.com",
                  appId: String = "test_app_id",
                  subscriptionKey: String = "test_subscription_key",
                  deviceModel: String = "test_device_model",
                  osVersion: String = "test_os_version",
                  appName: String = "test_app_name",
                  appVersion: String = "test_app_version",
                  sdkVersion: String = "test_sdk_version") {
        super.init(
            platformClient: platformClient,
            baseUrl: baseUrl,
            appId: appId,
            subscriptionKey: subscriptionKey,
            deviceModel: deviceModel,
            osVersion: osVersion,
            appName: appName,
            appVersion: appVersion,
            sdkVersion: sdkVersion
        )
    }

    override func fetchConfig(success: @escaping (Config) -> Void, error: @escaping (KotlinException) -> Void) {
        fetchConfigCalledNumTimes += 1
        success(fetchedConfig)
    }

    override func fetchPublicKey(keyId: String, success: @escaping (String) -> Void, error: @escaping (KotlinException) -> Void) {
        fetchKeyCalledNumTimes += 1
        success(fetchedKey)
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

func createCacheMock(initialContents: Data? = #"{"body":{"":""},"keyId":"fooKey"}"#.data(using: .utf8)) -> CacheMock {
    return CacheMock(apiClient: ConfigApiClientMock(), poller: Poller(), initialCacheContents: initialContents)
}
