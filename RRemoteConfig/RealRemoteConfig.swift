import RemoteConfigShared

internal class RealRemoteConfig {
    static let shared = RealRemoteConfig()
    var environment: Environment
    var poller: Poller
    var apiClient: ConfigApiClient
    var cache: ConfigCache

    init() {
        self.environment = Environment()
        self.apiClient = ConfigApiClient(
            platformClient: ConfigApiClientKt.createHttpClient(),
            baseUrl: self.environment.baseUrl!.absoluteString,
            appId: self.environment.appId,
            subscriptionKey: self.environment.subscriptionKey,
            deviceModel: self.environment.deviceModel,
            osVersion: self.environment.osVersion,
            appName: self.environment.appName,
            appVersion: self.environment.appVersion,
            sdkVersion: self.environment.sdkVersion
        )
        self.poller = Poller()
        self.cache = ConfigCache(apiClient: apiClient, poller: poller)
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
