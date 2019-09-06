internal class Fetcher {
    let apiClient: APIClient
    let environment: Environment

    init(client: APIClient,
         environment: Environment) {
        self.apiClient = client
        self.environment = environment
    }

    // MARK: Fetch Config
    func fetchConfig(completionHandler: @escaping (ConfigModel?) -> Void) {
        guard let url = environment.configUrl else {
            return completionHandler(nil)
        }
        let configRequest = request(for: url)

        apiClient.send(request: configRequest, parser: ConfigModel.self) { (result) in
            switch result {
            case .success(let response):
                var config = response.object as? ConfigModel
                let headers = response.httpResponse.allHeaderFields as? [String: String]
                config?.signature = headers?["Signature"]
                self.environment.etag = headers?["Etag"]
                completionHandler(config)
            case .failure(let error):
                Logger.e("Config fetch \(String(describing: configRequest.url)) error occurred: \(error.localizedDescription)")
                completionHandler(nil)
            }
        }
    }

    // MARK: Fetch Key
    func fetchKey(with keyId: String, completionHandler: @escaping (KeyModel?) -> Void) {
        guard let url = environment.keyUrl(with: keyId) else {
            return completionHandler(nil)
        }
        let keyRequest = request(for: url)

        apiClient.send(request: keyRequest, parser: KeyModel.self) { (result) in
            switch result {
            case .success(let response):
                completionHandler(response.object as? KeyModel)
            case .failure(let error):
                Logger.e("Key fetch \(String(describing: keyRequest.url)) error occurred: \(error.localizedDescription)")
                completionHandler(nil)
            }
        }
    }

    fileprivate func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setHeaders(from: environment)
        return request
    }
}
