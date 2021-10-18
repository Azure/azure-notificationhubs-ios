//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_PUSHREGISTRY_DELEGATE_FORWARDER_h
#define ANH_PUSHREGISTRY_DELEGATE_FORWARDER_h

#import "ANHDelegateForwarder.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kANHPushRegistryDelegateForwarderEnabledKey = @"NHPushRegistryDelegateForwarderEnabledKey";

@interface ANHPushRegistryDelegateForwarder : ANHDelegateForwarder

+ (void)doNothingButForceLoadTheClass;

@end

NS_ASSUME_NONNULL_END

#endif
