//
//  NotificationsTableViewController.m
//  SampleNHAppMacObjC
//
//  Created by User on 06.07.2020.
//  Copyright © 2020 Matthew Podwysocki. All rights reserved.
//

#import "NotificationsTableViewController.h"

@implementation NotificationsTableViewController

- (id) initWithTableView: (NSTableView *) tableView {
    self = [super init];
    if (self) {
        self.notificationDetails = [NSMutableArray array];
        
        tableView.dataSource = self;
        tableView.delegate = self;
    }
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_notificationDetails count];
}

- (void) addNotificationHubMessage:(MSNotificationHubMessage *) details {
    [self.notificationDetails addObject:details];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (_notificationDetails[row]) {
        NSTableCellView *cell;
        
        if (tableColumn == tableView.tableColumns[0]) {
            cell = [tableView makeViewWithIdentifier:@"TitleNotificationCell" owner:nil];
            cell.textField.stringValue = _notificationDetails[row].title;
        } else if (tableColumn == tableView.tableColumns[1]) {
            cell = [tableView makeViewWithIdentifier:@"BodyNotificationCell" owner:nil];
            cell.textField.stringValue = _notificationDetails[row].body;
        }
        
        return cell;
    };
    
    return nil;
}

@end
