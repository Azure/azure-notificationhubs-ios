//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import Cocoa
import WindowsAzureMessaging

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var connectionString: String?
    var hubName: String?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let path = Bundle.main.path(forResource: "DevSettings", ofType: "plist") {
            if let configValues = NSDictionary(contentsOfFile: path) {
                connectionString = configValues["CONNECTION_STRING"] as? String
                hubName = configValues["HUB_NAME"] as? String
            }
        }
        
        MSNotificationHub.start(connectionString: connectionString!, hubName: hubName!)
        MSNotificationHub.addTag("userAgent:com.microsoft.SampleNHAppSwift:1.1")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

