

//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHNotificationHub.h"
#import "ANHService+Private.h"
#import <Foundation/Foundation.h>
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ANHConnection;
@class ANHDebounceClient;
@class ANHInstallation;
@class ANHInstallationClient;
@class ANHNotificationHubOptions;

@protocol ANHCustomApplicationDelegate;
@protocol ANHInstallationManagementDelegate;

#if TARGET_OS_OSX
@interface ANHNotificationHub () <NSUserNotificationCenterDelegate>
#else
@interface ANHNotificationHub ()
#endif

/**
 * Method registers notification settings and an application for remote notifications.
 */
- (void)registerForRemoteNotifications;

/**
 * Method to reset the singleton when running unit tests only. So calling sharedInstance returns a fresh instance.
 */
+ (void)resetSharedInstance;

@property (nonatomic, strong) ANHNotificationHubOptions *options;

#if TARGET_OS_OSX

/**
 * The original NSUserNotificationCenterDelegate.
 */
@property(nonatomic) id<NSUserNotificationCenterDelegate> originalUserNotificationCenterDelegate;

/**
 * Method to return a context for observing delegate changes.
 */
+ (void *)userNotificationCenterDelegateContext;

/**
 * Observer to register user notification center delegate when application launches.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

/**
 * Method that is called by NSUserNotificationCenter when its delegate changes.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
#endif

NS_ASSUME_NONNULL_END

@end
