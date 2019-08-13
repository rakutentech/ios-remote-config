extension URLRequest {
    mutating func setConfigHeaders(from environment: Environment) {
        addHeader("ras-app-id", environment.appId)
        addHeader("ras-device-model", environment.deviceModel)
        addHeader("ras-device-version", environment.deviceOsVersion)
        addHeader("ras-sdk-name", environment.sdkName)
        addHeader("ras-sdk-version", environment.sdkVersion)
        addHeader("ras-app-name", environment.appName)
        addHeader("ras-app-version", environment.appVersion)
        addHeader("apiKey", "ras-\(environment.subscriptionKey)")

        // If the ETag of the requested server config matches this header
        // the server will respond with 304 Not Modified and the OS will
        // give us the cached response
        if let etag = environment.etag {
            addHeader("If-None-Match", etag)
        }
    }

    mutating func addHeader(_ name: String, _ value: String) {
        if value.count > 0 {
            addValue(value, forHTTPHeaderField: name)
        }
    }
}
