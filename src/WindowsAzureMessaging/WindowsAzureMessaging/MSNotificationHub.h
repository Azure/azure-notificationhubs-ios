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
@class MSInstallationTemplate;
/**
 * The Azure Notification Hubs service
 */
@interface MSNotificationHub : NSObject

@property(nonatomic, copy, readonly) MSInstallation *installation;
@property(nonatomic, copy, readonly) NSString *hubName;
@property(nonatomic, copy, readonly) NSURL *serviceEndpoint;
@property(nonatomic, copy, readonly) NSMutableDictionary<NSString *, MSInstallationTemplate *> *templates;
@property(nonatomic) MSDebounceInstallationManager *debounceInstallationManager;

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
+ (BOOL)addTags:(NSSet<NSString *> *)tags;
+ (BOOL)removeTag:(NSString *)tag;
+ (BOOL)removeTags:(NSSet<NSString *> *)tags;
+ (NSSet<NSString *> *)getTags;
+ (void)clearTags;

#pragma mark Installation Support
+ (MSInstallation *)getInstallation;

@end

NS_ASSUME_NONNULL_END
