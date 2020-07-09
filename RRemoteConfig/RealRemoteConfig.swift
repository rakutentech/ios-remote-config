internal class RealRemoteConfig {
    static let shared = RealRemoteConfig()
    var environment: Environment
    var poller: Poller
    var apiClient: APIClient
    var fetcher: Fetcher
    var cache: ConfigCache

    init() {
        self.environment = Environment()
        self.apiClient = APIClient()
        self.fetcher = Fetcher(client: apiClient,
                               environment: environment)
        self.poller = Poller(delay: environment.pollingDelay ?? PollerConstants.defaultDelay)
        self.cache = ConfigCache(fetcher: fetcher,
                                 poller: poller,
                                 applyConfigDirectly: environment.applyConfigDirectlyAfterFetch)
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

    func fetchAndPollConfig() {
        cache.fetchAndPollConfig()
    }

    func fetchAndApplyConfig(completionHandler: @escaping (ConfigDictionary) -> Void) {
        cache.fetchAndApplyConfig(completionHandler: completionHandler)
    }
}
