import Quick
import Nimble
@testable import RRemoteConfig

// swiftlint:disable file_length

class ConfigCacheSpec: QuickSpec {
    override func spec() {
        describe("init function") {
            let fetcher = Fetcher(client: APIClient(), environment: Environment())

            it("sets expected default as the cache url when no cacheUrl param is supplied") {
                let expectedUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("rrc-config.plist")

                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())

                expect(configCache.cacheUrl).toEventually(equal(expectedUrl))
            }

            it("sets the cache url to the supplied cacheUrl param") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")

                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), cacheUrl: url)

                expect(configCache.cacheUrl).toEventually(equal(url))
            }

            it("when cache file has contents the config is empty immediately after init returns") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")
                NSDictionary(dictionary: ["body": ["foo": "bar"]]).write(to: url, atomically: true)
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), cacheUrl: url)
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }
            describe("set active config from cached config") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")
                let verifier = VerifierMock()
                let fetcher = Fetcher(client: APIClient(), environment: Environment())
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

                        let configCache = ConfigCache(fetcher: fetcher,
                                                      poller: Poller(),
                                                      cacheUrl: url,
                                                      keyStore: keyStore,
                                                      verifier: verifier)

                        expect(configCache.getConfig() as NSDictionary).toEventually(equal(["foo": "bar"] as NSDictionary), timeout: 10)
                    }

                    it("does not set the active config when verification fails") {
                        verifier.verifyOK = false

                        let configCache = ConfigCache(fetcher: fetcher,
                                                      poller: Poller(),
                                                      cacheUrl: url,
                                                      keyStore: keyStore,
                                                      verifier: verifier)

                        expect(configCache.getConfig() as NSDictionary).toEventually(equal([:] as NSDictionary), timeout: 1)
                    }
                }
                describe("key is not found in key store") {
                    it("does not set the active config") {
                        let configCache = ConfigCache(fetcher: fetcher,
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
            let fetcher = Fetcher(client: APIClient(), environment: Environment())

            it("returns the value from config when key exists in config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"foo":"bar"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getString("foo", "not found")

                expect(value).to(equal("bar"))
            }

            it("returns the fallback when key is not found in config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"moo":"bar"},"keyId":"fooKey"}"#.data(using: .utf8))
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }

            it("returns the fallback when config is empty") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
        describe("getBoolean function") {
            let fetcher = Fetcher(client: APIClient(), environment: Environment())

            it("returns the value from config when key exists") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"foo":"true"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getBoolean("foo", false)

                expect(value).to(beTrue())
            }

            it("returns the fallback when key is not found in config") {
                let fetcher = Fetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"moo":"true"},"keyId":"fooKey"}"#.data(using: .utf8))
                let fallback = false

                let value = configCache.getBoolean("foo", fallback)

                expect(value).to(equal(fallback))
            }

            it("returns the fallback when config is empty") {
                let fetcher = Fetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())
                let fallback = false

                let value = configCache.getBoolean("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
        describe("getNumber function") {
            let fetcher = Fetcher(client: APIClient(), environment: Environment())

            it("returns value that can be treated as int from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"foo":"10"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(10))
            }

            it("returns value that can be treated as double from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"foo":"10.123"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5.0)

                expect(value.doubleValue).to(beCloseTo(10.123))
            }

            it("returns value that can be treated as float from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"foo":"10.123"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5.5)

                expect(value.floatValue).to(beCloseTo(10.123))
            }

            it("returns value that can be treated as uint8 (byte) from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"foo":"254"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 10)

                expect(value.uint8Value).to(equal(UInt8(0xfe)))
            }

            it("returns fallback when value string cannot be converted to a number") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"foo":"bar"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(5))
            }

            it("returns fallback when key is not found in config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"moo":"10"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(5))
            }

            it("returns fallback when config is empty") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(5))
            }
        }
        describe("getConfig function") {
            let fetcher = Fetcher(client: APIClient(), environment: Environment())

            it("returns empty dictionary when config is empty") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())

                let value = configCache.getConfig()

                expect(value).to(equal([:]))
            }

            it("returns dictionary contents when config is non-empty") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: #"{"body":{"moo":"10","foo":"coo"},"keyId":"fooKey"}"#.data(using: .utf8))

                let value = configCache.getConfig()

                expect(value).to(equal(["moo": "10", "foo": "coo"]))
            }
        }
        describe("fetch config") {
            let jsonData = #"{"body":{"foo":"bar"},"keyId":"aKey"}"#.data(using: .utf8)!
            let fetcher = FetcherMock(client: APIClient(), environment: Environment())
            let configCache = ConfigCache(fetcher: fetcher, poller: Poller())
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("bar")
            let verifier = VerifierMock()

            beforeEach {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                }
            }

            describe("fetchAndPollConfig") {
                it("calls the fetcher exactly once") {
                    fetcher.fetchConfigCalledNumTimes = 0
                    configCache.fetchAndPollConfig()

                    expect(fetcher.fetchConfigCalledNumTimes).toEventually(equal(1))
                }

                describe("when the verification key is found locally") {
                    fetcher.fetchedConfig = ConfigModel(data: jsonData)
                    fetcher.fetchedConfig?.signature = "aSig"
                    let configCache = ConfigCache(fetcher: fetcher,
                                                  poller: Poller(),
                                                  cacheUrl: url,
                                                  keyStore: KeyStoreMock(contents: ["aKey": "1234"]),
                                                  verifier: verifier)

                    it("writes the fetched config when verification succeeds") {
                        verifier.verifyOK = true

                        configCache.fetchAndPollConfig()

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

                        configCache.fetchAndPollConfig()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            cacheContents = NSDictionary(contentsOf: configCache.cacheUrl)
                        })

                        expect(cacheContents).toEventually(equal(expected as NSDictionary), timeout: 1.0)
                    }
                }
                describe("when the verification key is not found locally") {
                    fetcher.fetchedConfig = ConfigModel(data: jsonData)
                    fetcher.fetchedConfig?.signature = "aSig"
                    let keyStore = KeyStoreMock(contents: [:])
                    let configCache = ConfigCache(fetcher: fetcher,
                                                  poller: Poller(),
                                                  cacheUrl: url,
                                                  keyStore: keyStore,
                                                  verifier: verifier)

                    beforeEach {
                        keyStore.store = [:]
                        fetcher.fetchKeyCalledNumTimes = 0
                    }
                    it("calls the fetch key function") {
                        configCache.fetchAndPollConfig()

                        expect(fetcher.fetchKeyCalledNumTimes).toEventually(equal(1))
                    }

                    it("adds the key after fetching it") {
                        let jsonData = #"{"id":"aKey","key":"123","createdAt":""}"#.data(using: .utf8)!
                        fetcher.fetchedKey = KeyModel(data: jsonData)

                        configCache.fetchAndPollConfig()

                        expect(keyStore.store?["aKey"]).toEventually(equal("123"), timeout: 2.0)
                    }
                }
            }
            describe("fetchAndApplyConfig") {
                it("calls the fetcher exactly once") {
                    fetcher.fetchConfigCalledNumTimes = 0
                    configCache.fetchAndApplyConfig { _ in }

                    expect(fetcher.fetchConfigCalledNumTimes).toEventually(equal(1))
                }

                describe("when the verification key is found locally") {
                    fetcher.fetchedConfig = ConfigModel(data: jsonData)
                    fetcher.fetchedConfig?.signature = "aSig"
                    let configCache = ConfigCache(fetcher: fetcher,
                                                  poller: Poller(),
                                                  cacheUrl: url,
                                                  keyStore: KeyStoreMock(contents: ["aKey": "1234"]),
                                                  verifier: verifier)

                    describe("if verification succeeds") {
                        beforeEach {
                            verifier.verifyOK = true
                        }
                        it("writes fetched config to cache") {
                            let expected: [String: Any] = [
                                "config": jsonData,
                                "signature": "aSig"
                            ]

                            configCache.fetchAndApplyConfig { _ in }

                            expect(NSDictionary(contentsOf: configCache.cacheUrl)).toEventually(equal(expected as NSDictionary), timeout: 2)
                        }

                        it("passes fetched config to completion handler") {
                            let expected = ["foo": "bar"]
                            var receivedConfig: [AnyHashable: Any] = ["ying": "yang"]

                            configCache.fetchAndApplyConfig { (config) in
                                receivedConfig = config
                            }

                            expect(receivedConfig as NSDictionary).toEventually(equal(expected as NSDictionary), timeout: 2)
                        }

                        it("sets the fetched config as active directly") {
                            let expected = ["foo": "bar"]
                            var receivedConfig: [AnyHashable: Any] = ["ying": "yang"]

                            configCache.fetchAndApplyConfig { (config) in
                                receivedConfig = config
                            }

                            expect(receivedConfig as NSDictionary).toEventually(equal(expected as NSDictionary), timeout: 2)
                        }
                    }
                    describe("if verification fails") {
                        beforeEach {
                            verifier.verifyOK = false
                        }
                        it("does not write the fetched config") {
                            let expected: [AnyHashable: Any] = [:]
                            NSDictionary(dictionary: expected).write(to: url, atomically: true)
                            var cacheContents: NSDictionary?

                            configCache.fetchAndApplyConfig { _ in
                                cacheContents = NSDictionary(contentsOf: configCache.cacheUrl)
                            }

                            expect(cacheContents).toEventually(equal(expected as NSDictionary), timeout: 2)
                        }

                        it("passes empty config to the completion handler") {
                            var receivedConfig: [AnyHashable: String] = ["foo": "bar"]

                            configCache.fetchAndApplyConfig { (config) in
                                receivedConfig = config
                            }

                            expect(receivedConfig.count).toEventually(equal(0), timeout: 2)
                        }
                    }
                }
                describe("when the verification key is not found locally") {
                    fetcher.fetchedConfig = ConfigModel(data: jsonData)
                    fetcher.fetchedConfig?.signature = "aSig"
                    let keyStore = KeyStoreMock(contents: [:])
                    let configCache = ConfigCache(fetcher: fetcher,
                                                  poller: Poller(),
                                                  cacheUrl: url,
                                                  keyStore: keyStore,
                                                  verifier: verifier)

                    beforeEach {
                        keyStore.store = [:]
                        fetcher.fetchKeyCalledNumTimes = 0
                    }
                    it("calls the fetch key function") {
                        configCache.fetchAndApplyConfig { _ in }

                        expect(fetcher.fetchKeyCalledNumTimes).toEventually(equal(1))
                    }

                    it("adds the key after fetching it") {
                        let jsonData = #"{"id":"aKey","key":"123","createdAt":""}"#.data(using: .utf8)!
                        fetcher.fetchedKey = KeyModel(data: jsonData)

                        configCache.fetchAndApplyConfig { _ in }

                        expect(keyStore.store?["aKey"]).toEventually(equal("123"), timeout: 2.0)
                    }
                }
            }
        }
    }
}
