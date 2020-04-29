// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "MSNotificationHubAppDelegate.h"
#import "MSNotificationHub.h"

// Singleton
static MSNotificationHubAppDelegate *sharedInstance = nil;
static IMP originalSetDelegateImp = nil;
static dispatch_once_t onceToken;

@implementation MSNotificationHubAppDelegate

@synthesize enabled;

+ (void)load {
    [[MSNotificationHubAppDelegate sharedInstance] setEnabledFromPlistForKey:@"AppDelegateForwardingEnabled"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[MSNotificationHubAppDelegate sharedInstance] swizzleImplForMethod: @selector(setDelegate:) inClass:[UIApplication class] from:[MSNotificationHubAppDelegate class] forDelegate:YES];
    });
}

- (instancetype)init {
    self = [super init];
    
    return self;
}

+ (instancetype)sharedInstance {
  dispatch_once(&onceToken, ^{
    if (sharedInstance == nil) {
      sharedInstance = [self new];
    }
  });
  return sharedInstance;
}

- (void)custom_setDelegate:(id <UIApplicationDelegate>)delegate {
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[MSNotificationHubAppDelegate sharedInstance]  swizzleImplForMethod: @selector(application: didRegisterForRemoteNotificationsWithDeviceToken:) inClass:[delegate class] from:[MSNotificationHubAppDelegate class] forDelegate:NO];
        [[MSNotificationHubAppDelegate sharedInstance]  swizzleImplForMethod: @selector(application: didFailToRegisterForRemoteNotificationsWithError:) inClass:[delegate class] from:[MSNotificationHubAppDelegate class] forDelegate:NO];
        [[MSNotificationHubAppDelegate sharedInstance]  swizzleImplForMethod: @selector(application: didReceiveRemoteNotification:) inClass:[delegate class] from:[MSNotificationHubAppDelegate class] forDelegate:NO];
        [[MSNotificationHubAppDelegate sharedInstance]  swizzleImplForMethod: @selector(application: didReceiveRemoteNotification: fetchCompletionHandler:) inClass:[delegate class] from:[MSNotificationHubAppDelegate class] forDelegate:NO];
    });
    
    ((void (*)(id, SEL, id<UIApplicationDelegate>))originalSetDelegateImp)(self, _cmd, delegate);
}

-(void) swizzleImplForMethod:(SEL)originalSelector inClass:(Class)class from:(Class)swizzledClass forDelegate:(BOOL) isDelegate {
    if(self.enabled) {
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        
        SEL swizzledSelector = NSSelectorFromString([@"custom_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
        
        if (isDelegate) {
            originalSetDelegateImp = class_getMethodImplementation(class, originalSelector);;
        }
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod && originalMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

- (void)setEnabledFromPlistForKey:(NSString *)plistKey {
    NSNumber *forwarderEnabledNum = [NSBundle.mainBundle objectForInfoDictionaryKey:plistKey];
    BOOL forwarderEnabled = forwarderEnabledNum ? [forwarderEnabledNum boolValue] : YES;
    self.enabled = forwarderEnabled;
    if (self.enabled) {
        NSLog(@"Delegate forwarder for info.plist key '%@' enabled. It may use swizzling.", plistKey);
    } else {
        NSLog(@"Delegate forwarder for info.plist key '%@' disabled. It won't use swizzling.", plistKey);
    }
}

- (void) custom_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [MSNotificationHub didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void) custom_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [MSNotificationHub didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void) custom_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [MSNotificationHub didReceiveRemoteNotification:userInfo];
}

- (void)custom_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  BOOL result = [MSNotificationHub didReceiveRemoteNotification:userInfo];
  if (result) {
    completionHandler(UIBackgroundFetchResultNewData);
  } else {
    completionHandler(UIBackgroundFetchResultNoData);
  }
}

@end
