// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

#import "MSApplication.h"
#import "MSNotificationHub.h"
#import "MSNotificationHubAppDelegateForwarder.h"

static dispatch_once_t swizzlingOnceToken;

// Singleton instance.
static MSNotificationHubAppDelegateForwarder *sharedInstance = nil;

@implementation MSNotificationHubAppDelegateForwarder

+ (void)load {
    [[MSNotificationHubAppDelegateForwarder sharedInstance]
      setEnabledFromPlistForKey:kMSAppDelegateForwarderEnabledKey];

    // Register selectors to swizzle for Push.
    [[MSNotificationHubAppDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(application:
                                                                                didRegisterForRemoteNotificationsWithDeviceToken:)];
    [[MSNotificationHubAppDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(application:
                                                                                didFailToRegisterForRemoteNotificationsWithError:)];
    [[MSNotificationHubAppDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(application:didReceiveRemoteNotification:)];
#if !TARGET_OS_OSX
    [[MSNotificationHubAppDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(application:
                                                                                didReceiveRemoteNotification:fetchCompletionHandler:)];
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
    return [MSApplication class];
}

- (dispatch_once_t *)swizzlingOnceToken {
  return &swizzlingOnceToken;
}

#pragma mark - Custom Application

- (void)custom_setDelegate:(id<MSApplicationDelegate>)delegate  {

  // Swizzle only once.
  static dispatch_once_t delegateSwizzleOnceToken;
  dispatch_once(&delegateSwizzleOnceToken, ^{
      // Swizzle the delegate object before it's actually set.
      [[MSNotificationHubAppDelegateForwarder sharedInstance] swizzleOriginalDelegate:delegate];
  });

    // Forward to the original `setDelegate:` implementation.
    IMP originalImp = [MSNotificationHubAppDelegateForwarder sharedInstance].originalSetDelegateImp;
    if (originalImp) {
        ((void (*)(id, SEL, id<MSApplicationDelegate>))originalImp)(self, _cmd, delegate);
    }
}

#pragma mark - Custom UIApplication

- (void)custom_application:(MSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    IMP originalImp = NULL;

    // Forward to the original delegate.
    [[MSNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    
    if (originalImp) {
      ((void (*)(id, SEL, MSApplication *, NSData *))originalImp)(self, _cmd, application, deviceToken);
    }
    
    // Then, forward to Push
    [MSNotificationHub didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)custom_application:(MSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    IMP originalImp = NULL;
    
    // Forward to the original delegate.
    [[MSNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, MSApplication *, NSError *))originalImp)(self, _cmd, application, error);
    }

    // Then, forward to Push
    [MSNotificationHub didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)custom_application:(MSApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    IMP originalImp = NULL;

    // Forward to the original delegate.
    [[MSNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, MSApplication *, NSDictionary *))originalImp)(self, _cmd, application, userInfo);
    }
    
    // Then, forward to Push
    [MSNotificationHub didReceiveRemoteNotification:userInfo];
}

#if !TARGET_OS_OSX

- (void)custom_application:(UIApplication *)application
  didReceiveRemoteNotification:(NSDictionary *)userInfo
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    IMP originalImp = NULL;
    
    // Forward to the original delegate.
    [[MSNotificationHubAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, MSApplication *, NSDictionary *, void (^)(UIBackgroundFetchResult)))originalImp)(self, _cmd, application, userInfo, completionHandler);
    }
    
    // Then, forward to Push
    [MSNotificationHub didReceiveRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}

#endif

@end
