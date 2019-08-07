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

            it("will return a config url with format <endpoint/app/{app-id}/config>") {
                let mockBundle = BundleMock()
                mockBundle.mockEndpoint = "https://endpoint.com"
                mockBundle.mockAppId = "12345"

                let environment = Environment(bundle: mockBundle)

                expect(environment.configUrl?.absoluteString).to(equal("https://endpoint.com/app/12345/config"))
            }

            it("will return a key url with format <endpoint/keys/{key-id}>") {
                let mockBundle = BundleMock()
                mockBundle.mockEndpoint = "https://endpoint.com"

                let environment = Environment(bundle: mockBundle)

                expect(environment.keyUrl(with: "my-key")?.absoluteString).to(equal("https://endpoint.com/keys/my-key"))
            }

            it("has the expected subscription key") {
                let mockBundle = BundleMock()
                mockBundle.mockSubKey = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.subscriptionKey).to(contain("foo"))
            }

            it("has the expected app id") {
                let mockBundle = BundleMock()
                mockBundle.mockAppId = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.appId).to(equal("foo"))
            }

            it("has the expected app name") {
                let mockBundle = BundleMock()
                mockBundle.mockAppName = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.appName).to(equal("foo"))
            }

            it("has the expected app version") {
                let mockBundle = BundleMock()
                mockBundle.mockAppVersion = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.appVersion).to(equal("foo"))
            }

            it("has the expected subscription key") {
                let mockBundle = BundleMock()
                mockBundle.mockSubKey = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.subscriptionKey).to(contain("foo"))
            }

            it("has the expected OS version") {
                let mockBundle = BundleMock()
                mockBundle.mockOsVersion = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.deviceOsVersion).to(equal("foo"))
            }

            it("has the expected device model") {
                let mockBundle = BundleMock()
                mockBundle.mockDeviceModel = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.deviceModel).to(equal("foo"))
            }

            it("has the expected sdk name") {
                let mockBundle = BundleMock()
                mockBundle.mockSdkName = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.sdkName).to(equal("foo"))
            }

            it("has the expected sdk version") {
                let mockBundle = BundleMock()
                mockBundle.mockSdkVersion = "foo"

                let environment = Environment(bundle: mockBundle)

                expect(environment.sdkVersion).to(equal("foo"))
            }
        }
        context("when bundle does not have valid key values") {
            let mockBundleInvalid = BundleMock()
            mockBundleInvalid.mockEndpoint = nil
            mockBundleInvalid.mockNotFound = "not-found"
            let environment = Environment(bundle: mockBundleInvalid)

            it("will return a nil config url") {
                expect(environment.configUrl?.absoluteString).to(beNil())
            }

            it("will return a nil keys url") {
                expect(environment.keyUrl(with: "my-key")?.absoluteString).to(beNil())
            }

            it("will return the 'not found' value when subscription key can't be read") {
                expect(environment.subscriptionKey).to(equal(mockBundleInvalid.valueNotFound))
            }

            it("will return the 'not found' value when app id can't be read") {
                expect(environment.appId).to(equal(mockBundleInvalid.valueNotFound))
            }

            it("will return the 'not found' value when app name can't be read") {
                expect(environment.appName).to(equal(mockBundleInvalid.valueNotFound))
            }

            it("will return the 'not found' value when app version can't be read") {
                expect(environment.appVersion).to(equal(mockBundleInvalid.valueNotFound))
            }

            it("will return the 'not found' value when device model can't be read") {
                expect(environment.deviceModel).to(equal(mockBundleInvalid.valueNotFound))
            }

            it("will return the 'not found' value when device os version can't be read") {
                expect(environment.deviceOsVersion).to(equal(mockBundleInvalid.valueNotFound))
            }

            it("will return the 'not found' value when sdk name can't be read") {
                expect(environment.sdkName).to(equal(mockBundleInvalid.valueNotFound))
            }

            it("will return the 'not found' value when sdk version can't be read") {
                expect(environment.sdkVersion).to(equal(mockBundleInvalid.valueNotFound))
            }
        }
    }
}
