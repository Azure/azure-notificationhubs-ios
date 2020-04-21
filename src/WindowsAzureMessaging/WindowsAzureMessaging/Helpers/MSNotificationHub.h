// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MSNotificationHub_h
#define MSNotificationHub_h

#import <Foundation.h>

/**
 * The Azure Notification Hubs service
*/
@interface MSNotificationHub : NSObject

@property(nonatomic, copy, readonly) NSString *hubName;
@property(nonatomic, copy, readonly) NSURL *serviceEndpoint;
@property(nonatomic, copy, readonly) NSString *pushToken;
@property(nonatomic, copy, readonly) NSMutableArray *tags;
@property(nonatomic, copy, readonly) NSMutableDictionary *templates;

/**
 * Initializes the Notification Hub with the connection string from the Access Policy, and Hub Name.
 * @param connectionString The connection string
 */
+ (void)initWithConnectionString:(NSString *) connectionString withHubName:(NSString*)notificationHubName;

#pragma mark Push Initialization

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark Tags Support

+ (void)addTag:(NSString *)tag;
+ (void)removeTag:(NSString *)tag;
+ (NSArray *)tags;

@end

#endif /* MSNotificationHub_h */
