@testable import RRemoteConfig

class CacheMock: ConfigCache {
    var refreshCalled = false

    override func refreshFromRemote() {
        self.refreshCalled = true
    }
}

func createCacheMock(initialContents: [String: String] = ["": ""]) -> CacheMock {
    return CacheMock(fetcher: ConfigFetcher(client: APIClient(), environment: Environment()), poller: Poller(), initialCacheContents: initialContents)
}
