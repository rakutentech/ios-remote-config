extension URLRequest {
    mutating func setExtraHeaders(from environment: Environment) {
        self.addHeader("ras-app-id", environment.appId)
        self.addHeader("ras-device-model", environment.deviceModel)
        self.addHeader("ras-device-version", environment.deviceOsVersion)
        self.addHeader("ras-sdk-name", environment.sdkName)
        self.addHeader("ras-sdk-version", environment.sdkVersion)
        self.addHeader("ras-app-name", environment.appName)
        self.addHeader("ras-app-version", environment.appVersion)
    }

    mutating func addHeader(_ name: String, _ value: String) {
        if value.count > 0 {
            self.addValue(value, forHTTPHeaderField: name)
        }
    }
}
