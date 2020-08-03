![framework-docs](https://github.com/Azure/azure-notificationhubs-ios/workflows/framework-docs/badge.svg)
![analyze-test](https://github.com/Azure/azure-notificationhubs-ios/workflows/analyze-test/badge.svg)

# Microsoft Azure Notification Hubs SDK for Apple

Microsoft Azure Notification Hubs provide a multiplatform, scaled-out push infrastructure that enables you to send mobile push notifications from any backend (in the cloud or on-premises) to any mobile platform. To learn more, visit our [Developer Center](https://azure.microsoft.com/en-us/documentation/services/notification-hubs).

The Azure Notification Hubs SDK for Apple provides capabilities for registering your device and receive push notifications on macOS and iOS including platforms including tvOS, watchOS and Mac Catalyst.

## Getting Started

The Azure Notification Hubs can be added to your app via Cocoapods, Carthage, Swift Package Manager, or by manually adding the binaries to your project.  We have a number of sample applications available written in both Swift and Objective-C to help you get started for both iOS with Mac Catalyst support, and a macOS sample, and SwiftUI coming soon.

**This introduces a new API as of version 3.0, and the usage of `SBNotificationHub` with registrations is still supported, but discouraged as we have the new `MSNotificationHub` which uses the Installation API and modern Apple APIs.**

1. NH Sample App for iOS/Mac Catalyst ([Swift](SampleNHAppSwift) | [Objective-C](SampleNHAppObjC))
2. NH Sample App for macOS ([Swift](SampleNHAppMacSwift) | [Objective-C](SampleNHAppMacObjC))
3. NH Sample App for SwiftUI ([iOS](SampleNHAppSwiftUI) | [macOS](SampleNHAppMacSwiftUI))
4. NH Sample Legacy App using Legacy APIs ([Swift](SampleNHAppLegacySwift) | [Objective-C](SampleNHAppLegacyObjC))

### Integration with Cocoapods

Add the following into your `podfile` to pull in the Azure Notification Hubs SDK:

```ruby
pod 'AzureNotificationHubs-iOS'
```

Run `pod install` to install the pod and then open your project workspace in Xcode.

### Integration with Carthage

Below are the steps on how to integrate the Azure Notification Huds SDK in your Xcode project using Carthage version 0.30 or higher.  Add the following to your `Cartfile` to include GitHub repository.

```ruby
# Gets the latest release
github "Azure/azure-notificationhubs-ios"
```

You can also specify a specific version of the Azure Notification Hubs SDK such as 3.0.0.

```ruby
# Get version in the format of X.X.X such as 3.0.0
github "Azure/azure-notificationhubs-ios" ~> 3.0.0
```

Once you have this, run `carthage update`.  This will fetch the SDK and put it into the `Carthage/Checkouts` folder.  Open Xcode and drag the `WindowsAzureMessaging.framework` from the `Carthage/Builds/iOS` for iOS or `Carthage/Builds/macOS` for macOS.  Ensure the app target is checked during the import.

### Integration via Swift Package Manager

The Azure Notification Hubs SDK also supports the Swift Package Manager.  To integrate, use the following steps:

1. From the Xcode menu click File > Swift Packages > Add Package Dependency.
2. In the dialog, enter the repository URL: `http://github.com/Azure/azure-notificationhubs-ios.git`
3. In the Version, select Up to Next Major and take the default option.
4. Choose WindowsAzureMessaging in the Package Product column.

### Integration via copying binaries

The Azure Notification Hubs SDK can also be added manually by downloading the release from GitHub on the [Azure Notification Hubs SDK Releases](https://github.com/Azure/azure-notificationhubs-ios/releases).

The SDK supports the use of XCframework. If you want to integrate XCframeworks into your project, download the WindowsAzureMessaging-SDK-Apple-XCFramework.zip from the releases page and unzip it. Resulting folder contents are not platform-specific, instead it contains the XCframework.

Unzip the file and you will see a folder called WindowsAzureMessaging-SDK-Apple that contains the framework files each platform folder.  Copy the framework to a desired location and then add to Xcode.  Ensure the app target is checked during the import.

### Initializing the SDK

To get started with the SDK, you need to configure your Azure Notification Hub with your Apple credentials.  To integrate the SDK, you will need the name of the hub as well as a connection string from your Access Policies.  Note that you only need the "Listen" permission to intercept push notifications.

You can then import the headers for Swift:

```swift
import WindowsAzureMessaging
```

And Objective-C as well:

```objc
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
```

Then we can initialize the SDK with our hub name and connection string.  This will automatically register the device using the [Installation API](https://docs.microsoft.com/en-us/azure/notification-hubs/notification-hubs-push-notification-registration-management#installations) with your device token.

Using Swift, we can use the `start` method, which then starts the installation and device registration process for push notifications.

Swift:
```swift
let connectionString = "<connection-string>"
let hubName = "<hub-name>"

MSNotificationHub.start(connectionString: connectionString!, hubName: hubName!)
```

With Objective-C, it is largely the same with calling the `startWithConnectionString` method:

Objective-C:
```objc
NSString *connectionString = @"<connection-string>";
NSString *hubName = @"<hub-name>";

[MSNotificationHub startWithConnectionString:connectionString hubName:hubName];
```

### Intercepting Push Notifications

You can set up a delegate to be notified whenever a push notification is received in foreground or a background push notification has been tapped by the user.  To get started with intercepting push notifications, implement the `MSNotificationHubDelegate`, and use the `MSNotificationHub.setDelegate` method to set the delegate implementation.  

Swift:
```swift
class SetupViewController: MSNotificationHubDelegate // And other imports

// Set up the delegate
MSNotificationHub.setDelegate(self)

// Implement the method
func notificationHub(_ notificationHub: MSNotificationHub!, didReceivePushNotification notification: MSNotificationHubMessage!) {

    let title = notification.title ?? ""
    let body = notification.body ?? ""

    if (UIApplication.shared.applicationState == .background) {
        NSLog("Notification received in background: title:\"\(title)\" body:\"\(body)\"")
    } else {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        self.present(alertController, animated: true)
    }
}
```

Objective-C:
```objc
@interface SetupViewController <MSNotificationHubDelegate /* Other protocols */>

// Set up the delegate
[MSNotificationHub setDelegate:self];

// Implement the method
- (void)notificationHub:(MSNotificationHub *)notificationHub didReceivePushNotification:(MSNotificationHubMessage *)notification {
    NSString *title = notification.title ?: @"";
    NSString *body = notification.body ?: @"";

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        NSLog(@"Notification received in the background: title: %@ body: %@", title, body);
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:notification.title
                        message:notification.body
                 preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}
```

### Tag Management

One of the ways to target a device or set of devices is through the use of [tags](https://docs.microsoft.com/en-us/azure/notification-hubs/notification-hubs-tags-segment-push-message#tags), where you can target a specific tag, or a tag expression.  The Azure Notification Hub SDK for Apple handles this through top level methods that allow you to add, clear, remove and get all tags for the current installation.  In this example, we can add some recommended tags such as the app language preference, and device country code.

Swift:
```swift
// Get language and country code for common tag values
let language = Bundle.main.preferredLocalizations.first!
let countryCode = NSLocale.current.regionCode!

// Create tags with type_value format
let languageTag = "language_" + language
let countryCodeTag = "country_" + countryCode

MSNotificationHub.addTags([languageTag, countryCodeTag])
```

Objective-C:
```objc
// Get language and country code for common tag values
NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
NSString *countryCode = [[NSLocale currentLocale] countryCode];

// Create tags with type_value format
NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];

[MSNotificationHub addTags:@[languageTag, countryCodeTag]];
```

### Template Management

With [Azure Notification Hub Templates](https://docs.microsoft.com/en-us/azure/notification-hubs/notification-hubs-templates-cross-platform-push-messages), you can enable a client application to specify the exact format of the notifications it wants to receive.  This is useful when you want to create a more personalized notification, with string replacement to fill the values.  The Installation API [allows multiple templates](https://docs.microsoft.com/en-us/azure/notification-hubs/notification-hubs-push-notification-registration-management#templates) for each installation which gives you greater power to target your users with rich messages.

For example, we can create a template with a body, some headers, and some tags.

Swift:
```swift
// Get language and country code for common tag values
let language = Bundle.main.preferredLocalizations.first!
let countryCode = NSLocale.current.regionCode!

// Create tags with type_value format
let languageTag = "language_" + language
let countryCodeTag = "country_" + countryCode

let body = "{\"aps\": {\"alert\": \"$(message)\"}}"
let template = MSInstallationTemplate()
template.body = body
template.addTags([languageTag, countryCodeTag])

MSNotificationHub.setTemplate(template, forKey: "template1")
```

Objective-C:
```objc
NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
NSString *countryCode = [[NSLocale currentLocale] countryCode];

// Create tags with type_value format
NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];

NSString *body = @"{\"aps\": {\"alert\": \"$(message)\"}}";

MSInstallationTemplate *template = [MSInstallationTemplate new];
template.body = body;

[template addTags:@[languageTag, countryCodeTag]];

[MSNotificationHub setTemplate:template forKey:@"template1"];
```

### Intercepting Installation Management

The SDK will handle saving the installation for you, however, we provide hooks where you can intercept both the successful installation or any failure through the `MSInstallationLifecycleDelegate`.  This has two methods, `didSaveInstallation` for successful saves, and `didFailToSaveInstallation` for any failures.  We can implement this to have our own logging for example.  

Swift:
```swift
// Set the delegate
MSNotificationHub.setLifecycleDelegate(self)

// Handle success
func notificationHub(_ notificationHub: MSNotificationHub!, didSave installation: MSInstallation!) {
    let installationId = installation.installationId;
    NSLog("Successful save with Installation ID: \"\(installationId)\"")
}

// Handle failure
func notificationHub(_ notificationHub: MSNotificationHub!, didFailToSave installation: MSInstallation!, withError error: Error!) {
    NSLog("Failed to save installation")
}
```

Objective-C:
```objc
// Set the delegate
[MSNotificationHub setLifecycleDelegate:self];

// Handle successes
- (void)notificationHub:(MSNotificationHub *)notificationHub didSaveInstallation:(MSInstallation *)installation {
    NSLog(@"Successful save with Installation ID: %@", installation.installationId);
}

// Handle failure
- (void)notificationHub:(MSNotificationHub *)notificationHub
    didFailToSaveInstallation:(MSInstallation *)installation
                    withError:(NSError *)error {
    NSLog(@"Failed to save installation with error %@", [error localizedDescription]);
}
```

### Enriching Installations

The SDK will update the installation on the device any time you change its properties such as adding a tag or adding an installation template. Before the installation is sent to the backend, you can intercept this installation to modify anything before it goes to the backend, for example, if you wish to add or modify tags. This is implemented in the `MSInstallationEnrichmentDelegate` protocol with a single method of `willEnrichInstallation`.

Swift:
```swift
// Set the delegate
MSNotificationHub.setEnrichmentDelegate(self)

// Handle the enrichment
func notificationHub(_ notificationHub: MSNotificationHub!, willEnrichInstallation installation: MSInstallation!) {
    installation.addTag("customTag")
}
```

Objective-C:
```objc
// Set the delegate
[MSNotificationHub setEnrichmentDelegate:self];

// Handle the enrichment
- (void)notificationHub:(MSNotificationHub *)notificationHub willEnrichInstallation:(MSInstallation *)installation {
    // Add another tag
    [installation addTag:@"customTag"];
}
```

### Saving Installations to a Custom Backend

The Azure Notification Hubs SDK will save the installation to our backend by default. If, however, you wish to skip our backend and store it on your backend, we support that through the `MSInstallationManagementDelegate` protocol. This has a method to save the installation `willUpsertInstallation`, passing in the installation, and then a completion handler is called with either an error if unsuccessful, or nil if successful.  To set the delegate, instead of specifying the connection string and hub name, you specify the installation manager with `startWithInstallationManagement`

Swift:
```swift
// Set the delegate
MSNotificationHub.startWithInstallationManagement(self)

func notificationHub(_ notificationHub: MSNotificationHub!, willUpsertInstallation installation: MSInstallation!, withCompletionHandler completionHandler: @escaping (NSError?) -> Void) {
    // Save to your own backend
    // Call the completion handler with no error if successful
    completionHandler(nil);
}
```

Objective-C:
```objc
// Set the delegate
[MSNotificationHub startWithInstallationManagement:self];

// Save to your own backend
- (void)notificationHub:(MSNotificationHub *)notificationHub
    willUpsertInstallation:(MSInstallation *)installation
         completionHandler:(void (^)(NSError *_Nullable))completionHandler {
    // Save to your own backend
    // Call the completion handler with no error if successful
    completionHandler(nil);
}
```

### Disabling Automatic Swizzling

By default, the SDK will swizzle methods to automatically intercept calls to `UIApplicationDelegate`/`NSApplicationDelegate` for calls to registering and intercepting push notifications, as well as `UNUserNotificationCenterDelegate` methods.  Note this is only available for iOS, watchOS, and Mac Catalyst.  This is not supported on macOS and tvOS.

#### Disabling UIApplicationDelegate/NSApplicationDelegate

1. Open the project's Info.plist
2. Add the `NHAppDelegateForwarderEnabled` key and set the value to 0.  This disables the UIApplicationDelegate/NSApplicationDelegate auto-forwarding to MSNotificaitonHub.
3. Implement the `MSApplicationDelegate`/`NSApplicationDelegate` methods for push notifications.

    Implement the application:didRegisterForRemoteNotificationsWithDeviceToken: callback and the application:didFailToRegisterForRemoteNotificationsWithError: callback in your AppDelegate to register for Push notifications.  In the code below, if on macOS, not Mac Catalyst, replace `UIApplication` with `NSApplication`.

    Swift:
    ```swift
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        // Pass the device token to MSNotificationHub
        MSNotificationHub.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        // Pass the error to MSNotificationHub
        MSNotificationHub.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    ```

    Objective-C:
    ```objc
    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
        // Pass the device token to MSNotificationHub
        [MSNotificationHub didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }

    - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
        // Pass the error to MSNotificationHub
        [MSNotificationHub didFailToRegisterForRemoteNotificationsWithError:error];
    }
    ```

4. Implement the callback to receive push notifications

    Implement the application:didReceiveRemoteNotification:fetchCompletionHandler callback to forward push notifications to MSNotificationHub  In the code below, if on macOS, not Mac Catalyst, replace `UIApplication` with `NSApplication`.

    Swift:
    ```swift
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        // Forward to MSNotificationHub
        MSNotificationHub.didReceiveRemoteNotification(userInfo)

        // Complete handling the notification
        completionHandler(.noData)
    }
    ```

    Objective-C:
    ```objc
    - (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo
              fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

        // Forward to MSNotificationHub
        [MSNotificationHub didReceiveRemoteNotification:userInfo];

        // Complete handling the notification
        completionHandler(UIBackgroundFetchResultNoData);
    }
    ```

#### Disabling UNUserNotificationCenterDelegate

1. Open the project's Info.plist
2. Add the `NHUserNotificationCenterDelegateForwarderEnabled` key and set the value to 0.  This disables the UNUserNotificationCenterDelegate auto-forwarding to MSNotificaitonHub.
3. Implement UNUserNotificationCenterDelegate callbacks and pass the notification's payload to `MSNotificationHub`.

    Swift:
    ```swift
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        //...

        // Pass the notification payload to MSNotificationHub
        MSNotificationHub.didReceiveRemoteNotification(notification.request.content.userInfo)

        // Complete handling the notification
        completionHandler([])
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        //...

        // Pass the notification payload to MSNotificationHub
        MSNotificationHub.didReceiveRemoteNotification(response.notification.request.content.userInfo)

        // Complete handling the notification
        completionHandler()
    }
    ```

    Objective-C:
    ```objc
    - (void)userNotificationCenter:(UNUserNotificationCenter *)center
          willPresentNotification:(UNNotification *)notification
            withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
            API_AVAILABLE(ios(10.0), tvos(10.0), watchos(3.0)) {

        //...

        // Pass the notification payload to MSNotificationHub
        [MSNotificationHub didReceiveRemoteNotification:notification.request.content.userInfo];

        // Complete handling the notification
        completionHandler(UNNotificationPresentationOptionNone);
    }

    - (void)userNotificationCenter:(UNUserNotificationCenter *)center
       didReceiveNotificationResponse:(UNNotificationResponse *)response
                withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0), tvos(10.0), watchos(3.0)) {

        //...
        [MSNotificationHub didReceiveRemoteNotification:response.notification.request.content.userInfo];

        // Complete handling the notification
        completionHandler();
    }
    ```

## Useful Resources

* Tutorials and product overview are available at [Microsoft Azure Notification Hubs Developer Center](https://azure.microsoft.com/en-us/documentation/services/notification-hubs).
* Our product team actively monitors the [Notification Hubs Developer Forum](http://social.msdn.microsoft.com/Forums/en-US/notificationhubs/) to assist you with any troubles.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

All Objective-C files follow LLVM coding style (with a few exceptions) and are formatted accordingly. To format your changes, make sure you have the clang-format tool. It can be installed with Homebrew using the command `brew install clang-format`. Once you have installed clang-format, run `./clang-format-changed-files.sh` from the repository root - this will format all files that have changes against the remote `master` branch (it will also perform a git fetch).

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
