//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHApplicationProvider.h"

@implementation ANHApplicationProvider

#if TARGET_OS_OSX
+ (NSApplication *)sharedApplication {

    // Compute selector at runtime for more discretion.
    SEL sharedAppSel = NSSelectorFromString(@"sharedApplication");
    return ((NSApplication * (*)(id, SEL))[[NSApplication class] methodForSelector:sharedAppSel])([NSApplication class], sharedAppSel);
}
#else
+ (UIApplication *)sharedApplication {

    // Compute selector at runtime for more discretion.
    SEL sharedAppSel = NSSelectorFromString(@"sharedApplication");
    return ((UIApplication * (*)(id, SEL))[[UIApplication class] methodForSelector:sharedAppSel])([UIApplication class], sharedAppSel);
}
#endif

#if TARGET_OS_OSX
+ (id<NSApplicationDelegate>)sharedAppDelegate {
    return [self sharedApplication].delegate;
}
#else
+ (id<UIApplicationDelegate>)sharedAppDelegate {
    return [self sharedApplication].delegate;
}
#endif

@end
