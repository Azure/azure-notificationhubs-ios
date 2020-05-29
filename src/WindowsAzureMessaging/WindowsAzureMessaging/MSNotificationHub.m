//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import "MSDebounceInstallationManager.h"
#import "MSInstallation.h"
#import "MSInstallationManager.h"
#import "MSLocalStorage.h"
#import "MSNotificationHub.h"
#import "MSNotificationHubMessage.h"
#import "MSNotificationHubPrivate.h"
#import "MSTokenProvider.h"

// Singleton
static MSNotificationHub *sharedInstance = nil;
static dispatch_once_t onceToken;

@implementation MSNotificationHub

- (instancetype)init {
    if ((self = [super init])) {
    }

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

+ (void)resetSharedInstance {

    // Resets the once_token so dispatch_once will run again
    onceToken = 0;
    sharedInstance = nil;
}

+ (void)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)notificationHubName {
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
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions authOptions =
            (UNAuthorizationOptions)(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge);
        [center requestAuthorizationWithOptions:authOptions
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                if (granted) {
                                    NSLog(@"Push notifications authorization was granted.");
                                } else {
                                    NSLog(@"Push notifications authorization was denied.");
                                }
                                if (error) {
                                    NSLog(@"Push notifications authorization request has "
                                          @"been finished with error: %@",
                                          error.localizedDescription);
                                }
                              }];
    } else {
        UIUserNotificationType allNotificationTypes =
            (UIUserNotificationType)(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithUserInfo:userInfo];
    [self didReceivePushNotification:message fetchCompletionHandler:completionHandler];
}

#pragma mark Instance Callbacks

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *pushToken = [self convertTokenToString:deviceToken];
    NSLog(@"Registered for push notifications with token: %@", pushToken);

    dispatch_async(dispatch_get_main_queue(), ^{
      id<MSNotificationHubDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(notificationHub:receivedPushToken:)]) {
            [delegate notificationHub:self receivedPushToken:pushToken];
      }
    });

    MSInstallation *installation = [self getInstallation];

    if ([pushToken isEqualToString:installation.pushChannel]) {
        return;
    }

    installation.pushChannel = pushToken;
    [self upsertInstallation:installation];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registering for push notifications has been finished with error: %@", error.localizedDescription);

    dispatch_async(dispatch_get_main_queue(), ^{
      id<MSNotificationHubDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(notificationHub:didFailToRegisterForRemoteNotificationsWithError:)]) {
            [delegate notificationHub:self didFailToRegisterForRemoteNotificationsWithError:error];
      }
    });
}

- (void)didReceivePushNotification:(MSNotificationHubMessage *)notification
            fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
      id<MSNotificationHubDelegate> delegate = self.delegate;
      if ([delegate respondsToSelector:@selector(notificationHub:didReceivePushNotification:fetchCompletionHandler:)]) {
          [delegate notificationHub:self didReceivePushNotification:notification fetchCompletionHandler:completionHandler];
      }
    });
}

#pragma mark Register Callbacks

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[MSNotificationHub sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[MSNotificationHub sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    return [[MSNotificationHub sharedInstance] didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
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
        [self upsertInstallation:[self getInstallation]];
        NSLog(@"Notification Hubs SDK has been enabled");
    } else {
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

#pragma mark Installation management support

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
