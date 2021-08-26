
//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "AppDelegate.h"
#import "Constants.h"
#import "BPush.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@property(nonatomic) API_AVAILABLE(ios(10.0)) void (^notificationPresentationCompletionHandler)(UNNotificationPresentationOptions options);
@property(nonatomic) void (^notificationResponseCompletionHandler)(void);

@end

@implementation AppDelegate

@synthesize notificationPresentationCompletionHandler;
@synthesize notificationResponseCompletionHandler;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
       
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
    
    [application registerForRemoteNotifications];
    
    // To register for Baidu Cloud Push Service when the App is started, Apikey is required
    [BPush registerChannel:launchOptions apiKey:kBaiduApiKey pushMode:BPushModeDevelopment withFirstAction:@"Open" withSecondAction:@"Close" withCategory:@"test" useBehaviorTextInput:YES isDebug:YES];
    
    // Disable geographic location push needs to be called before binding the interface
    [BPush disableLbs];
    
    
    // App is started when the user clicks on the push message
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [BPush handleNotification:userInfo];
    }
    
    return YES;
}

#pragma mark - UIApplicationDelegate

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"%@",userInfo);
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
        NSLog(@"Notification received in the background");
    }
    
    if (notificationResponseCompletionHandler) {
        NSLog(@"Tapped Notification");
    } else {
        NSLog(@"Notification received in the foreground");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageReceived" object:nil userInfo:userInfo];

    // Call notification completion handlers.
    if (notificationResponseCompletionHandler) {
        notificationResponseCompletionHandler();
        notificationResponseCompletionHandler = nil;
    }
    if (notificationPresentationCompletionHandler) {
        notificationPresentationCompletionHandler(UNNotificationPresentationOptionNone);
        notificationPresentationCompletionHandler = nil;
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)application:(UIApplication *)applicaion didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    NSLog(@"Device Token String %@", [self convertTokenToString:deviceToken]);
    
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error in bindChannelWithCompleteHandler: %@", [error localizedDescription]);
            return ;
        }
        
        if (result) {
            if ([result[@"error_code"] intValue] != 0) {
                return;
            }
            
            NSString *baiduChannelId = [BPush getChannelId];
            NSLog(@"Baidu Channel ID: %@", baiduChannelId);
            
            NSString *baiduUserId = [BPush getUserId];
            NSLog(@"Baidu User ID: %@", baiduUserId);
            
            [BPush listTagsWithCompleteHandler:^(id result, NSError * _Nullable err) {
                
                if (err) {
                    NSLog(@"Error in listTagsWithCompleteHandler: %@", [err localizedDescription]);
                    return;
                }
                
                NSLog(@"listTagsWithCompleteHandler result: %@", result);
            }];
            
            NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            NSString *countryCode = [[NSLocale currentLocale] countryCode];

            // Create tags with type_value format
            NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
            NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];
            
            [BPush setTags:@[languageTag, countryCodeTag] withCompleteHandler:^(id result, NSError * _Nullable err) {
                
                if (err) {
                    NSLog(@"Error in setTags: %@", [err localizedDescription]);
                    return;
                }
                
                NSLog(@"setTags result: %@", result);
            }];
        }
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    NSLog(@"Error registering for push %@", [error localizedDescription]);
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  notificationPresentationCompletionHandler = completionHandler;
}

// iOS 10 and later, asks the delegate to process the user's response to a delivered notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {
  notificationResponseCompletionHandler = completionHandler;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

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
