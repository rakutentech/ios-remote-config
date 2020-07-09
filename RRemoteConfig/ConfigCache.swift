internal class ConfigCache {
    let fetcher: Fetcher
    let poller: Poller
    let cacheUrl: URL
    let keyStore: KeyStore
    let verifier: Verifier
    private var activeConfig: ConfigModel?
    private var numberFormatter: NumberFormatter
    private var applyConfigDirectly: Bool = false

    init(fetcher: Fetcher,
         poller: Poller,
         cacheUrl: URL = FileManager.getCacheDirectory().appendingPathComponent("rrc-config.plist"),
         initialCacheContents: Data? = nil,
         keyStore: KeyStore = KeyStore(),
         verifier: Verifier = Verifier(),
         applyConfigDirectly: Bool = false) {
        self.fetcher = fetcher
        self.poller = poller
        self.cacheUrl = cacheUrl
        self.numberFormatter = NumberFormatter()
        self.keyStore = keyStore
        self.verifier = verifier
        self.applyConfigDirectly = applyConfigDirectly

        if let data = initialCacheContents {
            self.activeConfig = ConfigModel(data: data)
        }
        DispatchQueue.global(qos: .utility).async {
            let defaults = UserDefaults.standard
            let firstLaunch = "first_launch"
            if defaults.string(forKey: firstLaunch) == nil {
                defaults.set("true", forKey: firstLaunch)
                keyStore.empty()
            }

            if let dictionary = NSDictionary.init(contentsOf: self.cacheUrl) as? [String: Any] {
                Logger.v("Config read from cache plist \(cacheUrl): \(dictionary)")

                guard
                    let configData = dictionary["config"] as? Data,
                    var configModel = ConfigModel(data: configData) else {
                    return Logger.e("Config data in cache is invalid")
                }
                configModel.signature = dictionary["signature"] as? String

                if self.verifyContents(model: configModel) {
                    Logger.d("Cached config verified -> set as active config")
                    self.activeConfig = configModel
                } else {
                    Logger.e("Cached config \(configModel.config) failed verification")
                }
            }
        }
    }

    func getString(_ key: String, _ fallback: String) -> String {
        guard let config = activeConfig?.config else {
            return fallback
        }
        return config[key] ?? fallback
    }

    func getBoolean(_ key: String, _ fallback: Bool) -> Bool {
        guard let config = activeConfig?.config, let value = config[key] else {
            return fallback
        }
        return (value as NSString).boolValue
    }

    func getNumber(_ key: String, _ fallback: NSNumber) -> NSNumber {
        guard
            let config = activeConfig?.config,
            let value = config[key] else {
                return fallback
        }
        return numberFormatter.number(from: value) ?? fallback
    }

    func getConfig() -> [String: String] {
        return activeConfig?.config ?? [:]
    }

    func fetchAndPollConfig() {
        poller.start {
            self.fetchConfig(applyDirectly: self.applyConfigDirectly) { _ in }
        }
    }

    func fetchAndApplyConfig(completionHandler: @escaping (ConfigDictionary) -> Void) {
        self.fetchConfig(applyDirectly: true) { (configModel) in
            completionHandler(configModel?.config ?? ConfigDictionary())
        }
    }
}

// MARK: Fetch and store config
extension ConfigCache {
    fileprivate func fetchConfig(applyDirectly: Bool, completionHandler: @escaping (ConfigModel?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            self.fetcher.fetchConfig { (result) in
                guard let configModel = result else {
                    completionHandler(nil)
                    return Logger.e("Config could not be fetched from remote")
                }

                self.verifyContents(model: configModel, resultHandler: { (verified) in
                    guard verified else {
                        completionHandler(nil)
                        return Logger.e("Fetched config \(configModel.config) failed verification")
                    }

                    self.write([
                        "config": configModel.jsonData,
                        "signature": configModel.signature as Any
                    ])

                    if applyDirectly {
                        Logger.d("Fetched config verified -> set immediately as active config")
                        self.activeConfig = configModel
                    } else {
                        Logger.d("Fetched config verified -> set as active config on next app launch")
                    }

                    completionHandler(configModel)
                })
            }
        }
    }

    fileprivate func write(_ config: [String: Any]) {
        DispatchQueue.global(qos: .utility).async {
            NSDictionary(dictionary: config).write(to: self.cacheUrl, atomically: true)
            let readFromPlist = NSDictionary(contentsOf: self.cacheUrl)
            Logger.d("Fetched config verified and cached")
            Logger.v("Contents written to url \(self.cacheUrl):\n\(String(describing: readFromPlist))")
        }
    }
}

// MARK: Payload signature verification
extension ConfigCache {
    // synchronous verification with local key store
    fileprivate func verifyContents(model: ConfigModel) -> Bool {
        guard let keyId = model.keyId,
            let key = keyStore.key(for: keyId),
            let signature = model.signature else {
            return false
        }
        return self.verifier.verify(signatureBase64: signature,
                                    objectData: model.jsonData,
                                    keyBase64: key)
    }

    // asynchronous verification - fetches key from backend if key is not
    // found in local key store
    fileprivate func verifyContents(model: ConfigModel, resultHandler: @escaping (Bool) -> Void ) {
        guard let keyId = model.keyId,
            let signature = model.signature else {
                return resultHandler(false)
        }

        if let key = keyStore.key(for: keyId) {
            let verified = self.verifier.verify(signatureBase64: signature,
                                                objectData: model.jsonData,
                                                keyBase64: key)
            resultHandler(verified)
        } else {
            fetcher.fetchKey(with: keyId) { (keyModel) in
                guard let key = keyModel?.key, keyModel?.id == model.keyId else {
                    return resultHandler(false)
                }
                self.keyStore.addKey(key: key, for: keyId)
                let verified = self.verifier.verify(signatureBase64: signature,
                                                    objectData: model.jsonData,
                                                    keyBase64: key)
                resultHandler(verified)
            }
        }
    }
}

extension FileManager {
    fileprivate class func getCacheDirectory() -> URL {
        let cachePaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cachePaths[0]
    }
}
