import UIKit
import Realm
import RealmSwift
import iDevNetwork
import iDevCore
import iDevData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    /// This should only be accessed on the main thread.
    fileprivate lazy var realm: Realm = {
        // swiftlint:disable force_try
        let realm = try! Realm()
        // swiftlint:enable force_try
        return realm
    }()
    
    fileprivate var authenticationViewController: AuthenticationViewController?

    fileprivate var appLog: iDevLogger!

    // MARK: UIApplicationDelegate
    // ====================================
    // UIApplicationDelegate
    // ====================================
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        configureLogging()
        
        let fm = FileManager()
        let libraryDirectory = try! fm.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        logInfo("Library Directory: \(libraryDirectory)")
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        if let nav = self.window?.rootViewController as? UINavigationController {
            authenticationViewController = nav.topViewController as? AuthenticationViewController
            
            authenticationViewController?.realm = realm
        }
        return true
    }
}

// MARK: Private/Convenience
// ====================================
// Private/Convenience
// ====================================
private extension AppDelegate {
    func configureLogging() {
        appLog = iDevLogger()
        appLog.install()
        
        logVerbose("Logging initialized.")
    }
}
