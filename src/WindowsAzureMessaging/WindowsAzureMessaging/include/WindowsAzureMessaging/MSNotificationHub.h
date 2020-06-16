//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHubDelegate.h"
#import "MSNotificationHubMessage.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MSInstallation;
@class MSDebounceInstallationManager;
@class MSInstallationTemplate;
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
+ (void)startWithConnectionString:(NSString *)connectionString hubName:(NSString *)notificationHubName NS_SWIFT_NAME(start(connectionString:hubName:));

#pragma mark Push Initialization

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)setDelegate:(nullable id<MSNotificationHubDelegate>)delegate;

+ (BOOL)isEnabled;
+ (void)setEnabled:(BOOL)isEnabled;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)isEnabled;

#pragma mark Installation Support

- (NSString *)getPushChannel;
- (NSString *)getInstallationId;

+ (NSString *)getPushChannel;
+ (NSString *)getInstallationId;

#pragma mark Tags Support

+ (BOOL)addTag:(NSString *)tag;
+ (BOOL)addTags:(NSArray<NSString *> *)tags;
+ (BOOL)removeTag:(NSString *)tag;
+ (BOOL)removeTags:(NSArray<NSString *> *)tags;
+ (NSArray<NSString *> *)getTags;
+ (void)clearTags;

- (BOOL)addTag:(NSString *)tag;
- (BOOL)addTags:(NSArray<NSString *> *)tags;
- (BOOL)removeTag:(NSString *)tag;
- (BOOL)removeTags:(NSArray<NSString *> *)tags;
- (NSArray<NSString *> *)getTags;
- (void)clearTags;

#pragma mark Template Support

+ (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;
+ (BOOL)removeTemplateForKey:(NSString *)key;
+ (MSInstallationTemplate *)getTemplateForKey:(NSString *)key;

- (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;
- (BOOL)removeTemplateForKey:(NSString *)key;
- (MSInstallationTemplate *)getTemplateForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
