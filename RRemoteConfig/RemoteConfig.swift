/// Remote Config public API functions
@objc public class RemoteConfig: NSObject {

    /// Get a string from cached config.
    /// If the key does not exist, fallback will be returned.
    ///
    /// - Parameters:
    ///   - key: String key name
    ///   - fallback: String fallback value returned when key does not exist
    /// - Returns: String value for the specified key
    @objc public class func getString(key: String, fallback: String) -> String {
        return RealRemoteConfig.shared.getString(key, fallback)
    }

    /// Get a boolean from cached config.
    /// If the key does not exist, fallback will be returned.
    ///
    /// - Parameters:
    ///   - key: String key name
    ///   - fallback: Boolean fallback value returned when key does not exist
    /// - Returns: Boolean value for the specified key
    @objc public class func getBoolean(key: String, fallback: Bool) -> Bool {
        return RealRemoteConfig.shared.getBoolean(key, fallback)
    }

    /// Get a number from cached config.
    /// If the key does not exist, or cached value cannot be converted to
    /// number, fallback will be returned.
    ///
    /// - Parameters:
    ///   - key: String key name
    ///   - fallback: Number fallback value returned when key does not exist or
    ///   cached value cannot be converted to number
    /// - Returns: Number value for specified key
    @objc public class func getNumber(key: String, fallback: NSNumber) -> NSNumber {
        return RealRemoteConfig.shared.getNumber(key, fallback)
    }

    /// Get cached config.
    ///
    /// - Returns: String dictionary of config contents
    @objc public class func getConfig() -> [String: String] {
        return RealRemoteConfig.shared.getConfig()
    }
}
