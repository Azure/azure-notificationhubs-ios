//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHInstallationEnrichmentDelegate.h"
#import "ANHInstallationLifecycleDelegate.h"
#import "ANHInstallationManagementDelegate.h"
#import "ANHNotificationHubDelegate.h"
#import "ANHNotificationHubMessage.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ANHInstallation;
@class ANHDebounceInstallationManager;
@class ANHInstallationTemplate;
@class ANHNotificationHubOptions;

/**
 * The Azure Notification Hubs service
 */
NS_SWIFT_NAME(AzureNotificationHub)
@interface ANHNotificationHub : NSObject

/**
 * Initializes the Notification Hub with the connection string from the Access
 * Policy, and Hub Name.
 *
 * @param connectionString The access policy connection string.
 * @param notificationHubName The Azure Notification Hub name
 */
+ (void)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)notificationHubName NS_SWIFT_NAME(start(connectionString:hubName:));

/**
 * Initializes the Notification Hub with the connection string from the Access
 * Policy, and Hub Name.
 *
 * @param connectionString The access policy connection string.
 * @param notificationHubName The Azure Notification Hub name
 * @param options The Azure Notification Hubs options such as Authorization Options.
 */
+ (void)startWithConnectionString:(NSString *)connectionString hubName:(NSString *)notificationHubName options:(ANHNotificationHubOptions *)options NS_SWIFT_NAME(start(connectionString:hubName:options:));

/**
 * Initializes the Notification Hub with the installation management delegate to a custom backend.
 * Defines the class that implements the optional protocol `MSInstallationEnrichmentDelegate`.
 *
 * @param managementDelegate The delegate.
 *
 * @see MSInstallationEnrichmentDelegate
 */
+ (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate;

/**
 * Initializes the Notification Hub with the installation management delegate to a custom backend and options
 * Defines the class that implements the optional protocol `ANHInstallationEnrichmentDelegate`.
 *
 * @param managementDelegate The delegate.
 * @param options The Azure Notification Hubs options such as Authorization Options.
 *
 * @see MSInstallationEnrichmentDelegate
 */
+ (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate options:(ANHNotificationHubOptions *)options;

#pragma mark Push Initialization

/**
 * Callback for successful registration with push token.
 *
 * @param deviceToken The device token for remote notifications.
 */
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 * Callback for unsuccessful registration with error.
 *
 * @param error Error of unsuccessful registration.
 */
+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 * Callback for notification with user info.
 *
 * @param userInfo The user info for the remote notification.
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 * The delegate for getting messages from the server.
 */
@property(class, nonatomic, weak) id<ANHNotificationHubDelegate> _Nullable delegate;

/**
 * The flag indicates whether or not the SDK was enabled as a whole
 *
 * The state is persisted in the device's storage across application launches.
 */
@property(class, nonatomic, getter=isEnabled, setter=setEnabled:) BOOL enabled NS_SWIFT_NAME(enabled);

#pragma mark Installation Support

/**
 * Saves the current installation in local storage.
 */
+ (void)willSaveInstallation;

/**
 * Gets the current push channel device token.
 */
@property (class, nonatomic, readonly) NSString *pushChannel;

/**
 * Gets the current installation ID.
 */
@property (class, nonatomic, readonly) NSString *installationId;

#pragma mark Tags Support

/**
 * Adds a tag to the current installation.
 *
 * @param tag The tag to add
 *
 * @returns YES if tag was added, else NO.
 */
+ (BOOL)addTag:(NSString *)tag;

/**
 * Adds the tags array to the current installation.
 *
 * @param tags The tags array to add
 *
 * @returns YES if the tags were added, else NO.
 */
+ (BOOL)addTags:(NSArray<NSString *> *)tags;

/**
 * Removes the tag from the current installation.
 *
 * @param tag The tag to remove.
 *
 * @returns YES if the tag was removed, else NO.
 */
+ (BOOL)removeTag:(NSString *)tag;

/**
 * Removes the tags from the current installation.
 *
 * @param tags The tags to remove.
 *
 * @returns YES if the tags were removed, else NO.
 */
+ (BOOL)removeTags:(NSArray<NSString *> *)tags;

/**
 * Gets the tags from the current installation.
 *
 * @returns The tags from the current installation.
 */
@property (class, nonatomic, readonly) NSArray<NSString *> * tags;

/**
 * Clears the tags from the current installation.
 */
+ (void)clearTags;

#pragma mark Template Support

/**
 * Sets the template for the installation template for the given key.
 *
 * @param template The `MSInstallationTemplate` object containing the installation template data.
 * @param key The key for the template.
 *
 * @returns YES if the template was added, else NO.
 *
 * @see MSInstallationTemplate
 */
+ (BOOL)setTemplate:(ANHInstallationTemplate *)template forKey:(NSString *)key;

/**
 * Removes the installation template for the given key.
 *
 * @param key The key for the inistallation template.
 *
 * @returns YES if removed, else NO.
 */
+ (BOOL)removeTemplateForKey:(NSString *)key;

/**
 * Gets the installation template `MSInstallationTemplate` for the given key.
 *
 * @param key The key for the template.
 *
 * @returns The installation template instance
 *
 * @see MSInstallationTemplate
 */
+ (ANHInstallationTemplate *)templateForKey:(NSString *)key;

/**
 * Gets all the templates for the given installation.
 *
 * @returns A dictionary of the strings and installation templates.
 *
 * @see MSInstallationTemplate
 */
@property (class, nonatomic, readonly) NSDictionary<NSString *, ANHInstallationTemplate *> * templates;

#pragma mark UserID support

/**
 * Represents the User ID for the application
 */
@property (class, nonatomic) NSString *userId;

#pragma mark Installation management support

/**
 * The delegate for getting enriching installations before saving to the backend.
 */
@property(class, nonatomic, weak) id<ANHInstallationEnrichmentDelegate> _Nullable enrichmentDelegate;

/**
 * The lifecycle delegate to be able to intercept whether saving the installation was successful.
 * Defines the class that implements the optional protocol `MSInstallationLifecycleDelegate`.
 */
@property(class, nonatomic, weak) id<ANHInstallationLifecycleDelegate> _Nullable lifecycleDelegate;

@end

NS_ASSUME_NONNULL_END
