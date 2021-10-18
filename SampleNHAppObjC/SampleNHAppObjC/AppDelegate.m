//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "AppDelegate.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <ANHNotificationHubDelegate, UNUserNotificationCenterDelegate>

@property(nonatomic) API_AVAILABLE(ios(10.0)) void (^notificationPresentationCompletionHandler)(UNNotificationPresentationOptions options);
@property(nonatomic) void (^notificationResponseCompletionHandler)(void);

@end

@implementation AppDelegate

@synthesize notificationPresentationCompletionHandler;
@synthesize notificationResponseCompletionHandler;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DevSettings" ofType:@"plist"];
    NSDictionary *configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *connectionString = [configValues objectForKey:@"CONNECTION_STRING"];
    NSString *hubName = [configValues objectForKey:@"HUB_NAME"];
    
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    NSError *anhError;
    ANHNotificationHub.logLevel = ANHLogLevelDebug;
    [ANHNotificationHub sharedInstance].delegate = self;
    if (![[ANHNotificationHub sharedInstance] startWithConnectionString:connectionString hubName:hubName error:&anhError]) {
        NSLog(@"Error starting the ANH client: %@", anhError.localizedDescription);
        
        exit(-1);
    }
    
    [self addTags];
    
    return YES;
}

// Adds some basic tags such as language and country
- (void)addTags {
    // Get language and country code for common tag values
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *countryCode = [[NSLocale currentLocale] countryCode];

    // Create tags with type_value format
    NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
    NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];

    [[ANHNotificationHub sharedInstance] addTags:@[languageTag, countryCodeTag]];
}

#pragma mark - MSNotificationHubDelegate

- (void)notificationHub:(ANHNotificationHub *)notificationHub didReceivePushNotification:(ANHNotificationHubMessage *)message {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageReceived" object:nil userInfo:userInfo];
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
        NSLog(@"Notification received in the background");
    }
    
    if (notificationResponseCompletionHandler) {
        NSLog(@"Tapped Notification");
    } else {
        NSLog(@"Notification received in the foreground");
    }
    
    // Call notification completion handlers.
    if (notificationResponseCompletionHandler) {
        notificationResponseCompletionHandler();
        notificationResponseCompletionHandler = nil;
    }
    if (notificationPresentationCompletionHandler) {
        notificationPresentationCompletionHandler(UNNotificationPresentationOptionNone);
        notificationPresentationCompletionHandler = nil;
    }
    
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(10.0)) {
  notificationPresentationCompletionHandler = completionHandler;
}

// iOS 10 and later, asks the delegate to process the user's response to a delivered notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
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

@end
