//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSNotificationHubMessage : NSObject

/**
 * Notification title.
 */
@property(nonatomic, copy, readonly) NSString *title;

/**
 * Notification message.
 */
@property(nonatomic, copy, readonly) NSString *body;

/**
 * Notification badge.
 */
@property(nonatomic, readonly) NSInteger badge;

/**
 * Custom data for the notification.
 */
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *data;

- (instancetype)initWithNotification:(NSDictionary *)notification;
+ (instancetype)createFromNotification:(NSDictionary *)notification;
@end
