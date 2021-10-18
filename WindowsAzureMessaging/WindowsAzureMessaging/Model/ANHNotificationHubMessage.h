//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

/**
 * The Push Notification message.
 */
NS_SWIFT_NAME(NotificationHubMessage)
@interface ANHNotificationHubMessage : NSObject

/**
 * Notification title.
 */
@property(nonatomic, readonly) NSString *title;

/**
 * Notification message.
 */
@property(nonatomic, readonly) NSString *body;

/**
 * The notification badge count.
 */
@property(nonatomic, readonly) NSNumber *badge;

/**
 * The content-available from the APNS message.
 */
@property(nonatomic, readonly) NSNumber *contentAvailable;

/**
 * Notification data.
 */
@property(nonatomic, readonly) NSDictionary *userInfo;

@end
