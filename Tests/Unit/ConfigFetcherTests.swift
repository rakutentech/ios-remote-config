import Quick
import Nimble
@testable import RRemoteConfig

class ConfigFetcherSpec: QuickSpec {
    class APIClientMock: APIClient {
        var dictionary: [String: String]?
        var error: Error?
        var request: URLRequest?
        override func send<T>(request: URLRequest, decodeAs: T.Type, completionHandler: @escaping (Result<Any, Error>, HTTPURLResponse?) -> Void) where T: Decodable {
            self.request = request

            guard let dictionary = dictionary else {
                return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)), nil)
            }
            return completionHandler(.success(ConfigModel(config: dictionary)), HTTPURLResponse())
        }
    }
    override func spec() {
        describe("fetch function") {
            let bundleMock = BundleMock()

            // Fetcher will just return if these are invalid
            // so need to set something valid
            bundleMock.mockEndpoint = "https://www.endpoint.com"
            bundleMock.mockAppId = "foo-id"

            it("will call the send function of the api client passing in a request") {
                let apiClientMock = APIClientMock()
                let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request).toEventually(beAnInstanceOf(URLRequest.self))
            }
            context("when valid config model is received as the result from the api client") {
                it("will pass the config in the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    apiClientMock.dictionary = ["foo": "bar"]
                    let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetchConfig(completionHandler: { (result) in
                        testResult = result
                    })

                    expect((testResult as? ConfigModel)?.config).toEventually(equal(["foo": "bar"]))
                }
            }
            it("will pass nil in the completion handler when environment is incorrectly configured") {
                var testResult: Any?
                bundleMock.mockEndpoint = "12345"
                let fetcher = Fetcher(client: APIClientMock(), environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (result) in
                    testResult = result
                })

                expect(testResult).to(beNil())
            }

            it("will prefix ras- to the request's subscription key header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockSubKey = "my-subkey"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                    print(apiClientMock.request?.allHTTPHeaderFields)
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["apiKey"]).toEventually(equal("ras-my-subkey"))
            }

            it("will add the app id header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockAppId = "my-app-id"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-app-id"]).toEventually(equal("my-app-id"))
            }

            it("will add the app name header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockAppName = "my-app-name"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-app-name"]).toEventually(equal("my-app-name"))
            }

            it("will add the app version header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockAppVersion = "100.1.0"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-app-version"]).toEventually(equal("100.1.0"))
            }

            it("will add the device model header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockDeviceModel = "a-model"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-device-model"]).toEventually(equal("a-model"))
            }

            it("will add the device OS version header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockOsVersion = "os foo"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-device-version"]).toEventually(equal("os foo"))
            }

            it("will add the sdk name header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockSdkName = "my sdk"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-sdk-name"]).toEventually(equal("my sdk"))
            }

            it("will add the sdk version header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockSdkVersion = "1.2.3"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-sdk-version"]).toEventually(equal("1.2.3"))
            }

            context("when error is received as the result from the api client") {
                it("will pass nil in the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    apiClientMock.error = NSError(domain: "Test", code: 123, userInfo: nil)
                    let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetchConfig(completionHandler: { (result) in
                        testResult = result
                    })

                    expect(testResult).to(beNil())
                }
            }
        }
    }
}
