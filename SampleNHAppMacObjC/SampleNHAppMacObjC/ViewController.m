//
//  ViewController.m
//  SampleNHAppMacObjC
//
//  Created by Matthew Podwysocki on 6/30/20.
//  Copyright © 2020 Matthew Podwysocki. All rights reserved.
//

#import "ViewController.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_DeviceTokenTextField  setStringValue:[MSNotificationHub getPushChannel]];
    [_InstallationIdTextField setStringValue:[MSNotificationHub getInstallationId]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [tableView numberOfRows];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
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

- (void)notificationHub:(MSNotificationHub *)notificationHub didReceivePushNotification:(MSNotificationHubMessage *)message {
    NSLog(@"Message title: %@", message.title);
    NSLog(@"Message body: %@", message.body);
}

@end
