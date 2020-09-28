// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import <Availability.h>
#import <UserNotifications/UserNotifications.h>

#import "ANHUserNotificationCenterDelegateForwarder.h"
#import "MSNotificationHub.h"

static dispatch_once_t swizzlingOnceToken;

// Singleton instance.
static ANHUserNotificationCenterDelegateForwarder *sharedInstance = nil;

@implementation ANHUserNotificationCenterDelegateForwarder

+ (void)load {
    [[ANHUserNotificationCenterDelegateForwarder sharedInstance]
        setEnabledFromPlistForKey:kANHUserNotificationCenterDelegateForwarderEnabledKey];

    if (@available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.14, macCatalyst 13.0, *)) {
        [[ANHUserNotificationCenterDelegateForwarder sharedInstance]
            addDelegateSelectorToSwizzle:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)];
        [[ANHUserNotificationCenterDelegateForwarder sharedInstance]
            addDelegateSelectorToSwizzle:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)];
    }
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
    if (@available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.14, macCatalyst 13.0, *)) {
        return [UNUserNotificationCenter class];
    }
    return nil;
}

- (dispatch_once_t *)swizzlingOnceToken {
    return &swizzlingOnceToken;
}

#pragma mark - Custom Application

- (void)custom_setDelegate:(id<UNUserNotificationCenterDelegate>)delegate API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0)) {

    // Swizzle only once.
    static dispatch_once_t delegateSwizzleOnceToken;
    dispatch_once(&delegateSwizzleOnceToken, ^{
      // Swizzle the delegate object before it's actually set.
      [[ANHUserNotificationCenterDelegateForwarder sharedInstance] swizzleOriginalDelegate:delegate];
    });

    // Forward to the original `setDelegate:` implementation.
    IMP originalImp = [ANHUserNotificationCenterDelegateForwarder sharedInstance].originalSetDelegateImp;
    if (originalImp) {
        ((void (*)(id, SEL, id<UNUserNotificationCenterDelegate>))originalImp)(self, _cmd, delegate);
    }
}

#pragma mark - Custom UNUserNotificationCenterDelegate

- (void)custom_userNotificationCenter:(UNUserNotificationCenter *)center
              willPresentNotification:(UNNotification *)notification
                withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
    API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0)) API_UNAVAILABLE(tvos) {
    IMP originalImp = NULL;

    /*
     * First, forward to the original delegate, customers can leverage the completion handler later in their Push callback.
     * It's now a responsibility of the original delegate to call the completion handler.
     */
    [[ANHUserNotificationCenterDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, UNUserNotificationCenter *, UNNotification *, void (^)(UNNotificationPresentationOptions options)))originalImp)(
            self, _cmd, center, notification, completionHandler);
    }

    // Then, forward to MSNotificationHub
    [MSNotificationHub didReceiveRemoteNotification:notification.request.content.userInfo];
    if (!originalImp) {

        // No original implementation, we have to call the completion handler ourselves with the default behavior.
        completionHandler(UNNotificationPresentationOptionNone);
    }
}

- (void)custom_userNotificationCenter:(UNUserNotificationCenter *)center
       didReceiveNotificationResponse:(UNNotificationResponse *)response
                withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0), tvos(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0)) {
    IMP originalImp = NULL;

    /*
     * First, forward to the original delegate, customers can leverage the completion handler later in their Push callback.
     * It's now a responsability of the original delegate to call the completion handler.
     */
    [[ANHUserNotificationCenterDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    if (originalImp) {
        ((void (*)(id, SEL, UNUserNotificationCenter *, UNNotificationResponse *, void (^)(void)))originalImp)(self, _cmd, center, response,
                                                                                                               completionHandler);
    }

    // Then, forward to MSNotificationHub
    [MSNotificationHub didReceiveRemoteNotification:response.notification.request.content.userInfo];
    if (!originalImp) {

        // No original implementation, we have to call the completion handler ourselves.
        completionHandler();
    }
}

@end
