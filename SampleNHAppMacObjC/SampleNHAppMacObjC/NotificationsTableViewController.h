//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
@interface NotificationsTableViewController : NSObject<NSTableViewDelegate, NSTableViewDataSource>
@property(nonatomic) NSMutableArray<MSNotificationHubMessage *> *notificationDetails;

- (id) initWithTableView: (NSTableView *) tableView;
- (void) addNotificationHubMessage:(MSNotificationHubMessage *) details;
@end
