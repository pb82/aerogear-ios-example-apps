import AGSAuth
import AGSSync
import Alamofire
import IQKeyboardManagerSwift
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true

        // create the authentication config
        let authenticationConfig = AuthenticationConfig(redirectURL: "memeolist://callback")
        do {
            try AgsAuth.instance.configure(authConfig: authenticationConfig)
            if let transport = AgsSync.instance.transport {
                transport.headerProvider = AgsAuth.instance.getAuthHeaderProvider()
            }
            guard let _ = try! AgsAuth.instance.currentUser() else {
                let rootViewController = LoginViewController()
                window?.rootViewController = UINavigationController(rootViewController: rootViewController)
                window?.makeKeyAndVisible()
                return true
            }
        } catch AgsAuth.Errors.noServiceConfigurationFound {
            print("No Auth configuration found.")
        } catch {
            print("Some other error.")
            return false
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        do {
            return try AgsAuth.instance.resumeAuth(url: url as URL)
        } catch AgsAuth.Errors.serviceNotConfigured {
            print("AeroGear auth service is not configured")
        } catch {
            fatalError("Unexpected error: \(error).")
        }
        return false
    }
}
