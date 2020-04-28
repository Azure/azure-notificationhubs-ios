// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

#import "MSNotificationHub.h"

// Singleton
static MSNotificationHub *sharedInstance = nil;
static dispatch_once_t onceToken;

@implementation MSNotificationHub

@synthesize tags;
@synthesize templates;

- (instancetype)init {
    if ((self = [super init])) {
        tags = [NSMutableArray new];
        templates = [NSMutableDictionary new];
        
        [self registerForRemoteNotifications];
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

+ (void)initWithConnectionString:(NSString *) connectionString withHubName:(NSString*)notificationHubName {
    
}

- (void)registerForRemoteNotifications {
  if (@available(iOS 10.0, *)) {
      UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
      UNAuthorizationOptions authOptions = (UNAuthorizationOptions)(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge);
      [center requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError *_Nullable error) {
          if (granted) {
              NSLog(@"Push notifications authorization was granted.");
          } else {
              NSLog(@"Push notifications authorization was denied.");
          }
          if (error) {
              NSLog(@"Push notifications authorization request has been finished with error: %@", error.localizedDescription);
          }
      }];
  } else {
    UIUserNotificationType allNotificationTypes = (UIUserNotificationType)(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
  }
  [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark Instance Callbacks

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *pushToken = [self convertTokenToString:deviceToken];
    NSLog(@"Registered for push notifications with token: %@", pushToken);
    if ([pushToken isEqualToString:self.pushToken]) {
      return;
    }
    self.pushToken = pushToken;
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registering for push notifications has been finished with error: %@", error.localizedDescription);
}

- (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    return NO;
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

+ (void)setDelegate:(nullable id<MSNotificationHubMessageDelegate>)delegate {
  [[MSNotificationHub sharedInstance] setDelegate:delegate];
}

#pragma mark Tags

+ (void)addTag:(NSString *)tag {
    [[MSNotificationHub sharedInstance] addInstallationTag:tag];
}

+ (void)removeTag:(NSString *)tag {
    [[MSNotificationHub sharedInstance] removeInstallationTag:tag];
}

+ (NSArray<NSString *> *)getTags {
    return [[MSNotificationHub sharedInstance] tags];
}

- (void)addInstallationTag:(NSString *)tag {
    // TODO: Store in local storage and mark as dirty
    [self.tags addObject:tag];
}

- (void)removeInstallationTag:(NSString *)tag {
    // TODO: Store in local storage and mark as dirty
    [self.tags removeObject:tag];
}

#pragma mark Templates

+ (void)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key {
    [[MSNotificationHub sharedInstance] setInstallationTemplate:template forKey:key];
}

+ (void)removeTemplate:(NSString *)key {
    [[MSNotificationHub sharedInstance] removeInstallationTemplate:key];
}

+ (MSInstallationTemplate *)getTemplate:(NSString *)name {
    return nil;
}

- (void)setInstallationTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key {
    // TODO: Store in local storage and mark as dirty
    [self.templates setValue:template forKey:key];
}

- (void)removeInstallationTemplate:(NSString *)key {
    [self.templates removeObjectForKey:key];
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
