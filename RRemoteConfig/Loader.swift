import Foundation

// Swift doesn't have load-time initialization so we need
// this proxy class that is called by LoaderObjC's `load`
// method.
public class Loader: NSObject {
    @objc public static func loadRemoteConfig() {
        RealRemoteConfig.shared.refreshConfig()
    }
}
