import Quick
import Nimble
@testable import RRemoteConfig

class RealRemoteConfigSpec: QuickSpec {
    class CacheMock: ConfigCache {
        var getStringCalled = false
        var refreshCalled = false

        override func refreshFromRemote() {
            self.refreshCalled = true
        }

        override func getString(_ key: String, _ fallback: String) -> String {
            self.getStringCalled = true
            return fallback
        }
    }
    override func spec() {
        describe("getString function") {
            it("calls config cache get string") {
                RealRemoteConfig.shared.cache = CacheMock(fetcher: ConfigFetcher(client: APIClient(), environment: Environment()), poller: ConfigPoller())

                _ = RealRemoteConfig.shared.getString("foo", "bar")

                expect((RealRemoteConfig.shared.cache as? CacheMock)?.getStringCalled).to(equal(true))
            }

            it("returns a string") {
                let string = RealRemoteConfig.shared.getString("foo", "bar")

                expect(string).to(equal("bar"))
            }
        }
        describe("refreshConfig function") {
            it("calls config cache refresh from remote") {
                RealRemoteConfig.shared.cache = CacheMock(fetcher: ConfigFetcher(client: APIClient(), environment: Environment()), poller: ConfigPoller())

                RealRemoteConfig.shared.refreshConfig()

                expect((RealRemoteConfig.shared.cache as? CacheMock)?.refreshCalled).to(equal(true))
            }
        }
    }
}
