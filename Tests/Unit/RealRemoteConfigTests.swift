import Quick
import Nimble
@testable import RRemoteConfig

class RealRemoteConfigSpec: QuickSpec {
    override func spec() {
        describe("getString function") {
            it("retrieves string from the cache for provided key") {
                let data = #"{"body":{"foo":"moo"},"keyId":"fooKey"}"#.data(using: .utf8)!
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: data)

                expect(RealRemoteConfig.shared.getString("foo", "bar")).to(equal("moo"))
            }
        }
        describe("getBoolean function") {
            it("retrieves boolean from the cache for provided key") {
                let data = #"{"body":{"foo":"true"},"keyId":"fooKey"}"#.data(using: .utf8)!
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: data)

                expect(RealRemoteConfig.shared.getBoolean("foo", false)).to(beTrue())
            }
        }
        describe("getNumber function") {
            it("retrieves number from the cache for provided key") {
                let data = #"{"body":{"foo":"10"},"keyId":"fooKey"}"#.data(using: .utf8)!
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: data)

                expect(RealRemoteConfig.shared.getNumber("foo", 20)).to(equal(10))
            }
        }
        describe("getConfig function") {
            it("returns the config cache dictionary") {
                let data = #"{"body":{"foo":"bar","moo":"100"},"keyId":"fooKey"}"#.data(using: .utf8)!
                RealRemoteConfig.shared.cache = createCacheMock(initialContents: data)

                expect(RealRemoteConfig.shared.getConfig()).to(equal(["foo": "bar", "moo": "100"]))
            }
        }
        describe("fetchAndPollConfig function") {
            it("calls config cache fetch") {
                RealRemoteConfig.shared.cache = createCacheMock()
                (RealRemoteConfig.shared.cache as? CacheMock)?.fetchCalled = false

                RealRemoteConfig.shared.fetchAndPollConfig()

                expect((RealRemoteConfig.shared.cache as? CacheMock)?.fetchCalled).to(equal(true))
            }
        }
        describe("fetchAndApplyConfig function") {
            it("calls config cache fetch") {
                RealRemoteConfig.shared.cache = createCacheMock()
                (RealRemoteConfig.shared.cache as? CacheMock)?.fetchCalled = false

                RealRemoteConfig.shared.fetchAndApplyConfig(completionHandler: { _ in })

                expect((RealRemoteConfig.shared.cache as? CacheMock)?.fetchCalled).to(equal(true))
            }
        }
    }
}
