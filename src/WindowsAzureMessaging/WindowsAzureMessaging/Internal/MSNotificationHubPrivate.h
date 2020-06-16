//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHub.h"
#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
@interface MSNotificationHub <NSUserNotificationCenterDelegate> ()
#else
@interface MSNotificationHub ()
#endif

- (NSString *)convertTokenToString:(NSData *)token;

+ (void)resetSharedInstance;

@property(nonatomic) id<MSNotificationHubDelegate> delegate;

#if TARGET_OS_OSX
@property(nonatomic) id<NSUserNotificationCenterDelegate> originalUserNotificationCenterDelegate;
#endif

@end
