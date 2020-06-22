//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSNotificationHubMessage : NSObject

/**
 * Notification title.
 */
@property(nonatomic, readonly) NSString *title;

/**
 * Notification message.
 */
@property(nonatomic, readonly) NSString *body;

/**
 * Notification data.
 */
@property(nonatomic, readonly) NSDictionary *userInfo;

@end
