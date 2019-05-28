import Quick
import Nimble
@testable import RRemoteConfig

class ConfigCacheSpec: QuickSpec {
    override func spec() {
        describe("init function") {
            it("sets expected default as the cache url when no cacheUrl param is supplied") {
                let expectedUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("rrc-config.plist")
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())

                let configCache = ConfigCache(fetcher: fetcher, poller: ConfigPoller())

                expect(configCache.cacheUrl).toEventually(equal(expectedUrl))
            }

            it("sets the cache url to the supplied cacheUrl param") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())

                let configCache = ConfigCache(fetcher: fetcher, poller: ConfigPoller(), cacheUrl: url)

                expect(configCache.cacheUrl).toEventually(equal(url))
            }

            it("when cache file has contents the config is empty immediately after init returns") {
                let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("foo")
                NSDictionary(dictionary: ["foo": "bar"]).write(to: url, atomically: true)
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: ConfigPoller())
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
        describe("getString function") {
            it("returns the value from config when key exists in config") {
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: ConfigPoller(), initialCacheContents: ["foo": "bar"])

                let value = configCache.getString("foo", "not found")

                expect(value).to(equal("bar"))
            }

            it("returns the fallback when key is not found in config") {
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: ConfigPoller(), initialCacheContents: ["moo": "bar"])
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }

            it("returns the fallback when config is empty") {
                let fetcher = ConfigFetcher(client: APIClient(), environment: Environment())
                let configCache = ConfigCache(fetcher: fetcher, poller: ConfigPoller())
                let fallback = "not found"

                let value = configCache.getString("foo", fallback)

                expect(value).to(equal(fallback))
            }
        }
    }
}
