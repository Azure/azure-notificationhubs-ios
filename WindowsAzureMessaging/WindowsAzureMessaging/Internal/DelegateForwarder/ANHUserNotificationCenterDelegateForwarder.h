//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_USERNOTIFICATIONCENTER_DELEGATE_FORWARDER_h
#define ANH_USERNOTIFICATIONCENTER_DELEGATE_FORWARDER_h

#import "ANHDelegateForwarder.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kANHUserNotificationCenterDelegateForwarderEnabledKey = @"NHUserNotificationCenterDelegateForwarderEnabled";

/**
 * The @c MSUserNotificationCenterDelegateForwarder is responsible for swizzling the @c UNUserNotificationCenterDelegate and forwarding
 * delegate calls to Push and customer implementation. The @c UNUserNotificationCenterDelegate is a push only delegate so the forwarder is
 * directly communicating with Push.
 */
@interface ANHUserNotificationCenterDelegateForwarder : ANHDelegateForwarder

/**
 * This is an empty method to be used to force load this class into the runtime.
 */
+ (void)doNothingButForceLoadTheClass;

@end

NS_ASSUME_NONNULL_END

#endif
