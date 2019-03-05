# iOS Notification Hubs Sample

This is a sample project intended to demonstrate the usage of the Azure Notification Hubs iOS Client SDK.  The sample app allows the developer to register the device with a Notification Hub with the given tags as well as unregister the device. 

This app handles the following scenarios
- Register and unregister the device with the Notification Hub with the given tags
- Receive push notifications
- Receive silent push notifications
- Handle mutable messages via a Notification Service Extension

## Getting Started.

The sample application requires the following:
- macOS Sierra+
- Xcode 10+
- iOS device with iOS 10+

In order to set up the Azure Notification Hub, [follow the tutorial](https://docs.microsoft.com/en-us/azure/notification-hubs/notification-hubs-ios-apple-push-notification-apns-get-started) to create the required certificates and register your application.

To run the application, update the following values in `Info.plist` with values from the notification hub:
- `NotificationHubConnectionString`: Use the `DefaultListenSharedAccessSignature` connection string from the notification hub created in the tutorial
- `NotificationHubName`: Use the name of the notification hub created in the tutorial

Once the values have been updated, build the application and deploy to your device.  From there, you can register the device, set tags used to target the device, and unregister the device.

## Setting up the notification code

Diving into the sample code, we can use the SDK to connect to the service using the connection string and hub name from `Info.plist`.

```objc
- (SBNotificationHub *)getNotificationHub {
    NSString *hubName = [[NSBundle mainBundle] objectForInfoDictionaryKey:NHInfoHubName];
    NSString *connectionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:NHInfoConnectionString];
    
    return [[SBNotificationHub alloc] initWithConnectionString:connectionString notificationHubPath:hubName];
}
```

We can then register for push notifications (with options to enable sound and badge updates) using the following code:

```objc
    @IBAction func handleRegister(_ sender: Any) {
        // Save raw tags text in storage
        UserDefaults.standard.set(tagsTextField.text, forKey: Constants.NHUserDefaultTags)
        
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
```

	We can also unregister the device from the Azure Notification Hub with the following code:

```objc
@IBAction func handleUnregister(_ sender: Any) {
        let hub = getNotificationHub()
        hub.unregisterNative { error in
            if (error != nil) {
                print("Error unregistering for push: \(error.debugDescription)");
            } else {
                showAlert("Unregistered", withTitle: "Registration Status")
            }
        }
    }
```

## Handle a push notification

In order to demonstrate handling a push notification, use the Azure Portal for your Notification Hub and select "Test Send" to send messages to your application.  For example, we can send a simple message to our device by selecting the Apple Platform, adding your selected tags and the following message body:

```
{
    "aps": {
        "alert": {
            "title": "Alert title",
            "body": "This is the alert body"
        }
    }
}
```

Diving into the code, the push notifications are handled by the following two `UNUserNotificationCenterDelegate` delegate methods.

The `userNotificationCenter:willPresent:withCompletionHandler:` method handles notifications when the app is in the foreground (before the notification is optionally displayed to the user):

```objc
func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Your code here
}
```

The `userNotificationCenter:didReceive:withCompletionHandler:` method handles notifications when the app is in the background, _and_ the user taps on the system notification:

```objc
func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
    // Your code here
}
```

## Handle a silent push

The iOS platform allows for [silent notifications](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_updates_to_your_app_silently?language=objc) which allow you to notify your application when new data is available, without displaying that notification to the user.  Using the "Test Send" capability, we can send a silent notification using the `content-available` property in the message body.

```
{
    "aps": {
        "content-available": 1
    }
}
```

To handle this scenario in code, implement the `UIApplicationDelegate` method `application:didReceiveRemoteNotification:fetchCompletionHandler:`:

```objc
func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Your code here
}
```

# Credits

- App icons are based on icons from [Material Design](https://material.io/tools/icons) and were packaged with [MakeAppIcon](https://makeappicon.com/).
