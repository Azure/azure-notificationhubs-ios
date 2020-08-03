//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: UIApplicationDelegate Methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let unparsedTags = UserDefaults.standard.string(forKey: Constants.NHUserDefaultTags) ?? ""
        let tagsArray = unparsedTags.split(separator: ",")
        
        let hub = getNotificationHub()
        hub.registerNative(withDeviceToken: deviceToken, tags: Set(tagsArray)) {
            error in
            if (error != nil) {
                print("Error registering for notifications: \(error.debugDescription)");
            } else {
                showAlert("Registered", withTitle:"Registration Status");
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Received remote (silent) notification");
        logNotificationDetails(userInfo);
        
        completionHandler(UIBackgroundFetchResult.newData);
    }
    
    // MARK: UNUserNotificationCenterDelegate Methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification while the application is in the foreground");
        
        showNotification(notification.request.content.userInfo)
        
        completionHandler([.sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification while the application is in the background");
        
        showNotification(response.notification.request.content.userInfo)
        
        completionHandler()
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


    func logNotificationDetails(_ userInfo: Any) {
        let state = UIApplication.shared.applicationState;
        let background = state != .active;
        print("Received \(background ? "(background)" : ""): \(userInfo)");
    }
    
    func showNotification(_ userInfo: Any) {
        logNotificationDetails(userInfo)
        
        let notificationDetail = NotificationDetailViewController(userInfo)
        UIApplication.shared.keyWindow?.rootViewController?.present(notificationDetail, animated: true, completion: nil)
    }
    
}

