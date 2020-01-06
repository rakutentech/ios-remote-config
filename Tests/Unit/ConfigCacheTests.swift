import Quick
import Nimble
@testable import RRemoteConfig
import RemoteConfigShared

class ConfigCacheSpec: QuickSpec {
    func createApiClient() -> ConfigApiClient {
        return ConfigApiClient(platformClient: ConfigApiClientKt.createHttpClient(),
            baseUrl: "https://www.example.com",
            appId: "test_app_id",
            subscriptionKey: "test_subscription_key",
            deviceModel: "test_device_model",
            osVersion: "test_os_version",
            appName: "test_app_name",
            appVersion: "test_app_version",
            sdkVersion: "test_sdk_version"
        )
    }

    override func spec() {
        describe("init function") {
            it("sets expected default as the cache url when no cacheUrl param is supplied") {
                let expectedUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("rrc-config.plist")

                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller())

                expect(configCache.cacheUrl).toEventually(equal(expectedUrl))
            }

            it("sets the cache url to the supplied cacheUrl param") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")

                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller())

                expect(configCache.cacheUrl).toEventually(equal(url))
            }

            it("when cache file has contents the config is empty immediately after init returns") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")
                NSDictionary(dictionary: ["body": ["foo": "bar"]]).write(to: url, atomically: true)
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller())
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }
            describe("set active config from cached config") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")
                let verifier = VerifierMock()
                let jsonData = (try? JSONSerialization.data(withJSONObject: ["body": ["foo": "bar"], "keyId": "1234"], options: []))!

                beforeEach {
                    let written = NSDictionary(dictionary:
                        ["config": jsonData,
                         "signature": "sigfoo"
                        ]).write(to: url, atomically: true)
                    print("test data written to cache url \(url): \(String(describing: written))")
                }

                describe("key is found in key store") {
                    let keyStore = KeyStoreMock(contents: ["1234": "ABCDE"])

                    it("sets the active config when verification succeeds") {
                        verifier.verifyOK = true

                        let configCache = ConfigCache(apiClient: self.createApiClient(),
                                                      poller: Poller(),
                                                      cacheUrl: url,
                                                      keyStore: keyStore,
                                                      verifier: verifier)

                        expect(configCache.getConfig() as NSDictionary).toEventually(equal(["foo": "bar"] as NSDictionary), timeout: 10)
                    }

                    it("does not set the active config when verification fails") {
                        verifier.verifyOK = false

                        let configCache = ConfigCache(apiClient: self.createApiClient(),
                                                      poller: Poller(),
                                                      cacheUrl: url,
                                                      keyStore: keyStore,
                                                      verifier: verifier)

                        expect(configCache.getConfig() as NSDictionary).toEventually(equal([:] as NSDictionary), timeout: 1)
                    }
                }
                describe("key is not found in key store") {
                    it("does not set the active config") {
                        let configCache = ConfigCache(apiClient: self.createApiClient(),
                                                      poller: Poller(),
                                                      cacheUrl: url,
                                                      keyStore: KeyStoreMock(contents: [:]),
                                                      verifier: verifier)

                        expect(configCache.getConfig() as NSDictionary).toEventually(equal([:] as NSDictionary), timeout: 1)
                    }
                }
            }
        }
        describe("getString function") {
            it("returns the value from config when key exists in config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"foo":"bar"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getString("foo", "not found")

                expect(value).to(equal("bar"))
            }

            it("returns the fallback when key is not found in config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"moo":"bar"},"keyId":"fooKey"}"#.data(using: .utf8))
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }

            it("returns the fallback when config is empty") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller())
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
        describe("getBoolean function") {
            it("returns the value from config when key exists") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"foo":"true"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getBoolean("foo", false)

                expect(value).to(beTrue())
            }

            it("returns the fallback when key is not found in config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"moo":"true"},"keyId":"fooKey"}"#.data(using: .utf8))
                let fallback = false

                let value = configCache.getBoolean("foo", fallback)

                expect(value).to(equal(fallback))
            }

            it("returns the fallback when config is empty") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller())
                let fallback = false

                let value = configCache.getBoolean("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
        describe("getNumber function") {
            it("returns value that can be treated as int from config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"foo":"10"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(10))
            }

            it("returns value that can be treated as double from config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"foo":"10.123"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5.0)

                expect(value.doubleValue).to(beCloseTo(10.123))
            }

            it("returns value that can be treated as float from config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"foo":"10.123"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5.5)

                expect(value.floatValue).to(beCloseTo(10.123))
            }

            it("returns value that can be treated as uint8 (byte) from config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"foo":"254"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 10)

                expect(value.uint8Value).to(equal(UInt8(0xfe)))
            }

            it("returns fallback when value string cannot be converted to a number") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"foo":"bar"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(5))
            }

            it("returns fallback when key is not found in config") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"moo":"10"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(5))
            }

            it("returns fallback when config is empty") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller())

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(5))
            }
        }
        describe("getConfig function") {
            it("returns empty dictionary when config is empty") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller())

                let value = configCache.getConfig()

                expect(value).to(equal([:]))
            }

            it("returns dictionary contents when config is non-empty") {
                let configCache = ConfigCache(apiClient: self.createApiClient(), poller: Poller(), initialCacheContents: #"{"body":{"moo":"10","foo":"coo"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getConfig()

                expect(value).to(equal(["moo": "10", "foo": "coo"]))
            }
        }
        describe("refreshFromRemote function") {
            let jsonData = #"{"body":{"foo":"bar"},"keyId":"aKey"}"#
            let mockApiClient = ConfigApiClientMock()
            let configCache = ConfigCache(apiClient: mockApiClient, poller: Poller())
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("bar")
            let verifier = VerifierMock()

            beforeEach {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                }
            }

            it("calls the fetcher's fetch function exactly once") {
                mockApiClient.fetchConfigCalledNumTimes = 0
                configCache.refreshFromRemote()

                expect(mockApiClient.fetchConfigCalledNumTimes).toEventually(equal(1))
            }

            describe("when the verification key is found locally") {
                mockApiClient.fetchedConfig = Config(rawBody: jsonData, body: ["": ""], signature: "aSig", keyId: "")
                let configCache = ConfigCache(apiClient: mockApiClient,
                                              poller: Poller(),
                                              cacheUrl: url,
                                              keyStore: KeyStoreMock(contents: ["aKey": "1234"]),
                                              verifier: verifier)

                it("writes the fetched config when verification succeeds") {
                    verifier.verifyOK = true

                    configCache.refreshFromRemote()

                    let expected: [String: Any] = [
                        "config": jsonData,
                        "signature": "aSig"
                    ]
                    expect(NSDictionary(contentsOf: configCache.cacheUrl)).toEventually(equal(expected as NSDictionary), timeout: 2)
                }

                it("does not write the fetched config when verification fails") {
                    let expected: [AnyHashable: Any] = [:]
                    NSDictionary(dictionary: expected).write(to: url, atomically: true)
                    verifier.verifyOK = false
                    var cacheContents: NSDictionary?

                    configCache.refreshFromRemote()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        cacheContents = NSDictionary(contentsOf: configCache.cacheUrl)
                    })

                    expect(cacheContents).toEventually(equal(expected as NSDictionary), timeout: 1.0)
                }
            }
            describe("when the verification key is not found locally") {
                mockApiClient.fetchedConfig = Config(rawBody: jsonData, body: ["": ""], signature: "aSig", keyId: "")
                let keyStore = KeyStoreMock(contents: [:])
                let configCache = ConfigCache(apiClient: mockApiClient,
                                              poller: Poller(),
                                              cacheUrl: url,
                                              keyStore: keyStore,
                                              verifier: verifier)

                beforeEach {
                    keyStore.store = [:]
                    mockApiClient.fetchKeyCalledNumTimes = 0
                }
                it("calls the fetch key function") {
                    configCache.refreshFromRemote()

                    expect(mockApiClient.fetchKeyCalledNumTimes).toEventually(equal(1))
                }

                it("adds the key after fetching it") {
                    mockApiClient.fetchedKey = "aKey"

                    configCache.refreshFromRemote()

                    expect(keyStore.store?["aKey"]).toEventually(equal("123"), timeout: 2.0)
                }
            }
        }
    }
}
