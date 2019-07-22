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
        describe("getBoolean function") {
            it("returns a boolean") {
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: ["foo": "true"])

                expect(RealRemoteConfig.shared.getBoolean("foo", false)).to(beTrue())
            }
        }
        describe("getNumber function") {
            it("returns a number") {
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: ["foo": "10"])

                expect(RealRemoteConfig.shared.getNumber("foo", 20)).to(equal(10))
            }
        }
        describe("getConfig function") {
            it("returns the config") {
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: ["foo": "bar", "moo": "100"])

                expect(RealRemoteConfig.shared.getConfig()).to(equal(["foo": "bar", "moo": "100"]))
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
