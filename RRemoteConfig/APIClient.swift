protocol SessionProtocol {
    func startTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: SessionProtocol {
    func startTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }.resume()
    }
}

internal struct Response {
    let object: Parsable
    let httpResponse: HTTPURLResponse

    init(_ object: Parsable, _ response: HTTPURLResponse) {
        self.object = object
        self.httpResponse = response
    }
}

internal class APIClient {
    let session: SessionProtocol

    init(session: SessionProtocol = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }

    func send<T>(request: URLRequest, parser: T.Type, completionHandler: @escaping (Result<Response, Error>) -> Void) where T: Parsable {

        session.startTask(with: request) { (data, response, error) in

            if let httpResponse = response as? HTTPURLResponse,
                let payloadData = data,
                let object = parser.init(data: payloadData) {
                return completionHandler(.success(Response(object, httpResponse)))
            }

            // Error handling:
            // first, check for OS-level error
            // then, for a decodable server error object
            // then if no server error object is found, handle as unspecified error
            if let err = error {
                return completionHandler(.failure(err))
            }

            do {
                let errorModel = try JSONDecoder().decode(APIError.self, from: data ?? Data())
                return completionHandler(.failure(NSError.serverError(code: errorModel.code, message: errorModel.message)))
            } catch {
                let serverError = NSError.serverError(code: (response as? HTTPURLResponse)?.statusCode ?? 0, message: "Unspecified server error occurred")
                Logger.e("Error: \(String(describing: serverError))")
                return completionHandler(.failure(serverError))
            }
        }
    }
}

struct APIError: Decodable, Equatable {
    let code: Int
    let message: String
}

fileprivate extension NSError {
    class func serverError(code: Int, message: String) -> NSError {
        return NSError(domain: "Remote Config Server", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
