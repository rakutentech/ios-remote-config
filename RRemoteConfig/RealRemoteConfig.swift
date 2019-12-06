import RemoteConfigShared

internal class RealRemoteConfig {
    static let shared = RealRemoteConfig()
    var environment: Environment
    var poller: Poller
    var apiClient: APIClient
    var fetcher: Fetcher
    var fetcher2: ConfigFetcher
    var cache: ConfigCache

    init() {
        self.environment = Environment()
        self.poller = Poller()
        self.apiClient = APIClient()
        self.fetcher = Fetcher(client: apiClient, environment: environment)
        self.fetcher2 = ConfigFetcher(baseUrl: self.environment.baseUrl!.absoluteString, appId: self.environment.appId, subscriptionKey: self.environment.subscriptionKey)
        self.cache = ConfigCache(fetcher: fetcher, fetcher2: fetcher2, poller: poller)
    }

    func getString(_ key: String, _ fallback: String) -> String {
        return cache.getString(key, fallback)
    }

    func getBoolean(_ key: String, _ fallback: Bool) -> Bool {
        return cache.getBoolean(key, fallback)
    }

    func getNumber(_ key: String, _ fallback: NSNumber) -> NSNumber {
        return cache.getNumber(key, fallback)
    }

    func getConfig() -> [String: String] {
        return cache.getConfig()
    }

    func refreshConfig() {
        cache.refreshFromRemote()
    }
}
