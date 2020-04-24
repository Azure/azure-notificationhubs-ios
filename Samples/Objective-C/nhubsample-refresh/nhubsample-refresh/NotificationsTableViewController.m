// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "NotificationsTableViewController.h"

@interface NotificationsTableViewController ()

@end

@implementation NotificationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.notifications = @[@"notification1", @"notification2", @"notification3"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"NotificationCell";
    
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.notificationSummaryLabel.text = self.notifications[indexPath.row];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqual: @"showNotificationDetails"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NotificationDetailsViewController *detailsView = segue.destinationViewController;
        
        detailsView.notification = self.notifications[indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


@end
