//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "TagTableViewCell.h"
#import "NotificationsTableViewController.h"

@interface SetupViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ANHNotificationHubDelegate>
@property (weak, nonatomic) IBOutlet UILabel *deviceTokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *installationIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *addNewTagTextField;
@property (weak, nonatomic) IBOutlet UITableView *tagsTable;
@property (weak, nonatomic) IBOutlet UITextField *userId;

@property (nonatomic, copy) NSArray<NSString *> *tags;
@property (weak, nonatomic) NotificationsTableViewController *notificationsTableView;

@end

