//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_VOIP_NOTIFICATION_HUB_H
#define ANH_VOIP_NOTIFICATION_HUB_H

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>
#import "ANHService.h"
#import "ANHVoIPNotificationHubDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class ANHInstallation;
@class ANHInstallationTemplate;

NS_SWIFT_NAME(VoIPNotificationHub)
@interface ANHVoIPNotificationHub : ANHService

/**
 * Gets the shared instance of the VoIP Notification Hub.
 */
@property (class, atomic, readonly) ANHVoIPNotificationHub *sharedInstance;

#pragma mark - Initialization

- (BOOL)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)notificationHubName
                            error:(NSError *__autoreleasing  _Nullable *)error;

- (BOOL)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)notificationHubName
                     pushRegistry:(PKPushRegistry *)pushRegistry
                            error:(NSError *__autoreleasing  _Nullable *)error;

- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate;

- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate
                           pushRegistry:(PKPushRegistry *)registry;

#pragma mark - PKPushRegistryDelegate

/**
 * The delegate for getting messages from the server.
 */
@property(nonatomic, weak) id<ANHVoIPNotificationHubDelegate> _Nullable delegate;

- (void)didUpdatePushCredentials:(NSData *)pushCredentials;

- (void)didInvalidatePushToken;

- (void)didReceiveIncomingPushWithPayload:(NSDictionary *)payload
withCompletionHandler:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END

#endif
