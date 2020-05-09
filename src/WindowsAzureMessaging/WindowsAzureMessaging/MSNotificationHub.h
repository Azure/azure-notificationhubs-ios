//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSDebounceInstallationManager.h"
#import "MSLocalStorage.h"
#import "MSNotificationHubDelegate.h"
#import "MSNotificationHubMessage.h"
#import "MSTokenProvider.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MSInstallation;
/**
 * The Azure Notification Hubs service
 */
@interface MSNotificationHub : NSObject {
    @private
    MSInstallation *_installation;
    MSDebounceInstallationManager *_debounceInstallationManager;
    NSString *_hubName;
    NSURL *_serviceEndpoint;
}

/**
 * Initializes the Notification Hub with the connection string from the Access
 * Policy, and Hub Name.
 * @param connectionString The connection string
 */
+ (void)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)notificationHubName;

#pragma mark Push Initialization

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo;

+ (void)setDelegate:(nullable id<MSNotificationHubDelegate>)delegate;

#pragma mark Tags Support

+ (BOOL)addTag:(NSString *)tag;
+ (BOOL)addTags:(NSArray<NSString *> *)tags;
+ (BOOL)removeTag:(NSString *)tag;
+ (BOOL)removeTags:(NSArray<NSString *> *)tags;
+ (NSSet<NSString *> *)getTags;
+ (void)clearTags;

- (BOOL)addTag:(NSString *)tag;
- (BOOL)addTags:(NSArray<NSString *> *)tags;
- (BOOL)removeTag:(NSString *)tag;
- (BOOL)removeTags:(NSArray<NSString *> *)tags;
- (NSSet<NSString *> *)getTags;
- (void)clearTags;

@end

NS_ASSUME_NONNULL_END
