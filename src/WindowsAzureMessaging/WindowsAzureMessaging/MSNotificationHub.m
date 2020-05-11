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

+ (void)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)notificationHubName {
    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:connectionString
                                                                                                 hubName:notificationHubName];

    [[MSNotificationHub sharedInstance] setDebounceInstallationManager:[[MSDebounceInstallationManager alloc] initWithInterval:2
                                                                                       installationManager:installationManager]];

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

- (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    MSNotificationHubMessage *message = [MSNotificationHubMessage createFromNotification:userInfo];
    [self didReceivePushNotification:message];

    if (message.additionalData) {
        return YES;
    }
    return NO;
}

#pragma mark Instance Callbacks

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *pushToken = [self convertTokenToString:deviceToken];
    NSLog(@"Registered for push notifications with token: %@", pushToken);

    [self setPushChannel:pushToken];
    [_debounceInstallationManager saveInstallation:[self getInstallation]];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registering for push notifications has been finished with error: %@", error.localizedDescription);
}

- (void)didReceivePushNotification:(MSNotificationHubMessage *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
      id<MSNotificationHubDelegate> delegate = self.delegate;
      if ([delegate respondsToSelector:@selector(notificationHub:didReceivePushNotification:)]) {
          [delegate notificationHub:self didReceivePushNotification:notification];
      }
    });
}

#pragma mark Register Callbacks

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [sharedInstance didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [sharedInstance didFailToRegisterForRemoteNotificationsWithError:error];
}

+ (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    return [sharedInstance didReceiveRemoteNotification:userInfo];
}

#pragma mark SDK Basics

+ (void)setEnabled:(BOOL)isEnabled {
}

+ (BOOL)isEnabled {
    return YES;
}

+ (void)setDelegate:(nullable id<MSNotificationHubDelegate>)delegate {
    [sharedInstance setDelegate:delegate];
}

#pragma mark Installations

+ (NSString *) getPushChannel {
    return [sharedInstance getPushChannel];
}

+ (NSString *) getInstallationId {
    return [sharedInstance getInstallationId];
}

- (NSString *) getPushChannel {
    MSInstallation *installation = [self getInstallation];
    return installation.pushChannel;
}

- (NSString *) getInstallationId {
    MSInstallation *installation = [self getInstallation];
    return installation.installationID;
}

- (void)setPushChannel:(NSString *)pushChannel {
    MSInstallation *installation = [self getInstallation];

    installation.pushChannel = pushChannel;

    [MSLocalStorage upsertInstallation:installation];
}

- (MSInstallation *)getInstallation {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    if (!installation) {
        installation = [MSInstallation new];
    }

    return installation;
}

- (void)upsertInstallation:(MSInstallation *)installation;
{ [MSLocalStorage upsertInstallation:installation]; }

#pragma mark Tags

+ (BOOL)addTag:(NSString *)tag {
    return [MSNotificationHub addTags:[NSArray arrayWithObject:tag]];
}

+ (BOOL)addTags:(NSArray<NSString *> *)tags {
    return [sharedInstance addTags:tags];
}

+ (void)clearTags {
    [sharedInstance clearTags];
}

+ (NSArray<NSString *> *)getTags {
    return [sharedInstance getTags];
}

+ (BOOL)removeTag:(NSString *)tag {
    return [sharedInstance removeTag:tag];
}

+ (BOOL)removeTags:(NSArray<NSString *> *)tags {
    return [sharedInstance removeTags:tags];
}

- (BOOL)addTag:(NSString *)tag {
    return [self addTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)addTags:(NSArray<NSString *> *)tags {
    MSInstallation *installation = [self getInstallation];

    if ([installation addTags:tags]) {
        [self upsertInstallation:installation];
        [_debounceInstallationManager saveInstallation:installation];
        return YES;
    }

    return NO;
}

- (void)clearTags {
    MSInstallation *installation = [self getInstallation];

    if (installation && installation.tags && [installation.tags count] > 0) {
        [installation clearTags];
        [self upsertInstallation:installation];
        [_debounceInstallationManager saveInstallation:installation];
    }
}

- (NSArray<NSString *> *)getTags {
    return [[self getInstallation] getTags];
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
    [_debounceInstallationManager saveInstallation:installation];

    return YES;
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
