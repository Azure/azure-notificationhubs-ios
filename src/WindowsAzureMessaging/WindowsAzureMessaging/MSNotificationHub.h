// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MSNotificationHub_h
#define MSNotificationHub_h

#import <Foundation/Foundation.h>
#import "MSInstallationTemplate.h"
#import "MSNotificationHubMessageDelegate.h"
#import "MSLocalStorage.h"

/**
 * The Azure Notification Hubs service
*/
@interface MSNotificationHub : NSObject

@property(nonatomic, copy, readonly) MSInstallation *installation;
@property(nonatomic, copy, readonly) NSString *hubName;
@property(nonatomic, copy, readonly) NSURL *serviceEndpoint;
@property(nonatomic, copy, readonly) NSMutableArray *tags;
@property(nonatomic, copy, readonly) NSMutableDictionary<NSString *, MSInstallationTemplate *> *templates;

// TODO: Move to internal
@property(nonatomic) id<MSNotificationHubMessageDelegate> delegate;
@property(atomic, copy) NSString *pushToken;

/**
 * Initializes the Notification Hub with the connection string from the Access Policy, and Hub Name.
 * @param connectionString The connection string
 */
+ (void)initWithConnectionString:(NSString *) connectionString withHubName:(NSString*)notificationHubName;

#pragma mark Push Initialization

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark Tags Support

+ (void)addTag:(NSString *)tag;
+ (void)removeTag:(NSString *)tag;
+ (NSArray *)getTags;

#pragma mark Template Support

+ (void)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;
+ (void)removeTemplate:(NSString *)key;
+ (MSInstallationTemplate *)getTemplate:(NSString *)key;

#pragma mark Helpers

// TODO: Move into internal
- (NSString *)convertTokenToString:(NSData *)token;

@end

#endif /* MSNotificationHub_h */
