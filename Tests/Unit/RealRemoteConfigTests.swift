import Quick
import Nimble
@testable import RRemoteConfig

class RealRemoteConfigSpec: QuickSpec {
    override func spec() {
        describe("getString function") {
            it("returns a string") {
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: ["foo": "moo"])

                expect(RealRemoteConfig.shared.getString("foo", "bar")).to(equal("moo"))
            }
        }
        describe("refreshConfig function") {
            it("calls config cache refresh") {
                RealRemoteConfig.shared.cache = createCacheMock()
                (RealRemoteConfig.shared.cache as? CacheMock)?.refreshCalled = false

                RealRemoteConfig.shared.refreshConfig()

                expect((RealRemoteConfig.shared.cache as? CacheMock)?.refreshCalled).to(equal(true))
            }
        }
    }
}
