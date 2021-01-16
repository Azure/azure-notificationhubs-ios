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
        let hubName = getPlistInfo(resourceName: "DevSettings", key: "HUB_NAME")
        let connectionString = getPlistInfo(resourceName: "DevSettings", key: "CONNECTION_STRING")

        MSNotificationHub.setLifecycleDelegate(self)
        UNUserNotificationCenter.current().delegate = self;
        MSNotificationHub.setDelegate(self)
        MSNotificationHub.start(connectionString: connectionString, hubName: hubName)
    }

    func getPlistInfo(resourceName: String, key: String) -> String {
        guard let value = Bundle.main.path(forResource: resourceName, ofType: "plist") else {
            return ""
        }
        return value
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
