
import UIKit
import CocoaLumberjack
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var container: NSPersistentContainer!

    
    private func createContainer(completion: @escaping (NSPersistentContainer) -> ()) {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { _, error in
            guard error == nil else { fatalError("Failed to load store") }
            DispatchQueue.main.async {
                completion(container)
            }
        })
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        createContainer { (container) in
            self.container = container
            let arrayOfVC = (self.window?.rootViewController as? UITabBarController)?.viewControllers
            let nc = arrayOfVC![0] as? UINavigationController
            let vc = nc?.topViewController as? MyTableViewController
            vc?.backgroundContext = container.newBackgroundContext()
            vc?.context = container.viewContext
            
            
//            if let tbc = self.window?.rootViewController as? UITabBarController, let nc = tbc.navigationController as? UINavigationController, let vc = nc.topViewController as? MyTableViewController {
//
//                print("sucsses")
//                print()
//            }
//
//            if let nc = self.window?.rootViewController as? UINavigationController, let vc = nc.topViewController as? MyTableViewController {
//                vc.context = container.viewContext
//                vc.backgroundContext = container.newBackgroundContext()
//            } else {
//                print("NO")
//            }
        }
        
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

