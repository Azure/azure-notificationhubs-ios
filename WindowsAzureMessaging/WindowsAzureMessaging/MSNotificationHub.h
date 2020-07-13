//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationEnrichmentDelegate.h"
#import "MSInstallationLifecycleDelegate.h"
#import "MSInstallationManagementDelegate.h"
#import "MSNotificationHubDelegate.h"
#import "MSNotificationHubMessage.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MSInstallation;
@class MSDebounceInstallationManager;
@class MSInstallationTemplate;

/**
 * The Azure Notification Hubs service
 */
@interface MSNotificationHub : NSObject

/**
 * Initializes the Notification Hub with the connection string from the Access
 * Policy, and Hub Name.
 *
 * @param connectionString The access policy connection string.
 * @param notificationHubName The Azure Notification Hub name
 */
+ (void)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)notificationHubName NS_SWIFT_NAME(start(connectionString:hubName:));

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
 * Set the delegate.
 * Defines the class that implements the optional protocol `MSNotificationHubDelegate`.
 *
 * @param delegate The delegate.
 *
 * @see MSNotificationHubDelegate
 */
+ (void)setDelegate:(nullable id<MSNotificationHubDelegate>)delegate;

/**
 * Check whether the Azure Notification Hubs SDK is enabled or not as a whole.
 *
 * @return YES if enabled, NO otherwise.
 *
 * @see setEnabled:
 */
+ (BOOL)isEnabled;

/**
 * Enable or disable the Azure Notification Hubs SDK from receiving messages.
 * The state is persisted in the device's storage across application launches.
 *
 * @param isEnabled YES to enable, NO to disable.
 *
 * @see isEnabled
 */
+ (void)setEnabled:(BOOL)isEnabled;

#pragma mark Installation Support

/**
 * Saves the current installation in local storage.
 */
+ (void)willSaveInstallation;

/**
 * Gets the current push channel device token.
 *
 * @returns The push channel device token.
 */
+ (NSString *)getPushChannel;

/**
 * Gets the current installation ID.
 *
 * @returns The current installation ID.
 */
+ (NSString *)getInstallationId;

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
+ (NSArray<NSString *> *)getTags;

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
+ (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;

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
+ (MSInstallationTemplate *)getTemplateForKey:(NSString *)key;

/**
 * Gets all the templates for the given installation.
 *
 * @returns A dictionary of the strings and installation templates.
 *
 * @see MSInstallationTemplate
 */
+ (NSDictionary<NSString *, MSInstallationTemplate *> *)getTemplates;

#pragma mark Installation management support

/**
 * Set the enrichment delegate for the installation
 * Defines the class that implements the optional protocol `MSInstallationEnrichmentDelegate`.
 *
 * @param enrichmentDelegate The delegate.
 *
 * @see MSInstallationEnrichmentDelegate
 */
+ (void)setEnrichmentDelegate:(nullable id<MSInstallationEnrichmentDelegate>)enrichmentDelegate;

/**
 * Set the management delegate for the installation to save to a custom backend
 * Defines the class that implements the optional protocol `MSInstallationEnrichmentDelegate`.
 *
 * @param managementDelegate The delegate.
 *
 * @see MSInstallationEnrichmentDelegate
 */
+ (void)setManagementDelegate:(nullable id<MSInstallationManagementDelegate>)managementDelegate;

/**
 * Set the lifecycle delegate to be able to intercept whether saving the installation was successful.
 * Defines the class that implements the optional protocol `MSInstallationLifecycleDelegate`.
 *
 * @param lifecycleDelegate The delegate.
 *
 * @see MSInstallationLifecycleDelegate
 */
+ (void)setLifecycleDelegate:(nullable id<MSInstallationLifecycleDelegate>)lifecycleDelegate;

@end

NS_ASSUME_NONNULL_END
