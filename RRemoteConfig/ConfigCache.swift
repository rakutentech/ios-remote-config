import RemoteConfigShared

internal class ConfigCache {
    let apiClient: ConfigApiClient
    let poller: Poller
    let cacheUrl: URL
    let keyStore: KeyStore
    let verifier: Verifier
    private var activeConfig: ConfigModel?
    private var numberFormatter: NumberFormatter

    init(apiClient: ConfigApiClient,
         poller: Poller,
         cacheUrl: URL = FileManager.getCacheDirectory().appendingPathComponent("rrc-config.plist"),
         initialCacheContents: Data? = nil,
         keyStore: KeyStore = KeyStore(),
         verifier: Verifier = Verifier()) {
        self.apiClient = apiClient
        self.poller = poller
        self.cacheUrl = cacheUrl
        self.numberFormatter = NumberFormatter()
        self.keyStore = keyStore
        self.verifier = verifier

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
                    Logger.d("Cached contents verified -> set as active config")
                    self.activeConfig = configModel
                } else {
                    Logger.e("Cached dictionary contents failed verification")
                }
            }
        }
    }

    func refreshFromRemote() {
        self.poller.start {
            DispatchQueue.main.async {
                self.fetchConfig()
            }
        }
    }

    // MARK: Get config methods
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

    // MARK: Private helpers
    fileprivate func fetchConfig() {
        self.apiClient.fetchConfig(success: { (result) in
            let body = result.rawBody as String
            var configModel = ConfigModel(data: body.data(using: .utf8)!)!
            configModel.signature = result.signature
            self.verifyContents(model: configModel, resultHandler: { (verified) in
                if verified {
                    let dictionary = [
                        "config": configModel.jsonData,
                        "signature": configModel.signature as Any
                    ]
                    self.write(dictionary)
                } else {
                    Logger.e("Fetched dictionary contents failed verification")
                }
            })
        }, error: { (exception) in
            Logger.e("Failed to fetch config: " + exception.description())
        })
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

extension FileManager {
    class func getCacheDirectory() -> URL {
        let cachePaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cachePaths[0]
    }
}

// MARK: Payload signature verification
extension ConfigCache {
    // synchronous verification with local key store
    func verifyContents(model: ConfigModel) -> Bool {
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
    func verifyContents(model: ConfigModel, resultHandler: @escaping (Bool) -> Void ) {
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
            apiClient.fetchPublicKey(keyId: keyId, success: { (key) in
                self.keyStore.addKey(key: key, for: keyId)
                let verified = self.verifier.verify(signatureBase64: signature,
                        objectData: model.jsonData,
                        keyBase64: key)
                resultHandler(verified)
            }, error: { (error) in
                resultHandler(false)
            })
        }
    }
}
