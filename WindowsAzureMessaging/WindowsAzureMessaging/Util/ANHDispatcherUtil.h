//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

#define ANH_DISPATCH_SELECTOR(declaration, object, selectorName, ...)                                                                       \
    ({                                                                                                                                     \
        SEL selector = NSSelectorFromString(@ #selectorName);                                                                              \
        IMP impl = [object methodForSelector:selector];                                                                                    \
        (declaration impl)(object, selector, ##__VA_ARGS__);                                                                               \
    })

@interface ANHDispatcherUtil : NSObject

+ (void)performBlockOnMainThread:(void (^)(void))block;

@end
