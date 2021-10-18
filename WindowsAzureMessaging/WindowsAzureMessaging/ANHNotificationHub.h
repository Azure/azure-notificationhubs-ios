//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_NOTIFICATION_HUB_H
#define ANH_NOTIFICATION_HUB_H

#import "ANHService.h"
#import "ANHConstants.h"
#import "ANHInstallationEnrichmentDelegate.h"
#import "ANHInstallationLifecycleDelegate.h"
#import "ANHInstallationManagementDelegate.h"
#import "ANHNotificationHubDelegate.h"
#import "ANHNotificationHubMessage.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ANHInstallation;
@class ANHInstallationTemplate;
@class ANHNotificationHubOptions;

/**
 * The Azure Notification Hubs service
 */
NS_SWIFT_NAME(NotificationHub)
@interface ANHNotificationHub : ANHService

/**
 * Gets the shared instance of the Notification Hub.
 */
@property (class, atomic, readonly) ANHNotificationHub *sharedInstance;

/**
 * Initializes the Notification Hub with the connection string from the Access
 * Policy, and Hub Name.
 *
 * @param connectionString The access policy connection string.
 * @param hubName The Azure Notification Hub name
 */
- (BOOL)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)hubName
                            error:(NSError *__autoreleasing *)error
                          NS_SWIFT_NAME(start(connectionString:hubName:error:));

/**
 * Initializes the Notification Hub with the connection string from the Access
 * Policy, and Hub Name.
 *
 * @param connectionString The access policy connection string.
 * @param notificationHubName The Azure Notification Hub name
 * @param options The Azure Notification Hubs options such as Authorization Options.
 */
- (BOOL)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)notificationHubName
                          options:(ANHNotificationHubOptions *)options
                            error:(NSError *__autoreleasing *)error
                          NS_SWIFT_NAME(start(connectionString:hubName:options:error:));

/**
 * Initializes the Notification Hub with the installation management delegate to a custom backend and options
 * Defines the class that implements the optional protocol `ANHInstallationEnrichmentDelegate`.
 *
 * @param managementDelegate The delegate.
 *
 * @see ANHInstallationEnrichmentDelegate
 */
- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate;

/**
 * Initializes the Notification Hub with the installation management delegate to a custom backend and options
 * Defines the class that implements the optional protocol `ANHInstallationEnrichmentDelegate`.
 *
 * @param managementDelegate The delegate.
 * @param options The Azure Notification Hubs options such as Authorization Options.
 *
 * @see ANHInstallationEnrichmentDelegate
 */
- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate options:(ANHNotificationHubOptions *)options;

#pragma mark Push Initialization

/**
 * Callback for successful registration with push token.
 *
 * @param deviceToken The device token for remote notifications.
 */
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 * Callback for unsuccessful registration with error.
 *
 * @param error Error of unsuccessful registration.
 */
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 * Callback for notification with user info.
 *
 * @param userInfo The user info for the remote notification.
 */
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 * The delegate for getting messages from the server.
 */
@property(nonatomic, weak) id<ANHNotificationHubDelegate> _Nullable delegate;

@end

NS_ASSUME_NONNULL_END

#endif
