import UIKit
import RRemoteConfig

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkConfig()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(5)) {
            self.checkConfig()
        }
        return true
    }

    func checkConfig() {
        let val1 = RemoteConfig.getString(key: "foo", fallback: "nope")
        print("key: foo, fallback: nope -> val1: \(val1)")
        let val2 = RemoteConfig.getString(key: "key", fallback: "oops")
        print("key: key, fallback: oops -> val2: \(val2)")
    }
}
