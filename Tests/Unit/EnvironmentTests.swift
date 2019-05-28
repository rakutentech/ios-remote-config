import Quick
import Nimble
@testable import RRemoteConfig

class EnvironmentSpec: QuickSpec {
    override func spec() {
        it("uses the main bundle when no bundle parameter is supplied") {
            let environment = Environment()
            let bundle = environment.bundle as? Bundle ?? Bundle(for: EnvironmentSpec.self)

            expect(bundle).to(equal(Bundle.main))
        }
        context("when bundle has valid key-values") {
            class MockBundleValid: EnvironmentSetupProtocol {
                var appId: String?
                var endpoint: String?
                var subKey: String?

                func value(for key: String) -> String? {
                    switch key {
                    case "RASApplicationIdentifier":
                        return appId
                    case "RRCConfigAPIEndpoint":
                        return endpoint
                    case "RASProjectSubscriptionKey":
                        return subKey
                    default:
                        return nil
                    }
                }
            }
            let mockBundle = MockBundleValid()
            let appId = "12345"
            let endpoint = "https://endpoint.com"
            let subKey = "ABCDE"
            it("will contain the app id in the url") {
                mockBundle.appId = appId
                mockBundle.endpoint = endpoint

                let environment = Environment(bundle: mockBundle)

                expect(environment.url?.absoluteString).to(contain(appId))
            }
            it("will contain the endpoint in the url") {
                mockBundle.endpoint = endpoint
                mockBundle.appId = appId

                let environment = Environment(bundle: mockBundle)

                expect(environment.url?.absoluteString).to(contain(endpoint))
            }
            it("has the expected subscription key") {
                mockBundle.subKey = subKey

                let environment = Environment(bundle: mockBundle)

                expect(environment.subscriptionKey).to(contain(subKey))
            }
        }
        context("when bundle does not have valid key values") {
            class MockBundleInvalid: EnvironmentSetupProtocol {
                var appId: String?
                var endpoint: String?
                var subKey: String?
                func value(for key: String) -> String? {
                    return nil
                }
            }
            let mockBundleInvalid = MockBundleInvalid()
            it("will return a nil url") {
                let environment = Environment(bundle: mockBundleInvalid)
                expect(environment.url?.absoluteString).to(beNil())
            }
            it("will return a nil subscription key") {
                let environment = Environment(bundle: mockBundleInvalid)

                expect(environment.subscriptionKey).to(beEmpty())
            }
        }
    }
}
