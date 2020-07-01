//
//  AppDelegate.m
//  SampleNHAppMacObjC
//
//  Created by Matthew Podwysocki on 6/30/20.
//  Copyright © 2020 Matthew Podwysocki. All rights reserved.
//

#import "AppDelegate.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@interface AppDelegate () <MSNotificationHubDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DevSettings" ofType:@"plist"];
    NSDictionary *configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *connectionString = [configValues objectForKey:@"CONNECTION_STRING"];
    NSString *hubName = [configValues objectForKey:@"HUB_NAME"];
    
    [MSNotificationHub setDelegate:self];
    [MSNotificationHub startWithConnectionString:connectionString hubName:hubName];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark MSNotificationHubDelegate

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"Did register for remote notifications with device token.");
}

- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
  NSLog(@"Did fail to register for remote notifications with error %@.", [error localizedDescription]);
}

- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary<NSString *, id> *)userInfo {
  NSLog(@"Did receive remote notification");
}

- (void)notificationHub:(MSNotificationHub *)notificationHub didReceivePushNotification:(MSNotificationHubMessage *)message {
    NSLog(@"Message title: %@", message.title);
    NSLog(@"Message body: %@", message.body);
}


@end
