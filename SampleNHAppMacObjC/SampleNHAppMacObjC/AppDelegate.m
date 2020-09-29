//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "AppDelegate.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@interface AppDelegate() <MSNotificationHubDelegate, NSUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DevSettings" ofType:@"plist"];
    NSDictionary *configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *connectionString = [configValues objectForKey:@"CONNECTION_STRING"];
    NSString *hubName = [configValues objectForKey:@"HUB_NAME"];
    
    if([connectionString length] != 0 && [hubName length] != 0) {
        [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
        [MSNotificationHub setDelegate:self];
        [MSNotificationHub startWithConnectionString:connectionString hubName:hubName];
        
        [self addTags];
        
        return;
    }
    
    NSLog(@"Please setup CONNECTION_STRING and HUB_NAME in DevSettings.plist and restart application");
    
    exit(-1);
}

- (void) addTags {
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *countryCode = [[NSLocale currentLocale] countryCode];
    
    // Create tags with type_value format
    NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
    NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];

    [MSNotificationHub addTags:@[languageTag, countryCodeTag]];
}

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"Did register for remote notifications with device token.");
}

- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
  NSLog(@"Did fail to register for remote notifications with error %@.", [error localizedDescription]);
}

- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary<NSString *, id> *)userInfo {
  NSLog(@"Did receive remote notification");
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSLog(@"Did activate notification");
}

- (void)notificationHub:(MSNotificationHub *)notificationHub didReceivePushNotification:(MSNotificationHubMessage *)message {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageReceived" object:nil userInfo:userInfo];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
