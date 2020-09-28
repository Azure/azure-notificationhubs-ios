//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import Cocoa
import WindowsAzureMessaging

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MSNotificationHubDelegate {

    var connectionString: String?
    var hubName: String?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let path = Bundle.main.path(forResource: "DevSettings", ofType: "plist") {
            if let configValues = NSDictionary(contentsOfFile: path) {
                connectionString = configValues["CONNECTION_STRING"] as? String
                hubName = configValues["HUB_NAME"] as? String
                
                MSNotificationHub.setDelegate(self)
                MSNotificationHub.start(connectionString: connectionString!, hubName: hubName!)
                
                return
            }
        }
        
        NSLog("Please setup CONNECTION_STRING and HUB_NAME in DevSettings.plist and restart application")
        
        exit(-1)
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub!, didReceivePushNotification message: MSNotificationHubMessage!) {
    
        let userInfo = ["message": message!]
        NotificationCenter.default.post(name: NSNotification.Name("MessageReceived"), object: nil, userInfo: userInfo)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

