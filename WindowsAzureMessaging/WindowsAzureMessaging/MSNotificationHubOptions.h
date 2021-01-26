//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

/**
 * A class which contains the options for the Notification Hubs initialization.
 */
@interface MSNotificationHubOptions : NSObject
/**
 * The authorization options for registering for push notifications.
 */
@property (nonatomic)UNAuthorizationOptions authorizationOptions API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0));

- (instancetype)initWithAuthorizationOptions:(UNAuthorizationOptions)authorizationOptions API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0)) NS_SWIFT_NAME(init(withOptions:));

@end
