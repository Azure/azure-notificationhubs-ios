//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#else
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#endif

#import "MSDebounceInstallationManager.h"
#import "MSInstallation.h"
#import "MSInstallationManager.h"
#import "MSLocalStorage.h"
#import "MSNotificationHub.h"
#import "MSNotificationHubAppDelegate.h"
#import "MSUserNotificationCenterDelegate.h"
#import "MSNotificationHubMessage.h"
#import "MSNotificationHubPrivate.h"
#import "MSTokenProvider.h"

#if TARGET_OS_OSX
static NSString *const kMSUserNotificationCenterDelegateKey = @"delegate";
#endif

// Singleton
static MSNotificationHub *sharedInstance = nil;
static dispatch_once_t onceToken;
#if TARGET_OS_OSX
static void *UserNotificationCenterDelegateContext = &UserNotificationCenterDelegateContext;
#endif

@implementation MSNotificationHub

- (instancetype)init {
    if ((self = [super init])) {
#if TARGET_OS_OSX
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];

        /*
         * If there is a user notification center delegate already set by a customer before starting Push, assign the delegate to custom
         * user notification center delegate.
         */
        if (center.delegate) {
            _originalUserNotificationCenterDelegate = center.delegate;
        }

        // Set a delegate that will forward notifications to Push as well as a customer's delegate.
        center.delegate = self;

        // Observe delegate property changes.
        [center addObserver:self
                 forKeyPath:kMSUserNotificationCenterDelegateKey
                    options:NSKeyValueObservingOptionNew
                    context:UserNotificationCenterDelegateContext];
#endif
    }

    return self;
}

#if TARGET_OS_OSX
- (void)dealloc {
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeObserver:self
                                                                  forKeyPath:kMSUserNotificationCenterDelegateKey
                                                                     context:UserNotificationCenterDelegateContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == UserNotificationCenterDelegateContext && [keyPath isEqualToString:kMSUserNotificationCenterDelegateKey]) {
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
    onceToken = 0;
    sharedInstance = nil;
}

+ (void)startWithConnectionString:(NSString *)connectionString hubName:(NSString *)notificationHubName {
    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:connectionString
                                                                                                 hubName:notificationHubName];

    [[MSNotificationHub sharedInstance]
        setDebounceInstallationManager:[[MSDebounceInstallationManager alloc] initWithInterval:2 installationManager:installationManager]];

    [[MSNotificationHub sharedInstance] registerForRemoteNotifications];
}

- (void)setDebounceInstallationManager:(MSDebounceInstallationManager *)debounceInstallationManager {
    _debounceInstallationManager = debounceInstallationManager;
}

- (void)registerForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions authOptions =
        (UNAuthorizationOptions)(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge);
    [center
        requestAuthorizationWithOptions:authOptions
                      completionHandler:^(BOOL granted, NSError *_Nullable error) {
                        if (granted) {
                            NSLog(@"Push notifications authorization was granted.");
                        } else {
                            NSLog(@"Push notifications authorization was denied.");
                        }
                        if (error) {
                            NSLog(@"Push notifications authorization request has been finished with error: %@", error.localizedDescription);
                        }
                      }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark UIApplicationDelegate

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[MSNotificationHub sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[MSNotificationHub sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[MSNotificationHub sharedInstance] didReceiveRemoteNotification:userInfo fromUserNotification:NO];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fromUserNotification:(BOOL)userNotification {

#if !TARGET_OS_OSX
    (void)userNotification;
#endif

    // Do not send message if SDK is disabled
    if (![self isEnabled]) {
        NSLog(@"Notification received while the SDK was ]enabled but it is disabled now, discard the notification.");
        return;
    }

#if TARGET_OS_OSX
    if ([NSApp isActive] || userNotification) {
#endif
        MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithUserInfo:userInfo];

        [self didReceivePushNotification:message];
#if TARGET_OS_OSX
    } else {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = (NSString *)title;
        notification.informativeText = (NSString *)message;
        notification.userInfo = userInfo;
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center deliverNotification:notification];
    }
#endif
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *pushToken = [self convertTokenToString:deviceToken];
    NSLog(@"Registered for push notifications with token: %@", pushToken);

    MSInstallation *installation = [self getInstallation];

    if ([pushToken isEqualToString:installation.pushChannel]) {
        return;
    }

    installation.pushChannel = pushToken;
    [self upsertInstallation:installation];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registering for push notifications has been finished with error: %@", error.localizedDescription);
}

#pragma mark Delegate Forwarding

- (void)didReceivePushNotification:(MSNotificationHubMessage *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
      id<MSNotificationHubDelegate> delegate = self.delegate;
      if ([delegate respondsToSelector:@selector(notificationHub:didReceivePushNotification:)]) {
          [delegate notificationHub:self didReceivePushNotification:notification];
      }
    });
}

#pragma mark SDK Basics

+ (void)setEnabled:(BOOL)isEnabled {
    @synchronized([self sharedInstance]) {
        [[self sharedInstance] setEnabled:isEnabled];
    }
}

+ (BOOL)isEnabled {
    @synchronized([self sharedInstance]) {
        return [[self sharedInstance] isEnabled];
    }
}

- (void)setEnabled:(BOOL)isEnabled {
    [MSLocalStorage setEnabled:isEnabled];

    if (isEnabled) {
#if TARGET_OS_OSX
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
#endif
        [self upsertInstallation:[self getInstallation]];
        NSLog(@"Notification Hubs SDK has been enabled");
    } else {
#if TARGET_OS_OSX
        [[MSAppDelegateForwarder sharedInstance] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
#endif
        NSLog(@"Notification Hub SDK has been disabled");
    }
}

- (BOOL)isEnabled {
    return [MSLocalStorage isEnabled];
}

+ (void)setDelegate:(nullable id<MSNotificationHubDelegate>)delegate {
    [[MSNotificationHub sharedInstance] setDelegate:delegate];
}

#pragma mark Installations

+ (NSString *)getPushChannel {
    return [[MSNotificationHub sharedInstance] getPushChannel];
}

+ (NSString *)getInstallationId {
    return [[MSNotificationHub sharedInstance] getInstallationId];
}

- (NSString *)getPushChannel {
    MSInstallation *installation = [self getInstallation];
    return installation.pushChannel;
}

- (NSString *)getInstallationId {
    MSInstallation *installation = [self getInstallation];
    return installation.installationID;
}

- (MSInstallation *)getInstallation {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    if (!installation) {
        installation = [MSInstallation new];
    }

    return installation;
}

- (void)upsertInstallation:(MSInstallation *)installation {
    [MSLocalStorage upsertInstallation:installation];

    if ([self isEnabled]) {
        [_debounceInstallationManager saveInstallation:installation
            withEnrichmentHandler:^void() {
              id<MSInstallationEnrichmentDelegate> enrichmentDelegate = self.enrichmentDelegate;
              if ([enrichmentDelegate respondsToSelector:@selector(notificationHub:willEnrichInstallation:)]) {
                  [enrichmentDelegate notificationHub:self willEnrichInstallation:installation];
                  [MSLocalStorage upsertInstallation:installation];
              }
            }
            withManagementHandler:^BOOL(InstallationCompletionHandler completion) {
              id<MSInstallationManagementDelegate> managementDelegate = self.managementDelegate;
              if ([managementDelegate respondsToSelector:@selector(notificationHub:willUpsertInstallation:completionHandler:)]) {
                  [managementDelegate notificationHub:self willUpsertInstallation:installation completionHandler:completion];
                  return true;
              }

              return false;
            }
            completionHandler:^void(NSError *_Nullable error) {
              id<MSInstallationLifecycleDelegate> lifecycleDelegate = self.lifecycleDelegate;
              if (error == nil) {
                  [MSLocalStorage upsertLastInstallation:installation];
                  if ([lifecycleDelegate respondsToSelector:@selector(notificationHub:didSaveInstallation:)]) {
                      [lifecycleDelegate notificationHub:self didSaveInstallation:installation];
                  };
              } else {
                  NSLog(@"Error while creating installation: %@\n%@", error.localizedDescription, error.userInfo);
                  if ([lifecycleDelegate respondsToSelector:@selector(notificationHub:didFailToSaveInstallation:withError:)]) {
                      [lifecycleDelegate notificationHub:self didFailToSaveInstallation:installation withError:error];
                  };
              }
            }];
    }
}

#pragma mark Tags

+ (BOOL)addTag:(NSString *)tag {
    return [MSNotificationHub addTags:[NSArray arrayWithObject:tag]];
}

+ (BOOL)addTags:(NSArray<NSString *> *)tags {
    return [[MSNotificationHub sharedInstance] addTags:tags];
}

+ (void)clearTags {
    [[MSNotificationHub sharedInstance] clearTags];
}

+ (NSArray<NSString *> *)getTags {
    return [[MSNotificationHub sharedInstance] getTags];
}

+ (BOOL)removeTag:(NSString *)tag {
    return [[MSNotificationHub sharedInstance] removeTag:tag];
}

+ (BOOL)removeTags:(NSArray<NSString *> *)tags {
    return [[MSNotificationHub sharedInstance] removeTags:tags];
}

- (BOOL)addTag:(NSString *)tag {
    return [self addTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)addTags:(NSArray<NSString *> *)tags {
    MSInstallation *installation = [self getInstallation];

    if ([installation addTags:tags]) {
        [self upsertInstallation:installation];
        return YES;
    }

    return NO;
}

- (void)clearTags {
    MSInstallation *installation = [self getInstallation];

    if (installation && installation.tags && [installation.tags count] > 0) {
        [installation clearTags];
        [self upsertInstallation:installation];
    }
}

- (NSArray<NSString *> *)getTags {
    MSInstallation *installation = [self getInstallation];
    return [installation.tags allObjects];
}

- (BOOL)removeTag:(NSString *)tag {
    return [self removeTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)removeTags:(NSArray<NSString *> *)tags {
    MSInstallation *installation = [self getInstallation];

    if (installation.tags == nil || [installation.tags count] == 0) {
        return NO;
    }

    [installation removeTags:tags];

    [self upsertInstallation:installation];

    return YES;
}

#pragma mark Templates

+ (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key {
    return [sharedInstance setTemplate:template forKey:key];
}

+ (BOOL)removeTemplateForKey:(NSString *)key {
    return [sharedInstance removeTemplateForKey:key];
}

+ (MSInstallationTemplate *)getTemplateForKey:(NSString *)key {
    return [sharedInstance getTemplateForKey:key];
}

+ (NSDictionary<NSString *, MSInstallationTemplate *> *)getTemplates {
    return [sharedInstance getTemplates];
}

- (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key {
    MSInstallation *installation = [self getInstallation];

    if ([installation setTemplate:template forKey:key]) {
        [self upsertInstallation:installation];
        return YES;
    }

    return NO;
}

- (BOOL)removeTemplateForKey:(NSString *)key {
    MSInstallation *installation = [self getInstallation];

    if (installation.templates == nil || [installation.templates count] == 0) {
        return NO;
    }

    if ([installation removeTemplateForKey:key]) {
        [self upsertInstallation:installation];
        return YES;
    }

    return NO;
}

- (MSInstallationTemplate *)getTemplateForKey:(NSString *)key {
    return [[self getInstallation] getTemplateForKey:key];
}

- (NSDictionary<NSString *, MSInstallationTemplate *> *)getTemplates {
    return [[self getInstallation] templates];
}

#pragma mark Installation management support

+ (void)willSaveInstallation {
    [sharedInstance willSaveInstallation];
}

- (void)willSaveInstallation {
    [self upsertInstallation:[self getInstallation]];
}

+ (void)setEnrichmentDelegate:(nullable id<MSInstallationEnrichmentDelegate>)enrichmentDelegate {
    [[MSNotificationHub sharedInstance] setEnrichmentDelegate:enrichmentDelegate];
}

+ (void)setManagementDelegate:(nullable id<MSInstallationManagementDelegate>)managementDelegate {
    [[MSNotificationHub sharedInstance] setManagementDelegate:managementDelegate];
}

+ (void)setLifecycleDelegate:(nullable id<MSInstallationLifecycleDelegate>)lifecycleDelegate {
    [[MSNotificationHub sharedInstance] setLifecycleDelegate:lifecycleDelegate];
}

#pragma mark Helpers

- (NSString *)convertTokenToString:(NSData *)token {
    if (!token) {
        return nil;
    }
    const unsigned char *dataBuffer = token.bytes;
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:(token.length * 2)];
    for (NSUInteger i = 0; i < token.length; ++i) {
        [stringBuffer appendFormat:@"%02x", dataBuffer[i]];
    }
    return [NSString stringWithString:stringBuffer];
}

@end
