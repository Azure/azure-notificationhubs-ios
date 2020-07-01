//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHub.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MSCustomApplicationDelegate;

#if TARGET_OS_OSX
@interface MSNotificationHub () <NSUserNotificationCenterDelegate>
#else
@interface MSNotificationHub ()
#endif

/**
 * Method converts NSData to NSString.
 *
 * @param token The push token.
 */
- (NSString *)convertTokenToString:(NSData *)token;

/**
 * Method registers notification settings and an application for remote notifications.
 */
- (void)registerForRemoteNotifications;

/**
* Method to reset the singleton when running unit tests only. So calling sharedInstance returns a fresh instance.
*/
+ (void)resetSharedInstance;

#if TARGET_OS_OSX
@property(nonatomic) id<NSUserNotificationCenterDelegate> originalUserNotificationCenterDelegate;
#endif

@property(nonatomic, nullable) id<MSNotificationHubDelegate> delegate;

@property(nonatomic, weak, nullable) id<MSInstallationEnrichmentDelegate> enrichmentDelegate;
@property(nonatomic, weak, nullable) id<MSInstallationManagementDelegate> managementDelegate;
@property(nonatomic, weak, nullable) id<MSInstallationLifecycleDelegate> lifecycleDelegate;

#if TARGET_OS_OSX

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
