//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

@interface ANHApplicationProvider : NSObject

/**
 * Get the Shared Application from either NSApplication (MacOS) or UIApplication.
 *
 * @return The shared application.
 */
#if TARGET_OS_OSX
+ (NSApplication *)sharedApplication;
#else
+ (UIApplication *)sharedApplication;
#endif

/**
 * Get the App Delegate.
 *
 * @return The delegate of the app object or nil if not accessible.
 */
#if TARGET_OS_OSX
+ (id<NSApplicationDelegate>)sharedAppDelegate;
#else
+ (id<UIApplicationDelegate>)sharedAppDelegate;
#endif

@end
