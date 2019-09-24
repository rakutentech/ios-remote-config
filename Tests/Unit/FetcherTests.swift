import Quick
import Nimble
@testable import RRemoteConfig

class FetcherSpec: QuickSpec {
    override func spec() {
        describe("config fetch function") {
            let bundleMock = BundleMock()

            // Fetcher will just return if endpoint or appid are invalid
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

                fetcher.fetchConfig(completionHandler: {_ in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["apiKey"]).toEventually(equal("ras-my-subkey"))
            }

            it("will add the If-None-Match header if Etag was saved") {
                let apiClientMock = APIClientMock()
                UserDefaults.standard.set("my-etag", forKey: Environment.etagKey)
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["If-None-Match"]).toEventually(equal("my-etag"))
            }

            it("will not add the If-None-Match header if Etag cannot be found") {
                let apiClientMock = APIClientMock()
                UserDefaults.standard.set(nil, forKey: Environment.etagKey)
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["If-None-Match"]).toEventually(beNil())
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

            it("will add the OS version header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockOsVersion = "os foo"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchConfig(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-os-version"]).toEventually(equal("os foo"))
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

            context("when valid config model is received as the result from the api client") {
                let dataString = #"{"body":{"foo":"bar"},"keyId":"fooKey"}"#

                it("will set the config dictionary in the result passed to the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    apiClientMock.data = dataString.data(using: .utf8)
                    let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetchConfig(completionHandler: { (result) in
                        testResult = result
                    })

                    expect((testResult as? ConfigModel)?.config).toEventually(equal(["foo": "bar"]))
                }

                it("will set the signature in the result passed to the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    apiClientMock.data = dataString.data(using: .utf8)
                    apiClientMock.headers = ["Signature": "a-sig"]
                    let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetchConfig(completionHandler: { (result) in
                        testResult = result
                    })

                    expect((testResult as? ConfigModel)?.signature).toEventually(equal("a-sig"))
                }

                it("will save the etag to user defaults") {
                    UserDefaults.standard.removeObject(forKey: Environment.etagKey)
                    let apiClientMock = APIClientMock()
                    let env = Environment()
                    apiClientMock.data = dataString.data(using: .utf8)
                    apiClientMock.headers = ["Etag": "an-etag"]
                    let fetcher = Fetcher(client: apiClientMock, environment: env)

                    fetcher.fetchConfig(completionHandler: { (_) in
                    })

                    expect(env.etag).toEventually(equal("an-etag"), timeout: 2)
                }
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
        describe("key fetch function") {
            let bundleMock = BundleMock()

            // Fetcher will just return if endpoint or appid are invalid
            // so need to set something valid
            bundleMock.mockEndpoint = "https://www.endpoint.com"
            bundleMock.mockAppId = "foo-id"

            it("will call the send function of the api client passing in a request") {
                let apiClientMock = APIClientMock()
                let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request).toEventually(beAnInstanceOf(URLRequest.self))
            }

            it("will pass nil in the completion handler when environment is incorrectly configured") {
                var testResult: Any?
                bundleMock.mockEndpoint = "12345"
                let fetcher = Fetcher(client: APIClientMock(), environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (result) in
                    testResult = result
                })

                expect(testResult).to(beNil())
            }

            it("will prefix ras- to the request's subscription key header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockSubKey = "my-subkey"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })
            expect(apiClientMock.request?.allHTTPHeaderFields!["apiKey"]).toEventually(equal("ras-my-subkey"))
            }

            it("will add the If-None-Match header if Etag was saved") {
                let apiClientMock = APIClientMock()
                UserDefaults.standard.set("my-etag", forKey: Environment.etagKey)
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["If-None-Match"]).toEventually(equal("my-etag"))
            }

            it("will not add the If-None-Match header if Etag cannot be found") {
                let apiClientMock = APIClientMock()
                UserDefaults.standard.set(nil, forKey: Environment.etagKey)
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["If-None-Match"]).toEventually(beNil())
            }

            it("will add the app id header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockAppId = "my-app-id"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-app-id"]).toEventually(equal("my-app-id"))
            }

            it("will add the app name header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockAppName = "my-app-name"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-app-name"]).toEventually(equal("my-app-name"))
            }

            it("will add the app version header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockAppVersion = "100.1.0"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-app-version"]).toEventually(equal("100.1.0"))
            }

            it("will add the device model header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockDeviceModel = "a-model"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-device-model"]).toEventually(equal("a-model"))
            }

            it("will add the OS version header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockOsVersion = "os foo"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-os-version"]).toEventually(equal("os foo"))
            }

            it("will add the sdk name header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockSdkName = "my sdk"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-sdk-name"]).toEventually(equal("my sdk"))
            }

            it("will add the sdk version header") {
                let apiClientMock = APIClientMock()
                bundleMock.mockSdkVersion = "1.2.3"
                let fetcher = Fetcher(client: apiClientMock, environment: Environment(bundle: bundleMock))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["ras-sdk-version"]).toEventually(equal("1.2.3"))
            }

            context("when valid key model is received as the result from the api client") {
                it("will set the config dictionary in the result passed to the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    let dataString = """
                        {"id":"foo","key":"myKeyId","createdAt":"boo"}
                        """
                    apiClientMock.data = dataString.data(using: .utf8)
                    let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetchKey(with: "key", completionHandler: { (result) in
                        testResult = result
                    })

                    expect((testResult as? KeyModel)?.key).toEventually(equal("myKeyId"))
                }
            }

            context("when error is received as the result from the api client") {
                it("will pass nil in the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    apiClientMock.error = NSError(domain: "Test", code: 123, userInfo: nil)
                    let fetcher = Fetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetchKey(with: "key", completionHandler: { (result) in
                        testResult = result
                    })

                    expect(testResult).to(beNil())
                }
            }
        }
    }
}
