@testable import RRemoteConfig

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
