//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "NotificationsTableViewController.h"

@interface ViewController : NSViewController<NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource, NSApplicationDelegate, MSNotificationHubDelegate>
@property (nonatomic, strong) NotificationsTableViewController *notificationsTableViewController;
@property (nonatomic, copy) NSArray<NSString *> *tags;

@property (weak) IBOutlet NSTextField *installationIdTextField;
@property (weak) IBOutlet NSTextField *deviceTokenTextField;
@property (weak) IBOutlet NSTableView *tagsTable;
@property (weak) IBOutlet NSTextField *tagsTextField;
@property (weak) IBOutlet NSTableView *notificationsTable;
@property (weak) IBOutlet NSTextField *userIdTextField;

@end

