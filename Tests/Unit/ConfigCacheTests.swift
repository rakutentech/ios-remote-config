import Quick
import Nimble
@testable import RRemoteConfig

class ConfigCacheSpec: QuickSpec {
    override func spec() {
        describe("init function") {
            let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())

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
                NSDictionary(dictionary: ["foo": "bar"]).write(to: url, atomically: true)
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
        describe("getString function") {
            let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())

            it("returns the value from config when key exists in config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["foo": "bar"])

                let value = configCache.getString("foo", "not found")

                expect(value).to(equal("bar"))
            }

            it("returns the fallback when key is not found in config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["moo": "bar"])
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
            let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())

            it("returns the value from config when key exists") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["foo": "true"])

                let value = configCache.getBoolean("foo", false)

                expect(value).to(beTrue())
            }

            it("returns the fallback when key is not found in config") {
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["moo": "true"])
                let fallback = false

                let value = configCache.getBoolean("foo", fallback)

                expect(value).to(equal(fallback))
            }

            it("returns the fallback when config is empty") {
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())
                let fallback = false

                let value = configCache.getBoolean("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
        describe("getNumber function") {
            let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())

            it("returns value that can be treated as int from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["foo": "10"])

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(10))
            }

            it("returns value that can be treated as double from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["foo": "10.123"])

                let value = configCache.getNumber("foo", 5.0)

                expect(value.doubleValue).to(beCloseTo(10.123))
            }

            it("returns value that can be treated as float from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["foo": "10.123"])

                let value = configCache.getNumber("foo", 5.5)

                expect(value.floatValue).to(beCloseTo(10.123))
            }

            it("returns value that can be treated as uint8 (byte) from config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["foo": "254"])

                let value = configCache.getNumber("foo", 10)

                expect(value.uint8Value).to(equal(UInt8(0xfe)))
            }

            it("returns fallback when value string cannot be converted to a number") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["foo": "bar"])

                let value = configCache.getNumber("foo", 5)

                expect(value.intValue).to(equal(5))
            }

            it("returns fallback when key is not found in config") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["moo": "10"])

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
            let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())

            it("returns empty dictionary when config is empty") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())

                let value = configCache.getConfig()

                expect(value).to(equal([:]))
            }

            it("returns dictionary contents when config is non-empty") {
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller(), initialCacheContents: ["moo": "10", "foo": "coo"])

                let value = configCache.getConfig()

                expect(value).to(equal(["moo": "10", "foo": "coo"]))
            }
        }
        describe("refreshFromRemote function") {
            class FetcherMock: ConfigFetcher {
                var fetcherCalledNumTimes = 0
                var fetchedConfig = ConfigModel(config: ["": ""])

                override func fetch(completionHandler: @escaping (ConfigModel?) -> Void) {
                    fetcherCalledNumTimes += 1
                    completionHandler(fetchedConfig)
                }
            }

            it("calls the fetcher's fetch function exactly once") {
                let fetcher = FetcherMock(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())

                configCache.refreshFromRemote()

                expect(fetcher.fetcherCalledNumTimes).to(equal(1))
            }

            it("writes the fetched config to the cache file") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")
                let fetcher = FetcherMock(client: APIClient(), environment: Environment())
                fetcher.fetchedConfig = ConfigModel(config: ["foo": "bar"])
                let configCache = ConfigCache(fetcher: fetcher, poller: Poller())

                configCache.refreshFromRemote()

                expect(NSDictionary(contentsOf: url)).to(equal(["foo": "bar"]))
            }
        }
    }
}
