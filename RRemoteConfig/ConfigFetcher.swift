internal class ConfigFetcher {
    let apiClient: APIClient
    let environment: Environment

    init(client: APIClient,
         environment: Environment) {
        self.apiClient = client
        self.environment = environment
    }

    func fetch(completionHandler: @escaping (ConfigModel?) -> Void) {
        guard let url = environment.url else {
            return completionHandler(nil)
        }
        var request = URLRequest(url: url)
        request.addValue("ras-\(environment.subscriptionKey)", forHTTPHeaderField: "apiKey")
        apiClient.send(request: request, decodeAs: ConfigModel.self) { (result) in
            switch result {
            case .success(let config):
                completionHandler(config as? ConfigModel)
            case .failure(let error):
                print("Error: ", error)
                completionHandler(nil)
            }
        }
    }
}
