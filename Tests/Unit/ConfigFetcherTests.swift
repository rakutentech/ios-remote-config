import Quick
import Nimble
@testable import RRemoteConfig

class ConfigFetcherSpec: QuickSpec {
    class APIClientMock: APIClient {
        var dictionary: [String: String]?
        var error: Error?
        var request: URLRequest?
        override func send<T>(request: URLRequest, decodeAs: T.Type, completionHandler: @escaping (Result<Any, Error>) -> Void) where T: Decodable {
            self.request = request

            guard let dictionary = dictionary else {
                return completionHandler(.failure(error ?? NSError(domain: "Test", code: 0, userInfo: nil)))
            }
            return completionHandler(.success(ConfigModel(config: dictionary)))
        }
    }
    class MockBundleInvalid: EnvironmentSetupProtocol {
        func value(for key: String) -> String? {
            return nil
        }
    }
    override func spec() {
        describe("fetch function") {
            it("will call the send function of the api client passing in a request") {
                let apiClientMock = APIClientMock()
                let fetcher = ConfigFetcher(client: apiClientMock, environment: Environment())

                fetcher.fetch(completionHandler: { (_) in
                })

                expect(apiClientMock.request).toEventually(beAnInstanceOf(URLRequest.self))
            }
            context("when valid config model is received as the result from the api client") {
                it("will pass the config in the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    apiClientMock.dictionary = ["foo": "bar"]
                    let fetcher = ConfigFetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetch(completionHandler: { (result) in
                        testResult = result
                    })

                    expect((testResult as? ConfigModel)?.config).toEventually(equal(["foo": "bar"]))
                }
            }
            it("will pass nil in the completion handler when environment is incorrectly configured") {
                var testResult: Any?
                let fetcher = ConfigFetcher(client: APIClientMock(), environment: Environment(bundle: MockBundleInvalid()))

                fetcher.fetch(completionHandler: { (result) in
                    testResult = result
                })

                expect(testResult).to(beNil())
            }

            it("will prefix ras- to the request's subscription key header") {
                let apiClientMock = APIClientMock()
                let fetcher = ConfigFetcher(client: apiClientMock, environment: Environment())

                fetcher.fetch(completionHandler: { (_) in
                })

                expect(apiClientMock.request?.allHTTPHeaderFields!["apiKey"]).toEventually(contain("ras-"))
            }
            context("when error is received as the result from the api client") {
                it("will pass nil in the completion handler") {
                    var testResult: Any?
                    let apiClientMock = APIClientMock()
                    apiClientMock.error = NSError(domain: "Test", code: 123, userInfo: nil)
                    let fetcher = ConfigFetcher(client: apiClientMock, environment: Environment())

                    fetcher.fetch(completionHandler: { (result) in
                        testResult = result
                    })

                    expect(testResult).to(beNil())
                }
            }
        }
    }
}
