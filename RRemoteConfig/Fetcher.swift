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
        var request = URLRequest(url: url)
        request.setConfigHeaders(from: environment)

        apiClient.send(request: request, parser: ConfigModel.self) { (result) in
            switch result {
            case .success(let response):
                var config = response.object as? ConfigModel
                let headers = response.httpResponse.allHeaderFields as? [String: String]
                config?.signature = headers?["Signature"]
                self.environment.etag = headers?["Etag"]
                completionHandler(config)
            case .failure(let error):
                Logger.e("Config fetch \(String(describing: request.url)) error occurred: \(error.localizedDescription)")
                completionHandler(nil)
            }
        }
    }

    // MARK: Fetch Key
    func fetchKey(with keyId: String, completionHandler: @escaping (KeyModel?) -> Void) {
        guard let url = environment.keyUrl(with: keyId) else {
            return completionHandler(nil)
        }
        var request = URLRequest(url: url)
        request.addHeader("apiKey", "ras-\(environment.subscriptionKey)")

        apiClient.send(request: request, parser: KeyModel.self) { (result) in
            switch result {
            case .success(let response):
                completionHandler(response.object as? KeyModel)
            case .failure(let error):
                Logger.e("Key fetch \(String(describing: request.url)) error occurred: \(error.localizedDescription)")
                completionHandler(nil)
            }
        }
    }
}
