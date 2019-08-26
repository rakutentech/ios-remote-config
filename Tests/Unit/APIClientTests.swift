import Quick
import Nimble
@testable import RRemoteConfig

class APIClientSpec: QuickSpec {
    struct TestStruct: Parsable, Equatable {
        let foo: [String: String]

        init?(data: Data) {
            guard let foo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
                return nil
            }
            self.foo = foo
        }
    }
    override func spec() {
        describe("send function") {
            class SessionMock: SessionProtocol {
                var jsonObj: [String: Any]?
                var serverErrorCode: Int?
                var error: NSError?

                func startTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                    let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: serverErrorCode ?? 0, httpVersion: "1", headerFields: nil)
                    var data: Data?
                    if let json = jsonObj {
                        data = try? JSONSerialization.data(withJSONObject: json, options: [])
                    }
                    completionHandler(data, response, error)
                }

                init(json: [String: Any]? = nil, statusCode: Int = 200, error: NSError? = nil) {
                    self.jsonObj = json
                    self.serverErrorCode = statusCode
                    self.error = error
                }
            }
            context("when network response contains valid result json") {
                var testResult: TestStruct?

                it("will pass a result to completion handler with expected value") {
                    let sessionMock = SessionMock(json: ["foo": "bar"])
                    let jsonData = (try? JSONSerialization.data(withJSONObject: ["foo": "bar"], options: []))!
                    APIClient(session: sessionMock).send(request: URLRequest(url: URL(string: "https://test.com")!), parser: TestStruct.self, completionHandler: {(result) in
                        switch result {
                        case .success(let response):
                            testResult = (response.object as? TestStruct)!
                        case .failure:
                            break
                        }
                    })

                    expect(testResult).toEventually(equal(TestStruct(data: jsonData)), timeout: 2)
                }
            }
            context("when network response contains valid error json") {
                var testError: NSError = NSError.init(domain: "Test", code: 0, userInfo: nil)

                it("will pass an error to completion handler with expected code") {
                    let sessionMock = SessionMock(json: ["code": 1, "message": "error message"])
                    APIClient(session: sessionMock).send(request: URLRequest(url: URL(string: "https://test.com")!), parser: TestStruct.self, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })

                    expect(testError.code).toEventually(equal(1), timeout: 2)
                }

                it("will pass an error to completion handler with expected message") {
                    let sessionMock = SessionMock(json: ["code": 1, "message": "error message"])
                    APIClient(session: sessionMock).send(request: URLRequest(url: URL(string: "https://test.com")!), parser: TestStruct.self, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })

                    expect(testError.localizedDescription).toEventually(equal("error message"), timeout: 2)
                }
            }
            context("when network response contains json that doesn't match our models") {
                it("will pass a non-nil error to completion handler") {
                    var testError: NSError = NSError.init(domain: "Test", code: 0, userInfo: nil)
                    let sessionMock = SessionMock(json: ["foo": "bar"])
                    APIClient(session: sessionMock).send(request: URLRequest(url: URL(string: "https://test.com")!), parser: TestStruct.self, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })

                    expect(testError).toEventually(beAnInstanceOf(NSError.self), timeout: 2)
                }
            }
            context("when network response doesn't contain json data") {
                var testError: NSError = NSError.init(domain: "Test", code: 0, userInfo: nil)

                it("will pass an error with code set to server status code to completion handler and error is nil") {
                    let sessionMock = SessionMock(json: nil, statusCode: 400)
                    APIClient(session: sessionMock).send(request: URLRequest(url: URL(string: "https://test.com")!), parser: TestStruct.self, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })

                    expect(testError.code).toEventually(equal(400), timeout: 2)
                }

                it("will pass any system error to completion handler even when response received") {
                    let sessionMock = SessionMock(json: nil, error: NSError(domain: "Test", code: 123, userInfo: nil))
                    APIClient(session: sessionMock).send(request: URLRequest(url: URL(string: "https://test.com")!), parser: TestStruct.self, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })

                    expect(testError).toEventually(equal(sessionMock.error), timeout: 2)
                }
            }
        }
    }
}
