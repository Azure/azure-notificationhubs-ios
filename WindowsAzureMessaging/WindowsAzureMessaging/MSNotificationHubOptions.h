//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface MSNotificationHubOptions : NSObject

@property (nonatomic)UNAuthorizationOptions authorizationOptions API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0));

- (instancetype)initWithAuthorizationOptions:(UNAuthorizationOptions)authorizationOptions API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0));

+ (instancetype)optionsWithAuthorizationOptions:(UNAuthorizationOptions)authorizationOptions API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0));

@end
