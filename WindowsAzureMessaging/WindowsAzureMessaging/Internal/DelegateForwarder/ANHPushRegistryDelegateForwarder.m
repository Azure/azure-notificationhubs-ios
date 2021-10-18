//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#include "ANHPushRegistryDelegateForwarder.h"
#include "ANHAsync.h"
#include "ANHVoIPNotificationHub.h"
#import <PushKit/PushKit.h>

@implementation ANHPushRegistryDelegateForwarder

static dispatch_once_t swizzlingOnceToken;
static ANHPushRegistryDelegateForwarder *sharedInstance = nil;

+ (void)load {
    [[ANHPushRegistryDelegateForwarder sharedInstance]
        setEnabledFromPlistForKey:kANHPushRegistryDelegateForwarderEnabledKey];
    
    if (@available(iOS 8.0, tvOS 13.0, watchOS 6.0, macOS 10.15, macCatalyst 13.0, *)) {
        [[ANHPushRegistryDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(pushRegistry:didInvalidatePushTokenForType:)];
        [[ANHPushRegistryDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(pushRegistry:didUpdatePushCredentials:forType:)];
        [[ANHPushRegistryDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(pushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:)];
        [[ANHPushRegistryDelegateForwarder sharedInstance] addDelegateSelectorToSwizzle:@selector(pushRegistry:didReceiveIncomingPushWithPayload:forType:)];
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
    if (@available(iOS 8.0, tvOS 13.0, watchOS 6.0, macOS 10.15, macCatalyst 13.0, *)) {
        return [PKPushRegistry class];
    }
    return nil;
}

- (dispatch_once_t *)swizzlingOnceToken {
    return &swizzlingOnceToken;
}

#pragma mark - Custom Application

- (void)custom_setDelegate:(id<PKPushRegistryDelegate>)delegate API_AVAILABLE(macos(10.15), macCatalyst(13.0), ios(8.0), watchos(6.0), tvos(13.0)) {
    
    // Swizzle only once.
    static dispatch_once_t delegateSwizzleOnceToken;
    dispatch_once(&delegateSwizzleOnceToken, ^{
      // Swizzle the delegate object before it's actually set.
      [[ANHPushRegistryDelegateForwarder sharedInstance] swizzleOriginalDelegate:delegate];
    });

    // Forward to the original `setDelegate:` implementation.
    IMP originalImp = [ANHPushRegistryDelegateForwarder sharedInstance].originalSetDelegateImp;
    if (originalImp) {
        ((void (*)(id, SEL, id<PKPushRegistryDelegate>))originalImp)(self, _cmd, delegate);
    }
}

#pragma mark - Custom PKPushRegistryDelegate

- (void)custom_pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type API_DEPRECATED_WITH_REPLACEMENT("-pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion", ios(8.0, 11.0), macCatalyst(8.0, 11.0)) API_UNAVAILABLE(macos, watchos, tvos) {
    
    IMP originalImp = NULL;
    [[ANHPushRegistryDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    
    if (originalImp) {
        ((void (*)(id, SEL, PKPushRegistry *, PKPushPayload *, PKPushType))originalImp)(self, _cmd, registry, payload, type);
    }
    
    if (type == PKPushTypeVoIP) {
        [[ANHVoIPNotificationHub sharedInstance] didReceiveIncomingPushWithPayload:payload.dictionaryPayload withCompletionHandler:^{
            
        }];
    }
}

- (void)custom_pushRegistry:(PKPushRegistry *)registry
didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type
withCompletionHandler:(void (^)(void))completion API_AVAILABLE(macos(10.15), macCatalyst(13.0), ios(11.0), watchos(6.0), tvos(13.0)) ANH_SWIFT_DISABLE_ASYNC {
    
    IMP originalImp = NULL;
    [[ANHPushRegistryDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    
    if (originalImp) {
        ((void (*)(id, SEL, PKPushRegistry *, PKPushPayload *, PKPushType, void (^)(void)))originalImp)(self, _cmd, registry, payload, type, completion);
    }
    
    [[ANHVoIPNotificationHub sharedInstance] didReceiveIncomingPushWithPayload:payload.dictionaryPayload withCompletionHandler:completion];
    
    if (!originalImp) {
        completion();
    }
}

- (void)custom_pushRegistry:(PKPushRegistry *)registry
    didUpdatePushCredentials:(PKPushCredentials *)pushCredentials {
    
    IMP originalImp = NULL;
    [[ANHPushRegistryDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    
    if (originalImp) {
        ((void (*)(id, SEL, PKPushRegistry *, PKPushCredentials *))originalImp)(self, _cmd, registry, pushCredentials);
    }
    
    [[ANHVoIPNotificationHub sharedInstance] didUpdatePushCredentials:pushCredentials.token];
}

- (void)custom_pushRegistry:(PKPushRegistry *)registry
didInvalidatePushTokenForType:(PKPushType)type {
    
    IMP originalImp = NULL;
    [[ANHPushRegistryDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
    
    if (originalImp) {
        ((void (*)(id, SEL, PKPushRegistry *, PKPushType))originalImp)(self, _cmd, registry, type);
    }
    
    [[ANHVoIPNotificationHub sharedInstance] didInvalidatePushToken];
}

@end
