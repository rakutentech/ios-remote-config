internal class RealRemoteConfig {
    static let shared = RealRemoteConfig()
    var environment: Environment
    var poller: ConfigPoller
    var apiClient: APIClient
    var fetcher: ConfigFetcher
    var cache: ConfigCache

    init() {
        self.environment = Environment()
        self.poller = ConfigPoller()
        self.apiClient = APIClient()
        self.fetcher = ConfigFetcher(client: apiClient, environment: environment)
        self.cache = ConfigCache(fetcher: fetcher, poller: poller)
    }

    func getString(_ key: String, _ fallback: String) -> String {
        return cache.getString(key, fallback)
    }

    func refreshConfig() {
        cache.refreshFromRemote()
    }
}
