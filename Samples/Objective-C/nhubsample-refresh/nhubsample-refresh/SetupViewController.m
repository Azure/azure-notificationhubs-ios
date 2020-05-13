//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SetupViewController.h"
#import "NotificationsTableViewController.h"

@interface SetupViewController ()

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tags = [MSNotificationHub getTags];
    
    self.addNewTagTextField.delegate = self;
    self.tagsTable.delegate = self;
    self.tagsTable.dataSource = self;
    [self.tagsTable reloadData];
    
    self.deviceTokenLabel.text = [MSNotificationHub getPushChannel];
    self.installationIdLabel.text = [MSNotificationHub getInstallationId];
    
    self.notificationsTableView = (NotificationsTableViewController*) [[(UINavigationController*)[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
    
    [MSNotificationHub setDelegate:self];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Hide the keyboard.
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [MSNotificationHub addTag:textField.text];
    self.tags = [MSNotificationHub getTags];
    textField.text = @"";
    [self.tagsTable reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TagCell";
    
    TagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.tagLabel.text = self.tags[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tags count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MSNotificationHub removeTag:self.tags[indexPath.row]];
        self.tags = [MSNotificationHub getTags];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tagsTable reloadData];
    }
}

- (void)notificationHub:(MSNotificationHub *)notificationHub didReceivePushNotification:(MSNotificationHubMessage *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler  {
    NSLog(@"Received notification: %@: %@", notification.title, notification.body);
    [self.notificationsTableView addNotification:notification];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:notification.title
                                                                             message:notification.body
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion: nil];
    });
    completionHandler((notification.data != nil && [notification.data count] > 0) ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
}


@end
