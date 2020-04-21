// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MSNotificationHubMessage_h
#define MSNotificationHubMessage_h

#import <Foundation/Foundation.h>

@interface MSNotificationHubMessage : NSObject

/**
 * Notification title.
 */
@property(nonatomic, copy, readonly) NSString *title;

/**
 * Notification message.
 */
@property(nonatomic, copy, readonly) NSString *message;

/**
 * Custom data for the notification.
 */
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *customData;

@end

#endif /* MSNotificationHubMessage_h */
