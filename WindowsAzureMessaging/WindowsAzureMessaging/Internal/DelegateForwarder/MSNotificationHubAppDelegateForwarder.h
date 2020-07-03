//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSDelegateForwarder.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kMSAppDelegateForwarderEnabledKey = @"NHAppDelegateForwarderEnabled";

@interface MSNotificationHubAppDelegateForwarder : MSDelegateForwarder

/**
 * This is an empty method to be used to force load this class into the runtime.
 */
+(void)doNothingButForceLoadTheClass;

@end

NS_ASSUME_NONNULL_END
