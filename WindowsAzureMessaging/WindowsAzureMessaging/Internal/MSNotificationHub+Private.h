//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHub.h"
#import "MSNotificationHubDelegate.h"
#import "MSDebounceInstallationManager.h"
#import <Foundation/Foundation.h>

@protocol MSCustomApplicationDelegate;

#if TARGET_OS_OSX
@interface MSNotificationHub () <NSUserNotificationCenterDelegate>
#else
@interface MSNotificationHub ()
#endif

@property(nonatomic) id<MSNotificationHubDelegate> delegate;

@property(nonatomic) MSDebounceInstallationManager *debounceInstallationManager;

#if TARGET_OS_OSX
@property(nonatomic) id<NSUserNotificationCenterDelegate> originalUserNotificationCenterDelegate;
#endif

+ (void)resetSharedInstance;

- (NSString *)convertTokenToString:(NSData *)token;

- (void)registerForRemoteNotifications;

#if TARGET_OS_OSX

+ (void *)userNotificationCenterDelegateContext;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
#endif

@end
