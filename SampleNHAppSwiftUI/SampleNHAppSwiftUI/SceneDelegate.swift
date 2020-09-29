//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------


import UIKit
import SwiftUI
import WindowsAzureMessaging

class SceneDelegate: UIResponder, UIWindowSceneDelegate, MSNotificationHubDelegate, MSInstallationLifecycleDelegate {

    var window: UIWindow?
    @ObservedObject var notifications: ObservableMessagesList = ObservableMessagesList(items: []);
    @ObservedObject var installation: ObservableInstallation = ObservableInstallation(installationId: MSNotificationHub.getInstallationId(), pushChannel: MSNotificationHub.getPushChannel())
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // Create the SwiftUI view that provides the window contents.
        MSNotificationHub.setLifecycleDelegate(self)
        
        let contentView = ContentView(notifications: notifications, installation: installation)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceivePushNotification), name: Notification.Name("MessageReceived"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("MessageReceived"), object: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    @objc func didReceivePushNotification(notification: Notification) {
        let message = notification.userInfo!["message"] as! MSNotificationHubMessage
        
        NSLog("Received notification: %@; %@", message.title ?? "<nil>", message.body)
        
        self.notifications.items.append(message)
        
        let alertController = UIAlertController(title: message.title, message: message.body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alertController.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func notificationHub(_ notificationHub: MSNotificationHub, didSave installation: MSInstallation) {
        
        DispatchQueue.main.async {
            self.installation.installationId = installation.installationId
            self.installation.pushChannel = installation.pushChannel
        }
    }
}

