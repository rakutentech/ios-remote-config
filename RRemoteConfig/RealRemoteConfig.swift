internal class RealRemoteConfig {
    static let shared = RealRemoteConfig()
    var environment: Environment
    var poller: Poller
    var apiClient: APIClient
    var fetcher: ConfigFetcher
    var cache: ConfigCache

    init() {
        self.environment = Environment()
        self.poller = Poller()
        self.apiClient = APIClient()
        self.fetcher = ConfigFetcher(client: apiClient, environment: environment)
        self.cache = ConfigCache(fetcher: fetcher, poller: poller)
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
