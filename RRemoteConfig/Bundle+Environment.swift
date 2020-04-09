extension Bundle: EnvironmentSetupProtocol {
    var valueNotFound: String {
        return "NONE"
    }

    func osVersion() -> String {
        return UIDevice.current.systemVersion
    }

    func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

    func sdkName() -> String {
        return "Remote Config"
    }

    func sdkVersion() -> String {
        return Bundle(for: Environment.self).value(for: "CFBundleShortVersionString") ?? self.valueNotFound
    }

    func value(for key: String) -> String? {
        return self.object(forInfoDictionaryKey: key) as? String
    }

    func languageCode() -> String? {
        // Use the device's preferred languages rather than Locale.current
        // because 'current' depends on the languages an app has been localized into
        guard let language = Locale.preferredLanguages.first else {
            return Locale.current.languageCode
        }
        return Locale(identifier: language).languageCode
    }

    func countryCode() -> String? {
        return Locale.current.regionCode
    }
}
