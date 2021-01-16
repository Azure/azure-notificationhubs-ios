//
//  NotificationViewModel.swift
//  SampleNHAppSwiftUI2
//
//  Created by Hyounwoo Sung on 2021/01/16.
//

import UserNotifications
import WindowsAzureMessaging

class NotificationViewModel: NSObject, ObservableObject, MSNotificationHubDelegate, MSInstallationLifecycleDelegate, UNUserNotificationCenterDelegate {
    private var notificationPresentationCompletionHandler: Any?
    private var notificationResponseCompletionHandler: Any?

    @Published var installationId: String = MSNotificationHub.getInstallationId()
    @Published var pushChannel: String = MSNotificationHub.getPushChannel()
    @Published var items = [MSNotificationHubMessage]()

    let messageReceived = NotificationCenter.default
                .publisher(for: NSNotification.Name("MessageReceived"))

    let messageTapped = NotificationCenter.default
                .publisher(for: NSNotification.Name("MessageTapped"))

    override init() {
        super.init()

        if let path = Bundle.main.path(forResource: "DevSettings", ofType: "plist") {
            if let configValues = NSDictionary(contentsOfFile: path) {
                let connectionString = configValues["CONNECTION_STRING"] as? String
                let hubName = configValues["HUB_NAME"] as? String

                if (!(connectionString ?? "").isEmpty && !(hubName ?? "").isEmpty)
                {
                    MSNotificationHub.setLifecycleDelegate(self)
                    UNUserNotificationCenter.current().delegate = self;
                    MSNotificationHub.setDelegate(self)
                    MSNotificationHub.start(connectionString: connectionString!, hubName: hubName!)

                    addTags()
                }
            }
        }
    }

    func getPlistInfo(resourceName: String, key: String) -> String {
        guard let value = Bundle.main.path(forResource: resourceName, ofType: "plist") else {
            return ""
        }
        return value
    }

    func addTags() {
        // Get language and country code for common tag values
        let language = Bundle.main.preferredLocalizations.first ?? "<undefined>"
        let countryCode = NSLocale.current.regionCode ?? "<undefined>"

        // Create tags with type_value format
        let languageTag = "language_" + language
        let countryCodeTag = "country_" + countryCode

        MSNotificationHub.addTags([languageTag, countryCodeTag])
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.notificationPresentationCompletionHandler = completionHandler;
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.notificationResponseCompletionHandler = completionHandler;
    }

    func notificationHub(_ notificationHub: MSNotificationHub, didSave installation: MSInstallation) {
        DispatchQueue.main.async {
            self.installationId = installation.installationId
            self.pushChannel = installation.pushChannel
        }
    }

    func notificationHub(_ notificationHub: MSNotificationHub!, didReceivePushNotification message: MSNotificationHubMessage!) {

        let userInfo = ["message": message!]

        // Append receivedPushNotification message to self.items
        self.items.append(message)

        if (notificationResponseCompletionHandler != nil) {
            NSLog("Tapped Notification")
            NotificationCenter.default.post(name: NSNotification.Name("MessageTapped"), object: nil, userInfo: userInfo)
        } else {
            NSLog("Notification received in the foreground")
            NotificationCenter.default.post(name: NSNotification.Name("MessageReceived"), object: nil, userInfo: userInfo)
        }

        // Call notification completion handlers.
        if (notificationResponseCompletionHandler != nil) {
            (notificationResponseCompletionHandler as! () -> Void)()
            notificationResponseCompletionHandler = nil
        }
        if (notificationPresentationCompletionHandler != nil) {
            (notificationPresentationCompletionHandler as! (UNNotificationPresentationOptions) -> Void)([])
            notificationPresentationCompletionHandler = nil
        }
    }

}
