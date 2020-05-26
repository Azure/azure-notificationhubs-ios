//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import UIKit
import WindowsAzureMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MSInstallationEnrichmentDelegate, MSInstallationManagementDelegate, MSInstallationLifecycleDelegate {

    var connectionString: String?
    var hubName: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let path = Bundle.main.path(forResource: "devsettings", ofType: "plist") {
            if let configValues = NSDictionary(contentsOfFile: path) {
                connectionString = configValues["connectionString"] as? String
                hubName = configValues["hubName"] as? String
            }
        }
        
        MSNotificationHub.setEnrichmentDelegate(self)
        MSNotificationHub.setManagementDelegate(self)
        MSNotificationHub.setLifecycleDelegate(self)
        MSNotificationHub.initWithConnectionString(connectionString!, hubName: hubName!)
        MSNotificationHub.addTag("userAgent:com.example.nhubsample-refresh:1.0")
        
        return true
    }

// Sample usage of MSInstallationManagementDelegate
//    func notificationHub(_ notificationHub: MSNotificationHub!, willUpsertInstallation installation: MSInstallation!, withCompletionHandler completionHandler:
//        @escaping (Bool) -> Void) {
//        NSLog("willUpsertInstallation");
//        completionHandler(false);
//    }

//    func notificationHub(_ notificationHub: MSNotificationHub!, willDeleteInstallation installationId: String {
//        NSLog("willDeleteInstallation");
//    }
    
// Sample usage of MSInstallationLifecycleDelegate
//    func notificationHub(_ notificationHub: MSNotificationHub!, didSaveInstallation installation: MSInstallation! {
//        NSLog("didSaveInstallation");
//    }
//    
//    func notificationHub(_ notificationHub: MSNotificationHub!, didFailToSaveInstallationWithError error: NSError? {
//        NSLog("didSaveInstallation");
//    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub!, willEnrichInstallation installation: MSInstallation!) {
        NSLog("willEnrichInstallation");
    }

}
