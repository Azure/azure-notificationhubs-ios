//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import Cocoa
import SwiftUI
import WindowsAzureMessaging

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MSNotificationHubDelegate, MSInstallationLifecycleDelegate {

    var window: NSWindow!
    
    var connectionString: String?
    var hubName: String?
    
    @ObservedObject var notifications: ObservableMessagesList = ObservableMessagesList(items: []);
    @ObservedObject var installation: ObservableInstallation = ObservableInstallation(installationId: MSNotificationHub.getInstallationId(), pushChannel: MSNotificationHub.getPushChannel())


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let path = Bundle.main.path(forResource: "DevSettings", ofType: "plist") {
            if let configValues = NSDictionary(contentsOfFile: path) {
                connectionString = configValues["CONNECTION_STRING"] as? String
                hubName = configValues["HUB_NAME"] as? String
                
                if (!(connectionString ?? "").isEmpty && !(hubName ?? "").isEmpty)
                {
                    MSNotificationHub.start(connectionString: connectionString!, hubName: hubName!)
                    
                    addTags()
                } else {
                    NSLog("Please setup CONNECTION_STRING and HUB_NAME in DevSettings.plist and restart application")
                    
                    exit(-1)
                }
            }
        }
        
        MSNotificationHub.setDelegate(self)
        MSNotificationHub.setLifecycleDelegate(self)
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(notifications: notifications, installation: installation)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
        MSNotificationHub.addTag("com.example.SampleNHAppMacSwiftUI:1.0.0");
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub!, didReceivePushNotification notification: MSNotificationHubMessage!) {
        
        NSLog("Received notification: %@; %@", notification.title ?? "<nil>", notification.body)
        
        self.notifications.items.append(notification)
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub, didSave installation: MSInstallation) {
        
        DispatchQueue.main.async {
            self.installation.installationId = installation.installationId
            self.installation.pushChannel = installation.pushChannel
        }
    }

}

