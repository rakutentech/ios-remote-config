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
}
