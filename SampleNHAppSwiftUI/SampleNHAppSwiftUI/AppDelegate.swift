//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import UIKit
import WindowsAzureMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var connectionString: String?
    var hubName: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let path = Bundle.main.path(forResource: "DevSettings", ofType: "plist") {
            if let configValues = NSDictionary(contentsOfFile: path) {
                connectionString = configValues["CONNECTION_STRING"] as? String
                hubName = configValues["HUB_NAME"] as? String
                
                if (!(connectionString ?? "").isEmpty && !(hubName ?? "").isEmpty)
                {
                    MSNotificationHub.start(connectionString: connectionString!, hubName: hubName!)
                    
                    addTags()
                    
                    return true
                }
            }
        }
        
        NSLog("Please setup CONNECTION_STRING and HUB_NAME in DevSettings.plist and restart application")
        
        exit(-1)
    }
    
    // Adds some basic tags such as language and country
    func addTags() {
        // Get language and country code for common tag values
        let language = Bundle.main.preferredLocalizations.first!
        let countryCode = NSLocale.current.regionCode!

        // Create tags with type_value format
        let languageTag = "language_" + language
        let countryCodeTag = "country_" + countryCode

        MSNotificationHub.addTags([languageTag, countryCodeTag])
        MSNotificationHub.addTag("com.example.SampleNHAppSwiftUI:1.0.0");
    }

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

}
