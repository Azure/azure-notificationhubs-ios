//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHNotificationHub+Private.h"
#import "ANHApplication.h"
#import "ANHConnection.h"
#import "ANHDebounceClient.h"
#import "ANHDelegateForwarder.h"
#import "ANHLogger+Private.h"
#import "ANHInstallation.h"
#import "ANHInstallationClient.h"
#import "ANHLocalStorage.h"
#import "ANHNotificationHubAppDelegateForwarder.h"
#import "ANHUserNotificationCenterDelegateForwarder.h"
#import "ANHNotificationHubMessage+Private.h"
#import "ANHNotificationHubOptions.h"
#import "ANH_Errors.h"

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#else
#import <UIKit/UIKit.h>
#endif

#if __has_include(<UserNotifications/UserNotifications.h>)
#import <UserNotifications/UserNotifications.h>
#else
#define NO_USERNOTIFICATIONS
#endif

#if TARGET_OS_OSX
static NSString * const kANHUserNotificationCenterDelegateKey = @"delegate";
#endif
#if TARGET_OS_OSX
static void *UserNotificationCenterDelegateContext = &UserNotificationCenterDelegateContext;
#endif

@implementation ANHNotificationHub

// Singleton
static ANHNotificationHub *sharedInstance = nil;
static dispatch_once_t onceToken;

- (instancetype)init {
    if ((self = [super init])) {

        // Force load for swizzling
        [ANHNotificationHubAppDelegateForwarder doNothingButForceLoadTheClass];
        [ANHUserNotificationCenterDelegateForwarder doNothingButForceLoadTheClass];
        
        self.debounceClient = [[ANHDebounceClient alloc] initWithInterval: 2];

#if TARGET_OS_OSX
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];

        /*
         * If there is a user notification center delegate already set by a customer before starting Push, assign the delegate to custom
         * user notification center delegate.
         */
        if (center.delegate) {
            id<NSUserNotificationCenterDelegate> centerDelegate = center.delegate;
            _originalUserNotificationCenterDelegate = centerDelegate;
        }

        // Set a delegate that will forward notifications to Push as well as a customer's delegate.
        center.delegate = self;

        // Observe delegate property changes.
        [center addObserver:self
                 forKeyPath:kANHUserNotificationCenterDelegateKey
                    options:NSKeyValueObservingOptionNew
                    context:UserNotificationCenterDelegateContext];
#endif
    }

    return self;
}

#if TARGET_OS_OSX
- (void)dealloc {
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeObserver:self
                                                                  forKeyPath:kANHUserNotificationCenterDelegateKey
                                                                     context:UserNotificationCenterDelegateContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == UserNotificationCenterDelegateContext && [keyPath isEqualToString:kANHUserNotificationCenterDelegateKey]) {
        id delegate = [change objectForKey:NSKeyValueChangeNewKey];
        if (delegate != self) {
            self.originalUserNotificationCenterDelegate = delegate;
            [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (void *)userNotificationCenterDelegateContext {
    return UserNotificationCenterDelegateContext;
}

#endif

#pragma mark Singleton and Initialization

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
      if (sharedInstance == nil) {
          sharedInstance = [self new];
      }
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    // Resets the once_token so dispatch_once will run again
    onceToken = 0;
    sharedInstance = nil;
}

- (BOOL)startWithConnectionString:(NSString *)connectionString hubName:(NSString *)notificationHubName error:(NSError *__autoreleasing  _Nullable *)error {
    ANHNotificationHubOptions *options = [[ANHNotificationHubOptions alloc] init];
    return [self startWithConnectionString:connectionString hubName:notificationHubName options:options error:error];
}

- (BOOL)startWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName options:(ANHNotificationHubOptions *)options error:(NSError *__autoreleasing  _Nullable *)error {
    
    ANHConnection *connection = [[ANHConnection alloc] initWithConnectionString:connectionString];
    if (!connection) {
        if (error) {
            NSDictionary *userInfo = @{
               NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid connection string.", nil),
               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid connection string format.", nil),
               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Invalid connection string. Check the format of the connection string.", nil)
            };
            *error = [NSError errorWithDomain:kANHErrorDomain code:ANHConnectionErrorCode userInfo:userInfo];
            ANHLogError(kANHLogDomain, @"Invalid connection string");
            return NO;
        }
    }
    
    self.connectionString = connection;
    self.options = options;
    self.installationClient = [[ANHInstallationClient alloc] initWithConnectionString:connection hubName:hubName];
    
    [self registerForRemoteNotifications];
    
    return YES;
}

- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate {
    ANHNotificationHubOptions *options = [[ANHNotificationHubOptions alloc] init];
    [self startWithInstallationManagement:managementDelegate options:options];
}

- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate options:(ANHNotificationHubOptions *)options {
    self.managementDelegate = managementDelegate;
    self.options = options;
    
    [self registerForRemoteNotifications];
}

- (void)registerForRemoteNotifications {
    if (@available(iOS 10.0, maccatalyst 13.0, tvOS 10.0, macOS 10.14, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions authOptions = self.options.authorizationOptions;
        
        [center requestAuthorizationWithOptions:authOptions
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
            
            id<ANHNotificationHubDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(notificationHub:didRequestAuthorization:error:)]) {
                [delegate notificationHub:self didRequestAuthorization:granted error:error];
            } else {
                if (granted) {
                    ANHLogInfo(kANHLogDomain, @"Push notifications authorization was granted.");
                } else {
                    ANHLogInfo(kANHLogDomain, @"Push notifications authorization was denied.");
                }
                if (error) {
                    ANHLogError(kANHLogDomain, @"Push notifications authorization request has been finished with error: %@",
                          error.localizedDescription);
                }
            }
        }];
        
        [[ANHApplication sharedApplication] registerForRemoteNotifications];
    } else {
#if TARGET_OS_OSX
        [NSApp registerForRemoteNotificationTypes:(NSRemoteNotificationTypeSound | NSRemoteNotificationTypeBadge | NSRemoteNotificationTypeAlert)];
#elif TARGET_OS_IPHONE
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        
        UIUserNotificationType allNotificationTypes =
            (UIUserNotificationType)(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
#pragma GCC diagnostic pop

        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    }
}

#pragma mark - ANHService Implementation

- (NSString *)currentInstallationKey {
    return kANHInstallationKey;
}

- (NSString *)lastInstallationKey {
    return kANHLastInstallationKey;
}

#pragma mark - ApplicationDelegate Methods

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *pushToken = [self convertTokenToString:deviceToken];
    ANHLogInfo(kANHLogDomain, @"Registered for push notifications with token: %@", pushToken);

    ANHInstallation *installation = [self installation];

    if ([pushToken isEqualToString:installation.pushChannel]) {
        return;
    }

    installation.pushChannel = pushToken;
    self.pushChannel = pushToken;
    [self upsertInstallation:installation];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    ANHLogError(kANHLogDomain, @"didFailToRegisterForRemoteNotificationsWithError: %@", [error localizedDescription]);
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self didReceiveRemoteNotification:userInfo fromUserNotification:NO];
}

#if TARGET_OS_OSX
- (BOOL)didReceiveUserNotification:(NSUserNotification *)notification {
    if (notification) {
        [self didReceiveRemoteNotification:notification.userInfo fromUserNotification:YES];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];

        // The delivered notification should be removed.
        [center removeDeliveredNotification:notification];
        return YES;
    }
    return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self didReceiveUserNotification:[notification.userInfo objectForKey:NSApplicationLaunchUserNotificationKey]];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [self didReceiveUserNotification:notification];
    if ([self.originalUserNotificationCenterDelegate respondsToSelector:@selector(userNotificationCenter:didActivateNotification:)]) {
        [self.originalUserNotificationCenterDelegate userNotificationCenter:center didActivateNotification:notification];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {

    // Testing if the selector is defined in NSUserNotificationCenterDelegate or not.
    struct objc_method_description hasMethod =
        protocol_getMethodDescription(@protocol(NSUserNotificationCenterDelegate), [anInvocation selector], NO, YES);
    if (hasMethod.name != NULL && [self.originalUserNotificationCenterDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.originalUserNotificationCenterDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}
#endif

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fromUserNotification:(BOOL)userNotification {

#if !TARGET_OS_OSX
    (void)userNotification;
#endif

    ANHNotificationHubMessage *message = [[ANHNotificationHubMessage alloc] initWithUserInfo:userInfo];

#if TARGET_OS_OSX
    if ([NSApp isActive] || userNotification) {
#endif
        [self didReceivePushNotification:message];
#if TARGET_OS_OSX
    } else {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = (NSString *)message.title;
        notification.informativeText = (NSString *)message.body;
        notification.userInfo = message.userInfo;
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center deliverNotification:notification];
    }
#endif
}

- (void)didReceivePushNotification:(ANHNotificationHubMessage *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
      id<ANHNotificationHubDelegate> delegate = self.delegate;
      if ([delegate respondsToSelector:@selector(notificationHub:didReceivePushNotification:)]) {
          [delegate notificationHub:self didReceivePushNotification:notification];
      }
    });
}

@end
