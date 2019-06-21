public class RemoteConfig {

    public class func getString(key: String, fallback: String) -> String {
        return RealRemoteConfig.shared.getString(key, fallback)
    }
}
