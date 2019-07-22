@objc public class RemoteConfig: NSObject {

    @objc public class func getString(key: String, fallback: String) -> String {
        return RealRemoteConfig.shared.getString(key, fallback)
    }
}
