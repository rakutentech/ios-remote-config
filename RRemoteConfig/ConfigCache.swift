internal class ConfigPoller {
}

internal class ConfigCache {
    let fetcher: ConfigFetcher
    let poller: ConfigPoller
    let cacheUrl: URL
    private var activeConfig: ConfigModel? = ConfigModel(config: [:])

    init(fetcher: ConfigFetcher,
         poller: ConfigPoller,
         cacheUrl: URL = FileManager.getCacheDirectory().appendingPathComponent("rrc-config.plist"),
         initialCacheContents: [String: String]? = nil) {
        self.fetcher = fetcher
        self.poller = poller
        self.cacheUrl = cacheUrl
        if let initialCacheContents = initialCacheContents {
            self.activeConfig = ConfigModel(config: initialCacheContents)
        }
        DispatchQueue.global(qos: .utility).async {
            if let dictionary = NSDictionary.init(contentsOf: self.cacheUrl) as? [String: String] {
                #if DEBUG
                print("Config read from cache plist \(cacheUrl): \(dictionary)")
                #endif
                self.activeConfig = ConfigModel(config: dictionary)
            }
        }
    }

    func getString(_ key: String, _ fallback: String) -> String {
        guard let config = activeConfig?.config else {
            return fallback
        }
        return config[key] ?? fallback
    }

    func refreshFromRemote() {
        self.fetcher.fetch { (result) in
            guard let config = result?.config else {
                return print("Config could not be refreshed from remote")
            }
            self.write(config)
        }
    }

    fileprivate func write(_ config: [String: String]) {
        DispatchQueue.global(qos: .utility).async {
            NSDictionary(dictionary: config).write(to: self.cacheUrl, atomically: true)
            #if DEBUG
            let readFromPlist = NSDictionary(contentsOf: self.cacheUrl)
            print("Config written to cache plist: \(String(describing: readFromPlist))")
            #endif
        }
    }
}

extension FileManager {
    class func getCacheDirectory() -> URL {
        let cachePaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cachePaths[0]
    }
}
