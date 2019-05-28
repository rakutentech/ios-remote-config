import UIKit
import RRemoteConfig

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let val1 = RemoteConfig.getString(key: "foo", fallback: "bar")
        print("key: foo, fallback: bar -> val1: \(val1)")
        let val2 = RemoteConfig.getString(key: "asaa", fallback: "oops")
        print("key: asaa, fallback: oops -> val2: \(val2)")
        return true
    }
}
