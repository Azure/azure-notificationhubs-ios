//
//  AppDelegate.swift
//  nhubsample
//
//  Created by TOYS on 2/25/19.
//  Copyright © 2019 Microsoft. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
                self.showAlert("Registered", withTitle:"Registration Status");
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification while the application is in the foreground");
        
        showNoification(notification.request.content.userInfo)
        
        completionHandler([.sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification while the application is in the background");
        
        showNoification(response.notification.request.content.userInfo)
        
        completionHandler()
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
    
    func getNotificationHub() -> SBNotificationHub {
        let NHubName = Bundle.main.object(forInfoDictionaryKey: Constants.NHInfoHubName) as? String
        let NHubConnectionString = Bundle.main.object(forInfoDictionaryKey: Constants.NHInfoConnectionString) as? String
        
        return SBNotificationHub.init(connectionString: NHubConnectionString, notificationHubPath: NHubName)
    }
    
    func handleRegister() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                if (error != nil) {
                    print("Error requesting for authorization:");
                }
                print("Permission granted: \(granted)")
                guard granted else { return }
                self.getNotificationSettings()
        }
    }

    func handleUnregister() {
        let hub = getNotificationHub()
        hub.unregisterNative { error in
            if (error != nil) {
                print("Error unregistering for push: \(error.debugDescription)");
            } else {
                self.showAlert("Unregistered", withTitle: "Registration Status")
            }
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func logNotificationDetails(_ userInfo: Any) {
        let state = UIApplication.shared.applicationState;
        let background = state != .active;
        print("Received \(background ? "(background)" : ""): \(userInfo)");
    }
    
    func showAlert(_ message: String, withTitle title: String = "Alert") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showNoification(_ userInfo: Any) {
        logNotificationDetails(userInfo)
        
        let notificationDetail = NotificationDetailViewController(userInfo)
        UIApplication.shared.keyWindow?.rootViewController?.present(notificationDetail, animated: true, completion: nil)
    }
}

