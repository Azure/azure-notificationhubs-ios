//
//  NotificationsTableViewController.h
//  SampleNHAppMacObjC
//
//  Created by User on 06.07.2020.
//  Copyright © 2020 Matthew Podwysocki. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
@interface NotificationsTableViewController : NSObject<NSTableViewDelegate, NSTableViewDataSource>
@property(nonatomic) NSMutableArray<MSNotificationHubMessage *> *notificationDetails;

- (id) initWithTableView: (NSTableView *) tableView;
- (void) addNotificationHubMessage:(MSNotificationHubMessage *) details;
@end
