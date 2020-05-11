//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "NotificationsTableViewController.h"

@interface NotificationsTableViewController ()

@end

@implementation NotificationsTableViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        self.notifications = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    cell.notificationSummaryLabel.text = [self.notifications objectAtIndex:indexPath.row].title ?: [self.notifications objectAtIndex:indexPath.row].body;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqual: @"showNotificationDetails"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NotificationDetailsViewController *detailsView = segue.destinationViewController;
        
        detailsView.notification = [self.notifications objectAtIndex:indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void) addNotification:(MSNotificationHubMessage *) notification {
    [self.notifications addObject:notification];
    [self.tableView reloadData];
}


@end
