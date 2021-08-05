// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

#import "ANHAsync.h"
#import "ANHApplication.h"
#import "ANHNotificationHubAppDelegateForwarder.h"
#import "MSNotificationHub.h"

static dispatch_once_t swizzlingOnceToken;

// Singleton instance.
static ANHNotificationHubAppDelegateForwarder *sharedInstance = nil;

@implementation ANHNotificationHubAppDelegateForwarder

+ (void)load {
    [[ANHNotificationHubAppDelegateForwarder sharedInstance] setEnabledFromPlistForKey:kANHAppDelegateForwarderEnabledKey];

    // Register selectors to swizzle for Push.
    [[ANHNotificationHubAppDelegateForwarder sharedInstance]
        addDelegateSelectorToSwizzle:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)];
    [[ANHNotificationHubAppDelegateForwarder sharedInstance]
        addDelegateSelectorToSwizzle:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)];
    [[ANHNotificationHubAppDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(application:
                                                                                              didReceiveRemoteNotification:)];
#if !TARGET_OS_OSX
    [[ANHNotificationHubAppDelegateForwarder sharedInstance]
        addDelegateSelectorToSwizzle:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
#endif
}

+ (void)doNothingButForceLoadTheClass {
    // This method doesn't need to do anything it's purpose is just to force load this class into the runtime.
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    sharedInstance = [self new];
}

- (Class)originalClassForSetDelegate {
    return [ANHApplication class];
}

- (dispatch_once_t *)swizzlingOnceToken {
    return &swizzlingOnceToken;
}

#pragma mark - Custom Application

- (void)custom_setDelegate:(id<ANHApplicationDelegate>)delegate {

    // Swizzle only once.
    static dispatch_once_t delegateSwizzleOnceToken;
    dispatch_once(&delegateSwizzleOnceToken, ^{
      // Swizzle the delegate object before it's actually set.
      [[ANHNotificationHubAppDelegateForwarder sharedInstance] swizzleOriginalDelegate:delegate];
    });

    // Forward to the original `setDelegate:` implementation.
    IMP originalImp = [ANHNotificationHubAppDelegateForwarder sharedInstance].originalSetDelegateImp;
    if (originalImp) {
        ((void (*)(id, SEL, id<ANHApplicationDelegate>))originalImp)(self, _cmd, delegate);
    }
}

#pragma mark - Custom UIApplication

- (void)custom_application:(ANHApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    IMP originalImp = NULL;

    // Forward to the original delegate.
    [[ANHNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];

    if (originalImp) {
        ((void (*)(id, SEL, ANHApplication *, NSData *))originalImp)(self, _cmd, application, deviceToken);
    }

    // Then, forward to Push
    [MSNotificationHub didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)custom_application:(ANHApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    IMP originalImp = NULL;

    // Forward to the original delegate.
    [[ANHNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, ANHApplication *, NSError *))originalImp)(self, _cmd, application, error);
    }

    // Then, forward to MSNotificationHub
    [MSNotificationHub didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)custom_application:(ANHApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    IMP originalImp = NULL;

    // Forward to the original delegate.
    [[ANHNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, ANHApplication *, NSDictionary *))originalImp)(self, _cmd, application, userInfo);
    }

    // Then, forward to MSNotificationHub
    [MSNotificationHub didReceiveRemoteNotification:userInfo];
}

#if !TARGET_OS_OSX

- (void)custom_application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler ANH_SWIFT_DISABLE_ASYNC {
    IMP originalImp = NULL;

    // Forward to the original delegate.
    [[ANHNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, ANHApplication *, NSDictionary *, void (^)(UIBackgroundFetchResult)))originalImp)(self, _cmd, application,
                                                                                                              userInfo, completionHandler);
    }

    // Then, forward to MSNotificationHub
    [MSNotificationHub didReceiveRemoteNotification:userInfo];

    if (!originalImp) {

        // No original implementation, we have to call the completion handler ourselves with the default behavior.
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

#endif

@end
