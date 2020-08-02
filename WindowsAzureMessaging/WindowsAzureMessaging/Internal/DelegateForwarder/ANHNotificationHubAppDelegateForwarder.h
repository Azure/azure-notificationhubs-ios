//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHDelegateForwarder.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kANHAppDelegateForwarderEnabledKey = @"NHAppDelegateForwarderEnabled";

@interface ANHNotificationHubAppDelegateForwarder : ANHDelegateForwarder

/**
 * This is an empty method to be used to force load this class into the runtime.
 */
+ (void)doNothingButForceLoadTheClass;

@end

NS_ASSUME_NONNULL_END
